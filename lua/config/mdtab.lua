-- Per-region indentation for Markdown buffers.
--
--   * prose (anything outside a fenced code block): <Tab> inserts 2 spaces,
--     > / < shift by 2.
--   * inside a fenced code block: only the *editing* behaviour follows the block's
--     language, using the indentation settings of that filetype (python = 4 spaces,
--     lua/js = 2 spaces, go = real <Tab> characters, ...).
--
-- Rendering stays completely standard: nothing here touches 'tabstop', adds
-- extmarks or otherwise changes how the buffer looks. Tabs are drawn by Neovim with
-- the buffer's own 'tabstop' (4 for markdown in this config).
--
-- Where the per-language settings come from: on first use of a language the real
-- settings are read from a throwaway buffer with that filetype, so ftplugins and
-- your own `au FileType` lines are honoured. Results are cached per session.

local api = vim.api

local M = {}

M.config = {
  -- indentation step used for prose and for code blocks of unknown languages
  prose_width = 2,
  -- probe the real indentation settings of a code block's filetype
  probe = true,
  -- create new lines with the indentation of the code block they land in
  newline_indent = true,
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
local known_cache = {}

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

  local w = math.max(1, M.config.prose_width)
  return {
    expandtab = true,
    ts = buf_option(buf, "tabstop"),
    sts = w,
    sw = w,
    step = w,
    shift = w,
    prose = true,
  }
end

--- <BS>, <C-t> and <C-d> work off 'shiftwidth' / 'softtabstop' / 'expandtab', so
--- these have to follow the region while editing. Otherwise Backspace inside a go
--- block deletes markdown's 2 columns out of a tab instead of removing the tab
--- (a backspace inside the indent deletes back to a 'shiftwidth' boundary).
local last_sync = {}

local function sync_indent_options(buf, row)
  local saved = vim.b[buf].mdtab_saved
  if not saved then
    return
  end
  local spec = spec_at(buf, row or api.nvim_win_get_cursor(0)[1])
  local et, step
  if spec.prose then
    et, step = true, math.max(1, M.config.prose_width)
  else
    et = spec.expandtab
    -- tabs are drawn with the buffer's 'tabstop', so one tab is exactly that wide
    step = spec.expandtab and (spec.step > 0 and spec.step or spec.shift) or buf_option(buf, "tabstop")
  end
  local key = ("%s:%d"):format(et and "et" or "noet", step)
  if last_sync[buf] == key then
    return
  end
  last_sync[buf] = key
  if buf_option(buf, "expandtab") ~= et then
    buf_set(buf, "expandtab", et)
  end
  if buf_option(buf, "softtabstop") ~= step then
    buf_set(buf, "softtabstop", step)
  end
  if buf_option(buf, "shiftwidth") ~= step then
    buf_set(buf, "shiftwidth", step)
  end
end

-- ---------------------------------------------------------------------------
-- indentation helpers
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

--- Re-express a display column in the block's own style.
local function indent_text(spec, col)
  local width = spec.ts > 0 and spec.ts or 8
  if spec.expandtab then
    return (" "):rep(col)
  end
  return ("\t"):rep(math.floor(col / width)) .. (" "):rep(col % width)
end

--- Indent for a line that continues `src_row`.
---@param add_step boolean|nil  indent one level more when the source line opens a block
local function indent_from(buf, src_row, spec, add_step)
  local src = (src_row >= 1 and api.nvim_buf_get_lines(buf, src_row - 1, src_row, false)[1]) or ""
  local width = spec.ts > 0 and spec.ts or 8
  local step = spec.expandtab and (spec.step > 0 and spec.step or width) or width
  local trimmed = src:gsub("%s+$", "")
  local last = trimmed:sub(-1)
  -- ":" opens a block in space-indented languages (python), not in go
  local opens = last == "{" or last == "(" or last == "[" or (spec.expandtab and last == ":")
  local col = display_width(src:match("^[ \t]*") or "", width)
  if add_step and opens then
    col = col + step
  end
  return indent_text(spec, col)
end

-- ---------------------------------------------------------------------------
-- indent operations (> and <)
-- ---------------------------------------------------------------------------

local function shift_lines(start_line, end_line, dir)
  local buf = api.nvim_get_current_buf()
  if start_line < 1 or vim.bo[buf].filetype ~= "markdown" then
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

  if not spec.expandtab then
    -- <C-v><Tab>: a literal tab, regardless of 'expandtab' / 'softtabstop'
    api.nvim_feedkeys(api.nvim_replace_termcodes("<C-v><Tab>", true, false, true), "in", false)
    return
  end

  local width = spec.ts > 0 and spec.ts or 8
  local step = spec.step > 0 and spec.step or width
  local cur = display_width(api.nvim_get_current_line():sub(1, col), width)
  local n = step - cur % step
  if n <= 0 then
    n = step
  end
  api.nvim_feedkeys((" "):rep(n), "in", false)
end

-- ---------------------------------------------------------------------------
-- newline indentation
-- ---------------------------------------------------------------------------

--- Create a new line the way its code block wants it: tabs for go, 4 spaces for
--- python, one level deeper after an opening bracket. Prose keeps Vim's own
--- behaviour by feeding the native key.
---@param dir integer 1 = below the cursor (o / <CR>), -1 = above (O)
local function new_line(dir)
  local buf = api.nvim_get_current_buf()
  if vim.bo[buf].filetype ~= "markdown" or not vim.bo[buf].modifiable then
    return false
  end

  local row, col = unpack(api.nvim_win_get_cursor(0))
  local spec = spec_at(buf, row)
  if spec.prose then
    return false
  end

  local insert_mode = vim.fn.mode():sub(1, 1) == "i"
  local at_eol = col >= #api.nvim_get_current_line()
  local indent
  if dir < 0 then
    indent = indent_from(buf, row, spec, true)
  elseif insert_mode then
    indent = indent_from(buf, row, spec, at_eol)
  else
    indent = indent_from(buf, row, spec, true)
  end

  if insert_mode and dir > 0 then
    -- split the current line at the cursor
    local line = api.nvim_get_current_line()
    api.nvim_buf_set_lines(buf, row - 1, row, false, { line:sub(1, col), indent .. line:sub(col + 1) })
    api.nvim_win_set_cursor(0, { row + 1, #indent })
  elseif dir > 0 then
    local count = math.max(1, vim.v.count)
    local lines = {}
    for _ = 1, count do
      lines[#lines + 1] = indent
    end
    api.nvim_buf_set_lines(buf, row, row, false, lines)
    api.nvim_win_set_cursor(0, { row + count, #indent })
    vim.cmd("startinsert")
  else
    api.nvim_buf_set_lines(buf, row - 1, row - 1, false, { indent })
    api.nvim_win_set_cursor(0, { row, #indent })
    vim.cmd("startinsert")
  end
  return true
end

-- ---------------------------------------------------------------------------
-- attach
-- ---------------------------------------------------------------------------

local group = api.nvim_create_augroup("mdtab", { clear = true })

--- Probe the languages used by this buffer up front, so the first <Tab> in a block
--- does not have to pay for it.
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

  -- new lines get the indentation of the code block they are created in
  if M.config.newline_indent then
    vim.keymap.set("i", "<CR>", function()
      if vim.fn.pumvisible() == 1 then
        api.nvim_feedkeys(api.nvim_replace_termcodes("<C-y>", true, false, true), "m", false)
        return
      end
      if not new_line(1) then
        api.nvim_feedkeys(api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)
      end
    end, { buffer = buf, desc = "New line indented like its code block" })
    for _, key in ipairs({ "o", "O" }) do
      vim.keymap.set("n", key, function()
        if not new_line(key == "o" and 1 or -1) then
          api.nvim_feedkeys(key, "n", false)
        end
      end, { buffer = buf, desc = "New line indented like its code block" })
    end
  end

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

  if not vim.b[buf].mdtab_mapped then
    vim.b[buf].mdtab_mapped = true
    vim.b[buf].mdtab_saved = {
      et = buf_option(buf, "expandtab"),
      sts = buf_option(buf, "softtabstop"),
      sw = buf_option(buf, "shiftwidth"),
    }
    map(buf)
    probe_pending_languages(buf)
  end
  sync_indent_options(buf, api.nvim_win_get_cursor(0)[1])
end

--- Forget a buffer that is no longer markdown.
local function detach(buf)
  if not vim.b[buf].mdtab_mapped then
    return
  end
  vim.b[buf].mdtab_mapped = nil
  -- the new filetype's own settings win; nothing to restore
  last_sync[buf] = nil
  vim.b[buf].mdtab_saved = nil
  for _, key in ipairs({
    { "i", "<Tab>" },
    { "x", ">" },
    { "x", "<" },
    { "n", ">" },
    { "n", "<" },
    { "o", ">" },
    { "o", "<" },
    { "n", "o" },
    { "n", "O" },
    { "i", "<CR>" },
  }) do
    pcall(vim.keymap.del, key[1], key[2], { buffer = buf })
  end
  scan_cache[buf] = nil
end

function M.refresh()
  scan_cache = {}
  settings_cache = {}
  known_cache = {}
  for _, buf in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "markdown" then
      probe_pending_languages(buf)
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

  api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "InsertEnter" }, {
    group = group,
    callback = function(args)
      if vim.b[args.buf].mdtab_mapped then
        sync_indent_options(args.buf, api.nvim_win_get_cursor(0)[1])
      end
    end,
  })

  api.nvim_create_autocmd({ "BufUnload", "BufDelete" }, {
    group = group,
    callback = function(args)
      scan_cache[args.buf] = nil
    end,
  })

  api.nvim_create_user_command("MdTabInfo", M.info, { desc = "Show Markdown indentation rules at cursor" })
  api.nvim_create_user_command("MdTabRefresh", M.refresh, { desc = "Re-probe indentation settings" })

  for _, buf in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "markdown" then
      attach(buf)
    end
  end
end

return M
