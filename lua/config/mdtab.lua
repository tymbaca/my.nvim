-- Per-region indentation for Markdown buffers.
--
--   * prose (and anything outside a fenced code block): <Tab> inserts 2 spaces,
--     > / < shift by 2.
--   * inside a fenced code block: the indentation settings of the block's own
--     filetype are used, i.e. a python block indents with 4 spaces, a lua/js block
--     with 2, and a go block inserts real <Tab> characters.
--   * tabs are *rendered* with the width their language uses, even when one buffer
--     mixes blocks that need different tab widths (go = 8, a 4-wide tab language, ...).
--
-- How the tab rendering works
-- ---------------------------
-- Neovim keeps a single 'tabstop' per buffer, so mixed-width tab blocks cannot be
-- rendered natively. To get per-block widths the buffer gets a buffer-local
-- 'tabstop' of 1 and every real <Tab> is patched with an inline virtual-text extmark
-- holding (advance - 1) spaces; the tab itself keeps showing as its single blank
-- cell, so the line ends up exactly `advance` cells wide -- the same width it would
-- have in a native buffer of that filetype. Verified against native .go (tabstop 8)
-- and .c (tabstop 4) buffers.
--
-- Side effects worth knowing: 'tabstop' is 1 inside markdown buffers, so anything
-- that computes columns from 'tabstop' (some statusline/tab indicators) sees 1.
-- Text itself is never modified, so files keep their tabs.

local api = vim.api
local ns = api.nvim_create_namespace("mdtab_tabs")

local M = {}

M.config = {
  -- indentation step used for prose and for code blocks of unknown languages
  prose_width = 2,
  -- paint tabs at their per-language width (sets 'tabstop' = 1 in markdown buffers)
  render_tabs = true,
  -- probe the real settings of a code block's filetype in a scratch buffer
  probe = true,
  -- per language overrides, e.g. { javascript = { spaces = 2 }, go = { tabs = 8 } }
  overrides = {},
}

-- info-string name -> filetype
local aliases = {
  js = "javascript",
  jsx = "javascriptreact",
  ts = "typescript",
  tsx = "typescriptreact",
  py = "python",
  py3 = "python",
  python3 = "python",
  rb = "ruby",
  rs = "rust",
  golang = "go",
  ["c++"] = "cpp",
  cxx = "cpp",
  cs = "cs",
  ["c#"] = "cs",
  csharp = "cs",
  yml = "yaml",
  yaml = "yaml",
  md = "markdown",
  markdown = "markdown",
  kt = "kotlin",
  kts = "kotlin",
  hs = "haskell",
  ex = "elixir",
  exs = "elixir",
  sh = "sh",
  bash = "sh",
  shell = "sh",
  zsh = "zsh",
  console = "sh",
  console_out = "sh",
  tf = "terraform",
  hcl = "hcl",
  ps1 = "powershell",
  pwsh = "powershell",
  make = "make",
  makefile = "make",
  docker = "dockerfile",
  dockerfile = "dockerfile",
  proto3 = "proto",
  objc = "objc",
  text = "text",
  txt = "text",
  plaintext = "text",
  plain = "text",
  diff = "diff",
  patch = "diff",
  json5 = "jsonc",
}

---@type table<integer, { tick: integer, blocks: table[] }>
local scan_cache = {}
---@type table<string, table|false>
local settings_cache = {}

local function buf_option(buf, name)
  return api.nvim_get_option_value(name, { buf = buf })
end

local function buf_set(buf, name, value)
  api.nvim_set_option_value(name, value, { buf = buf })
end

-- ---------------------------------------------------------------------------
-- fenced code blocks
-- ---------------------------------------------------------------------------

local function fence_open(line)
  local lead = line:match("^(%s*)")
  if #lead > 3 then
    return nil
  end
  local rest = line:sub(#lead + 1)
  local ticks = rest:match("^(`+)")
  if ticks and #ticks >= 3 then
    local info = rest:sub(#ticks + 1)
    -- a backtick info string cannot contain backticks (CommonMark); keeping this
    -- line out of the scanner matters for editors that auto-close fences, which
    -- leave "```m<cursor>```" behind while you type
    if info:find("`", 1, true) then
      return nil
    end
    return "`", #ticks, info
  end
  local tildes = rest:match("^(~+)")
  if tildes and #tildes >= 3 then
    return "~", #tildes, rest:sub(#tildes + 1)
  end
  return nil
end

local function fence_close(line, ch, count)
  local lead = line:match("^(%s*)")
  if #lead > 3 then
    return false
  end
  local rest = line:sub(#lead + 1)
  local run = rest:match("^" .. vim.pesc(ch) .. "+")
  if not run or #run < count then
    return false
  end
  return rest:sub(#run + 1):match("^%s*$") ~= nil
end

---@param info string
---@return string|nil
local function info_lang(info)
  info = (info or ""):gsub("^%s*", "")
  if info == "" then
    return nil
  end
  local first = info:match("^%S+") or ""
  -- {@lua}, {.lua}, {lua}, .lua, lua
  local name = first:match("^%{%s*[%.:]?%s*([%w_%-%+%#%.]+)") or first
  name = name:gsub("{.*$", "")
  name = name:gsub("^[%.:]+", ""):gsub("[%.,;:}%)]+$", ""):gsub("%s+$", "")
  -- Only a plain language token may reach filetype lookups: anything else (stray
  -- backticks, globs, spaces, ...) would be expanded as a wildcard path by
  -- nvim_get_runtime_file() and spew "E79: Cannot expand wildcards".
  if not name:match("^[%w_%-%+%#][%w_%-%+%#%.]*$") then
    return nil
  end
  return name:lower()
end

---@param buf integer
---@return table[] blocks `{ start = fence row, stop = fence row (or last+1), lang = string|nil }`
local function blocks(buf)
  local tick = api.nvim_buf_get_changedtick(buf)
  local cached = scan_cache[buf]
  if cached and cached.tick == tick then
    return cached.blocks
  end

  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local out, cur = {}, nil
  for i, line in ipairs(lines) do
    local ch, count, info = fence_open(line)
    if cur then
      if ch == cur.ch and fence_close(line, ch, cur.count) then
        cur.stop = i
        out[#out + 1] = cur
        cur = nil
      end
    elseif ch then
      cur = { start = i, ch = ch, count = count, lang = info_lang(info) }
    end
  end
  if cur then
    cur.stop = #lines + 1
    out[#out + 1] = cur
  end

  scan_cache[buf] = { tick = tick, blocks = out }
  return out
end

---@return table|nil block containing `row` (content only, fences excluded)
local function block_at(buf, row)
  for _, b in ipairs(blocks(buf)) do
    if row > b.start and row < b.stop then
      return b
    end
  end
  return nil
end

-- ---------------------------------------------------------------------------
-- per filetype indentation settings
-- ---------------------------------------------------------------------------

local known_cache = {}

local function is_known_ft_uncached(ft)
  -- never hand a non-token to the runtime-path expansion (see info_lang)
  if type(ft) ~= "string" or not ft:match("^[%w_%-%+%#%.]+$") then
    return false
  end
  local ok_plugin, plugin = pcall(api.nvim_get_runtime_file, "ftplugin/" .. ft .. ".vim", false)
  if ok_plugin and plugin and plugin[1] then
    return true
  end
  local ok_indent, indent = pcall(api.nvim_get_runtime_file, "indent/" .. ft .. ".vim", false)
  if ok_indent and indent and indent[1] then
    return true
  end
  local ok, aus = pcall(api.nvim_get_autocmds, { event = "FileType" })
  if ok then
    for _, au in ipairs(aus) do
      for pattern in (au.pattern or ""):gmatch("[^,]+") do
        if pattern == ft then
          return true
        end
      end
    end
  end
  return false
end

local function is_known_ft(ft)
  local cached = known_cache[ft]
  if cached ~= nil then
    return cached
  end
  known_cache[ft] = is_known_ft_uncached(ft)
  return known_cache[ft]
end

--- Real indentation options of `ft`, read from a throwaway buffer so ftplugins and
--- the user's own FileType autocmds are honoured.
---@param ft string
---@return table|nil
local function probe_ft(ft)
  local buf = api.nvim_create_buf(false, true)
  buf_set(buf, "swapfile", false)
  buf_set(buf, "undolevels", -1)
  buf_set(buf, "buflisted", false)

  local res
  local ok = pcall(function()
    api.nvim_buf_call(buf, function()
      vim.cmd("silent! setlocal filetype=" .. ft)
      res = {
        expandtab = vim.bo.expandtab,
        ts = vim.bo.tabstop,
        sts = vim.bo.softtabstop,
        sw = vim.bo.shiftwidth,
      }
    end)
  end)
  pcall(api.nvim_buf_delete, buf, { force = true })

  if not ok or not res then
    return nil
  end
  return res
end

---@param ft string
---@return table|nil settings `{ expandtab, ts, sts, sw, step, shift }`
local function settings_for_ft(ft)
  if type(ft) ~= "string" or not ft:match("^[%w_%-%+%#%.]+$") then
    return nil
  end
  local cached = settings_cache[ft]
  if cached ~= nil then
    return cached or nil
  end

  local override = M.config.overrides[ft]
  if override then
    local n = override.spaces or override.tabs
    if n then
      local s = {
        expandtab = override.spaces ~= nil,
        ts = n,
        sts = n,
        sw = n,
      }
      s.step = n
      s.shift = n
      settings_cache[ft] = s
      return s
    end
  end

  local raw = M.config.probe and probe_ft(ft) or nil
  if not raw then
    settings_cache[ft] = false
    return nil
  end

  local ts = raw.ts > 0 and raw.ts or 8
  local sts = raw.sts > 0 and raw.sts or ts
  local sw = raw.sw > 0 and raw.sw or ts
  raw.ts, raw.sts, raw.sw = ts, sts, sw
  raw.step = sts
  raw.shift = sw
  settings_cache[ft] = raw
  return raw
end

--- Indentation spec for `row`: its code block's language, or prose.
---@return table `{ expandtab, ts, sts, sw, step, shift, prose }`
local function spec_at(buf, row)
  local block = block_at(buf, row)
  if block and block.lang then
    local ft = aliases[block.lang] or block.lang
    if is_known_ft(ft) then
      local s = settings_for_ft(ft)
      if s then
        return s
      end
    end
  end

  local saved = vim.b[buf].mdtab_saved or {}
  local w = math.max(1, M.config.prose_width)
  return {
    expandtab = true,
    ts = saved.ts or 4,
    sts = w,
    sw = w,
    step = w,
    shift = w,
    prose = true,
  }
end

-- ---------------------------------------------------------------------------
-- tab rendering
-- ---------------------------------------------------------------------------

--- Display width of `text` when every tab advances by `width`.
local function display_width(text, width)
  local col = 0
  local pos = 1
  while pos <= #text do
    local t = text:find("\t", pos, true)
    local seg = text:sub(pos, (t or (#text + 1)) - 1)
    col = col + vim.fn.strdisplaywidth(seg)
    if not t then
      break
    end
    col = col + (width - col % width)
    pos = t + 1
  end
  return col
end

local function paint_line(buf, row, line, width)
  if width < 1 then
    return
  end
  local col, pos = 0, 1
  while true do
    local t = line:find("\t", pos, true)
    if not t then
      break
    end
    col = col + vim.fn.strdisplaywidth(line:sub(pos, t - 1))
    local advance = width - col % width
    local pad = advance - 1
    if pad > 0 then
      api.nvim_buf_set_extmark(buf, ns, row - 1, t - 1, {
        end_col = t,
        virt_text = { { (" "):rep(pad), "Normal" } },
        virt_text_pos = "inline",
        hl_mode = "combine",
      })
    end
    col = col + advance
    pos = t + 1
  end
end

--- Width to paint tabs with, per line, for the current block structure.
local function widths(buf, block_list, saved)
  local in_block = {}
  for _, b in ipairs(block_list) do
    local block_spec = b.lang and spec_at(buf, b.start + 1) or nil
    local width = (block_spec and not block_spec.prose) and block_spec.ts or saved.ts
    for row = b.start + 1, b.stop - 1 do
      in_block[row] = width
    end
  end
  return in_block
end

--- Render every tab in the buffer (or only rows `first0`..`last0`, 0-based and
--- half-open) at the width of the block it belongs to.
local function render(buf, first0, last0)
  if not api.nvim_buf_is_valid(buf) then
    return
  end
  if vim.bo[buf].filetype ~= "markdown" then
    return
  end

  local lines = api.nvim_buf_get_lines(buf, 0, -1, false)
  local from = math.max(0, first0 or 0)
  local to = math.min(#lines, last0 or #lines)
  api.nvim_buf_clear_namespace(buf, ns, from, to)

  local saved = vim.b[buf].mdtab_saved
  if not saved or not M.config.render_tabs then
    return
  end

  local block_list = blocks(buf)
  local in_block = widths(buf, block_list, saved)

  for row = from + 1, to do
    local line = lines[row]
    if line and line:find("\t", 1, true) then
      paint_line(buf, row, line, in_block[row] or saved.ts)
    end
  end
end

-- Block structure signature; tab widths of untouched lines only change when a
-- fence (and thus the structure) changes.
local structure_sig = {}

local function sig(block_list)
  local parts = {}
  for _, b in ipairs(block_list) do
    parts[#parts + 1] = ("%d-%d-%s"):format(b.start, b.stop, b.lang or "")
  end
  return table.concat(parts, ",")
end

local pending = {}

--- Coalesce repaint requests into a single pass in the next event-loop tick, so the
--- paint lands in the same redraw as the edit (no visible lag) while typing still
--- only costs the lines that changed. `first0`/`last0` are 0-based, half-open;
--- leaving them out asks for a full repaint.
local function schedule_render(buf, first0, last0)
  local span = pending[buf]
  if not span then
    span = { full = false }
    pending[buf] = span
    vim.schedule(function()
      local job = pending[buf]
      pending[buf] = nil
      if not api.nvim_buf_is_valid(buf) or not job then
        return
      end
      local block_list = blocks(buf)
      local current = sig(block_list)
      if job.full or structure_sig[buf] ~= current then
        structure_sig[buf] = current
        render(buf) -- fences moved (or explicit request): every width may have changed
      elseif job.first then
        render(buf, job.first, job.last)
      end
    end)
  end
  if first0 == nil then
    span.full = true
  else
    local stop = last0 or (first0 + 1)
    span.first = span.first and math.min(span.first, first0) or first0
    span.last = span.last and math.max(span.last, stop) or stop
  end
end

-- ---------------------------------------------------------------------------
-- indent operations
-- ---------------------------------------------------------------------------

local function shift_lines(start_line, end_line, dir)
  local buf = api.nvim_get_current_buf()
  local saved = vim.b[buf].mdtab_saved
  if not saved or start_line < 1 or vim.bo[buf].filetype ~= "markdown" then
    return
  end
  end_line = math.min(end_line, api.nvim_buf_line_count(buf))

  -- group consecutive lines that share the same indentation spec
  local groups = {}
  for row = start_line, end_line do
    local spec = spec_at(buf, row)
    local key = ("%s:%d:%d"):format(spec.expandtab and "et" or "noet", spec.shift, spec.ts)
    local group = groups[#groups]
    if group and group.key == key then
      group.stop = row
    else
      groups[#groups + 1] = { key = key, start = row, stop = row, spec = spec }
    end
  end

  local keep = {
    sw = buf_option(buf, "shiftwidth"),
    ts = buf_option(buf, "tabstop"),
    sts = buf_option(buf, "softtabstop"),
    et = buf_option(buf, "expandtab"),
  }
  local cursor = api.nvim_win_get_cursor(0)

  for _, group in ipairs(groups) do
    local spec = group.spec
    buf_set(buf, "shiftwidth", spec.shift)
    buf_set(buf, "softtabstop", spec.step)
    buf_set(buf, "tabstop", spec.ts)
    buf_set(buf, "expandtab", spec.expandtab)
    local ok, err = pcall(vim.cmd, ("%d,%d%s"):format(group.start, group.stop, dir > 0 and ">" or "<"))
    if not ok then
      M.last_error = err
      vim.notify("mdtab: shift failed: " .. tostring(err), vim.log.levels.WARN)
    end
    buf_set(buf, "shiftwidth", keep.sw)
    buf_set(buf, "softtabstop", keep.sts)
    buf_set(buf, "tabstop", keep.ts)
    buf_set(buf, "expandtab", keep.et)
  end

  pcall(api.nvim_win_set_cursor, 0, cursor)
end

function M.shift(dir)
  shift_lines(vim.fn.line("'["), vim.fn.line("']"), dir)
end

-- ---------------------------------------------------------------------------
-- insert mode <Tab>
-- ---------------------------------------------------------------------------

local function tab()
  local buf = api.nvim_get_current_buf()
  if vim.bo[buf].filetype ~= "markdown" then
    api.nvim_feedkeys(api.nvim_replace_termcodes("<Tab>", true, false, true), "in", false)
    return
  end
  local row, col = unpack(api.nvim_win_get_cursor(0))
  local spec = spec_at(buf, row)
  local line = api.nvim_get_current_line()
  local width = spec.ts > 0 and spec.ts or 8

  if not spec.expandtab then
    -- <C-v><Tab>: a literal tab, regardless of 'expandtab' / 'softtabstop'
    api.nvim_feedkeys(api.nvim_replace_termcodes("<C-v><Tab>", true, false, true), "in", false)
    return
  end

  local step = spec.step > 0 and spec.step or width
  local cur = display_width(line:sub(1, col), width)
  local n = step - cur % step
  if n <= 0 then
    n = step
  end
  api.nvim_feedkeys((" "):rep(n), "in", false)
end

-- ---------------------------------------------------------------------------
-- attach
-- ---------------------------------------------------------------------------

local group = api.nvim_create_augroup("mdtab", { clear = true })

local function probe_pending_languages(buf)
  local wanted = {}
  for _, b in ipairs(blocks(buf)) do
    if b.lang then
      local ft = aliases[b.lang] or b.lang
      if settings_cache[ft] == nil and is_known_ft(ft) then
        wanted[#wanted + 1] = ft
      end
    end
  end
  if #wanted == 0 then
    return
  end
  vim.schedule(function()
    for _, ft in ipairs(wanted) do
      if api.nvim_buf_is_valid(buf) then
        settings_for_ft(ft)
      end
    end
    render(buf)
  end)
end

local function map(buf)
  vim.keymap.set("i", "<Tab>", tab, { buffer = buf, desc = "Indent: 2 spaces in prose, block filetype in code" })
  vim.keymap.set("x", ">", function()
    local s, e = vim.fn.line("v"), vim.fn.line(".")
    if s > e then
      s, e = e, s
    end
    shift_lines(s, e, 1)
    vim.cmd("normal! gv")
  end, { buffer = buf, desc = "Shift right by block indentation" })
  vim.keymap.set("x", "<", function()
    local s, e = vim.fn.line("v"), vim.fn.line(".")
    if s > e then
      s, e = e, s
    end
    shift_lines(s, e, -1)
    vim.cmd("normal! gv")
  end, { buffer = buf, desc = "Shift left by block indentation" })
  -- `>` / `<` become operators (`>j`, `>ap`, ...) backed by shift_lines
  for _, dir in ipairs({ 1, -1 }) do
    local key = dir > 0 and ">" or "<"
    vim.keymap.set("n", key, function()
      local count = vim.v.count
      vim.o.operatorfunc = dir > 0 and "v:lua.require'config.mdtab'.opfunc_right" or "v:lua.require'config.mdtab'.opfunc_left"
      api.nvim_feedkeys((count > 0 and tostring(count) or "") .. "g@", "in", false)
    end, { buffer = buf, desc = "Shift " .. (dir > 0 and "right" or "left") .. " by block indentation" })
    -- `>` is not a motion, so `>>` needs `_` (the current line) in operator-pending mode
    vim.keymap.set("o", key, function()
      return vim.v.operator == "g@" and "_" or "<Esc>"
    end, { buffer = buf, expr = true })
  end
end

function M.opfunc_right()
  M.shift(1)
end

function M.opfunc_left()
  M.shift(-1)
end

local function attach(buf)
  if not api.nvim_buf_is_valid(buf) or vim.bo[buf].filetype ~= "markdown" then
    return
  end

  if not vim.b[buf].mdtab_saved then
    vim.b[buf].mdtab_saved = {
      ts = buf_option(buf, "tabstop"),
      sts = buf_option(buf, "softtabstop"),
      sw = buf_option(buf, "shiftwidth"),
      et = buf_option(buf, "expandtab"),
    }
  end

  -- tabs are painted by extmarks, so a 1-wide 'tabstop' keeps the layout honest
  local want_ts = M.config.render_tabs and 1 or vim.b[buf].mdtab_saved.ts
  if buf_option(buf, "tabstop") ~= want_ts then
    buf_set(buf, "tabstop", want_ts)
  end

  if not vim.b[buf].mdtab_mapped then
    vim.b[buf].mdtab_mapped = true
    map(buf)
  end

  -- watch every change (including API/plugin edits, which do not fire TextChanged)
  if not vim.b[buf].mdtab_watched then
    vim.b[buf].mdtab_watched = true
    api.nvim_buf_attach(buf, false, {
      on_lines = function(_, _, _, firstline, _, new_lastline)
        schedule_render(buf, firstline, math.max(firstline, new_lastline))
      end,
      on_reload = function()
        schedule_render(buf)
      end,
      on_detach = function()
        pcall(function()
          vim.b[buf].mdtab_watched = false
        end)
      end,
    })
  end

  M.render(buf)
  structure_sig[buf] = sig(blocks(buf))
  probe_pending_languages(buf)
end

--- Forget a buffer that is no longer markdown.
local function detach(buf)
  if not vim.b[buf].mdtab_mapped then
    return
  end
  vim.b[buf].mdtab_mapped = nil
  for _, key in ipairs({ { "i", "<Tab>" }, { "x", ">" }, { "x", "<" }, { "n", ">" }, { "n", "<" }, { "o", ">" }, { "o", "<" } }) do
    pcall(vim.keymap.del, key[1], key[2], { buffer = buf })
  end
  api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  scan_cache[buf] = nil
  local saved = vim.b[buf].mdtab_saved
  vim.b[buf].mdtab_saved = nil
  -- only hand 'tabstop' back if nothing else claimed it
  if saved and buf_option(buf, "tabstop") == 1 then
    buf_set(buf, "tabstop", saved.ts)
  end
end

function M.render(buf)
  render(buf)
end

function M.refresh()
  scan_cache = {}
  settings_cache = {}
  known_cache = {}
  for _, buf in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "markdown" then
      attach(buf)
    end
  end
end

function M.info()
  local buf = api.nvim_get_current_buf()
  local row = api.nvim_win_get_cursor(0)[1]
  local block = block_at(buf, row)
  local spec = spec_at(buf, row)
  local kind = block and ("code block: " .. (block.lang or "<no language>")) or "prose"
  local ft = block and block.lang and (aliases[block.lang] or block.lang) or "-"
  vim.notify(
    ("%s (filetype %s)\nindent: %s, step %d, shift %d, tab width %d"):format(
      kind,
      ft,
      spec.expandtab and "spaces" or "tabs",
      spec.step,
      spec.shift,
      spec.ts
    ),
    vim.log.levels.INFO
  )
end

-- ---------------------------------------------------------------------------
-- setup
-- ---------------------------------------------------------------------------

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "markdown",
    callback = function(args)
      attach(args.buf)
    end,
  })

  api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "*",
    callback = function(args)
      if vim.b[args.buf].mdtab_mapped and vim.bo[args.buf].filetype ~= "markdown" then
        detach(args.buf)
      end
    end,
  })

  -- normal-mode edits, leaving insert mode and entering the window repaint at once
  api.nvim_create_autocmd({ "TextChanged", "InsertLeave", "BufWinEnter" }, {
    group = group,
    callback = function(args)
      if vim.b[args.buf].mdtab_saved then
        pending[args.buf] = nil
        render(args.buf)
        structure_sig[args.buf] = sig(blocks(args.buf))
      end
    end,
  })

  api.nvim_create_autocmd({ "BufUnload", "BufDelete" }, {
    group = group,
    callback = function(args)
      scan_cache[args.buf] = nil
    end,
  })

  api.nvim_create_autocmd({ "BufReadPost", "BufWinEnter" }, {
    group = group,
    callback = function(args)
      if vim.b[args.buf].mdtab_saved then
        attach(args.buf)
      end
    end,
  })

  api.nvim_create_user_command("MdTabInfo", M.info, { desc = "Show Markdown indentation rules at cursor" })
  api.nvim_create_user_command("MdTabRefresh", M.refresh, { desc = "Re-probe indentation settings and re-render tabs" })

  for _, buf in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "markdown" then
      attach(buf)
    end
  end
end

return M
