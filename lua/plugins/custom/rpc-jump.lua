-- Jump between a .proto `rpc` declaration and its hand-written Go implementation.
--
--   proto buffer, `gi` / `<leader>gp` -> Go `func (recv) RpcName(` of the grpc server
--   go buffer,    `gi`                -> picker: grpc interface method(s) + proto rpc
--   go buffer,    `<leader>gp`        -> `rpc RpcName(...)` in the .proto
--
-- Resolution is ripgrep based (no LSP can cross proto -> Go). Candidates are
-- filtered by the rpc's own request/response message types, so unrelated
-- same-named methods on services/repositories are dropped instead of listed.
-- Generated stubs, mocks and tests are skipped on the first pass and included
-- only if nothing else matches. With several exact matches a telescope picker
-- opens; a single match jumps straight there.

local M = {}

local GO_GLOBS = {
  '*.go',
  '!**/*_test.go',
  '!**/*_mock*',
  '!**/*.pb.go',
  '!**/*_grpc.pb.go',
  '!**/*.pb.gw.go',
  '!**/vendor/**',
}

local GO_GLOBS_ALL = { '*.go', '!**/vendor/**' }

local PROTO_GLOBS = { '*.proto', '!**/vendor/**' }

local GRPC_GLOBS = { '**/*_grpc.pb.go', '!**/vendor/**' }

--- Nearest ancestor holding .git / go.work / go.mod.
-- vim.fs.root with a marker *list* resolves by marker order, not by proximity,
-- so an outer .git would win over a nearer go.mod. Resolve per marker instead.
local function repo_root()
  local name = vim.api.nvim_buf_get_name(0)
  local start = name ~= '' and vim.fs.dirname(name) or vim.fn.getcwd()
  local best
  for _, marker in ipairs({ '.git', 'go.work', 'go.mod' }) do
    local found = vim.fs.root(start, marker)
    if found and (not best or #found > #best) then
      best = found
    end
  end
  return best
end

--- Search roots: repo root first, then the working directory when it differs.
local function search_roots()
  local roots, seen = {}, {}
  for _, root in ipairs({ repo_root(), vim.fn.getcwd() }) do
    if root and root ~= '' and not seen[root] then
      seen[root] = true
      roots[#roots + 1] = root
    end
  end
  return roots
end

--- Run ripgrep from the repo root and return { path, lnum, text } entries.
local function rg(root, pattern, globs)
  local cmd = { 'rg', '--no-heading', '--line-number', '--color', 'never', '--no-messages', '--regexp', pattern }
  for _, glob in ipairs(globs) do
    vim.list_extend(cmd, { '--glob', glob })
  end
  cmd[#cmd + 1] = '.'

  local ok, res = pcall(function()
    return vim.system(cmd, { cwd = root, text = true }):wait()
  end)
  -- rg exits 1 on "no matches", anything else is a real failure
  if not ok or type(res) ~= 'table' or (res.code ~= 0 and res.code ~= 1) then
    return {}
  end

  local entries, seen = {}, {}
  for line in (res.stdout or ''):gmatch('[^\r\n]+') do
    local path, lnum, text = line:match('^(.-):(%d+):(.*)$')
    if path then
      local abs = vim.fs.normalize(root .. '/' .. path)
      local key = abs .. ':' .. lnum
      if not seen[key] then
        seen[key] = true
        entries[#entries + 1] = { path = abs, lnum = tonumber(lnum), text = text }
      end
    end
  end
  return entries
end

--- First non-empty result across the search roots.
local function search(pattern, globs)
  for _, root in ipairs(search_roots()) do
    local found = rg(root, pattern, globs)
    if #found > 0 then
      return found
    end
  end
  return {}
end

local function short_type(t)
  return t and t:match('([%w_]+)$')
end

--- Full `func (recv) Name(args) returns` text of a hit, read from disk.
-- Signatures may span several lines, so the matched line alone is not enough to
-- decide whether it takes the rpc's request/response message types.
local function signature_of(entry, name)
  local ok, lines = pcall(vim.fn.readfile, entry.path)
  if not ok or type(lines) ~= 'table' then
    return nil
  end
  local text = table.concat(lines, '\n')

  local s, e, args = text:find('func%s+%b()%s*' .. vim.pesc(name) .. '%s*(%b())')
  if not s then
    s, e, args = text:find('func%s+' .. vim.pesc(name) .. '%s*(%b())')
  end
  if not s then
    return nil
  end

  local after = text:sub(e + 1)
  local returns = after:match('^%s*(%b())') or after:match('^%s*([^\n{]*)') or ''
  return { args = args or '', returns = returns }
end

local function name_col(entry, name)
  if not name then
    return 1
  end
  return entry.text:find(name, 1, true) or 1
end

--- The interface type a `*_grpc.pb.go` method line belongs to (e.g. ...Server).
local iface_cache = {}

local function enclosing_interface(path, lnum)
  local lines = iface_cache[path]
  if not lines then
    local ok, read = pcall(vim.fn.readfile, path)
    lines = ok and type(read) == 'table' and read or {}
    iface_cache[path] = lines
  end
  for r = lnum - 1, math.max(1, lnum - 80), -1 do
    local name = lines[r] and lines[r]:match('^type%s+([%w_]+)%s+interface')
    if name then
      return name
    end
  end
  return nil
end

--- Order of the Go -> proto chooser: proto rpc first (the usual destination),
-- then the server contract, then the client contract.
local function entry_rank(entry)
  if entry.kind == 'proto' then
    return 1
  end
  if entry.kind == 'grpc' then
    if entry.iface and entry.iface:match('Server$') then
      return 2
    end
    if entry.iface and entry.iface:match('Client$') then
      return 3
    end
    return 4
  end
  return 5
end

local function jump_to(entry, name)
  vim.cmd('edit ' .. vim.fn.fnameescape(entry.path))
  local col = name_col(entry, name)
  vim.api.nvim_win_set_cursor(0, { entry.lnum, math.max(col - 1, 0) })
  vim.cmd('normal! zz')
  return true
end

--- Keeps our entry order: telescope's generic sorter gives every entry the same
-- score and its unstable sort then scrambles the list (server/client swap).
-- Lower score wins, so the list index doubles as the score. Typing still filters
-- by plain substring on the display line.
function M.sorter()
  return require('telescope.sorters').Sorter:new({
    -- telescope calls scoring_function(self, prompt, ordinal, entry, ...)
    scoring_function = function(_, prompt, _, entry)
      local display = entry and entry.display
      if prompt ~= '' and display and not display:lower():find(prompt:lower(), 1, true) then
        return -1 -- filtered out
      end
      return entry and entry.order or 0
    end,
  })
end

--- Line-aware previewer: vim_buffer_vimgrep scrolls to entry.lnum and highlights
-- it. file_previewer is vim_buffer_cat, which always shows line 1.
function M.previewer()
  return require('telescope.config').values.grep_previewer({})
end

local function open(entries, title, name)
  if #entries == 0 then
    return false
  end
  if #entries == 1 then
    return jump_to(entries[1], name)
  end

  local ok, pickers = pcall(require, 'telescope.pickers')
  if not ok then
    return jump_to(entries[1], name)
  end
  local conf = require('telescope.config').values
  local finders = require('telescope.finders')

  -- remember insertion order, ordered_sorter scores by it
  for i, entry in ipairs(entries) do
    entry.order = i
  end

  pickers
    .new({}, {
      prompt_title = title,
      finder = finders.new_table({
        results = entries,
        entry_maker = function(entry)
          local rel = vim.fn.fnamemodify(entry.path, ':.')
          local col = name_col(entry, name)
          local tag = ''
          if entry.kind == 'grpc' then
            tag = ('[grpc %s] '):format(entry.iface or 'interface')
          elseif entry.kind == 'proto' then
            tag = '[proto rpc] '
          end
          return {
            value = entry,
            display = string.format('%s%s:%d:%d  %s', tag, rel, entry.lnum, col, vim.trim(entry.text)),
            ordinal = rel,
            path = entry.path,
            filename = entry.path,
            kind = entry.kind,
            iface = entry.iface,
            order = entry.order,
            lnum = entry.lnum,
            col = col,
            -- both ends are needed for telescope to highlight the match
            colend = col + #(name or '') - 1,
          }
        end,
      }),
      sorter = M.sorter(),
      previewer = M.previewer(),
    })
    :find()
  return true
end

--- The `rpc` declaration under the cursor: name, request and response types.
function M.rpc_declaration()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local start_row
  if vim.api.nvim_get_current_line():find('%f[%w_]rpc%f[%W]') then
    start_row = row
  else
    for r = row - 1, math.max(1, row - 8), -1 do
      local line = vim.api.nvim_buf_get_lines(0, r - 1, r, false)[1] or ''
      if line:find('%f[%w_]rpc%f[%W]') then
        start_row = r
        break
      end
    end
  end
  if not start_row then
    return nil
  end

  -- collect the statement across lines, it may wrap before `returns (...)`
  local parts = {}
  local last = math.min(start_row + 12, vim.api.nvim_buf_line_count(0))
  for r = start_row, last do
    parts[#parts + 1] = vim.api.nvim_buf_get_lines(0, r - 1, r, false)[1] or ''
    local joined = table.concat(parts, ' ')
    if joined:find(';', 1, true) or joined:find('{', 1, true) then
      break
    end
  end
  local stmt = table.concat(parts, ' ')

  local name = stmt:match('%f[%w_]rpc%s+([%a_][%w_]*)')
  if not name then
    return nil
  end

  local request = stmt:match('rpc%s+[%w_]+%s*%(%s*stream%s+([%w_%.]+)')
    or stmt:match('rpc%s+[%w_]+%s*%(%s*([%w_%.]+)')
  local response = stmt:match('returns%s*%(%s*stream%s+([%w_%.]+)')
    or stmt:match('returns%s*%(%s*([%w_%.]+)')

  return {
    name = name,
    request = short_type(request),
    response = short_type(response),
    statement = stmt,
  }
end

--- `rpc Name(` on the cursor line, or on the head of a multi-line declaration above it.
function M.rpc_at_cursor()
  local decl = M.rpc_declaration()
  return decl and decl.name
end

--- `func (recv) Name(` on the cursor line.
function M.method_at_cursor()
  return vim.api.nvim_get_current_line():match('^%s*func%s+%b()%s*([%a_][%w_]*)')
end

--- All `func (recv) Name(` implementations in Go sources.
-- With `types` ({ request = ..., response = ... }) candidates are narrowed to
-- signatures taking the rpc's request message and returning its response
-- message. Returns the matches plus the mode used: 'exact', 'relaxed' or 'name'.
function M.find_go_impls(name, types)
  if not name or name == '' then
    return {}, 'name'
  end

  -- optional receiver keeps plain `func Name(` working too
  local pattern = 'func[ \t]+(\\([^)]*\\)[ \t]+)?' .. name .. '[ \t]*\\('
  local all = search(pattern, GO_GLOBS)
  if #all == 0 then
    all = search(pattern, GO_GLOBS_ALL)
  end

  local request = types and types.request or nil
  local response = types and types.response or nil
  if #all == 0 or (not request and not response) then
    return all, 'name'
  end

  local exact, relaxed = {}, {}
  for _, entry in ipairs(all) do
    local sig = signature_of(entry, name)
    if sig then
      local args, returns = sig.args or '', sig.returns or ''
      local req_ok = (not request or request == '') or args:find(request, 1, true) ~= nil
      local resp_ok = (not response or response == '') or returns:find(response, 1, true) ~= nil
      if req_ok and resp_ok then
        exact[#exact + 1] = entry
      elseif req_ok or resp_ok then
        relaxed[#relaxed + 1] = entry
      end
    end
  end

  if #exact > 0 then
    return exact, 'exact'
  end
  if #relaxed > 0 then
    return relaxed, 'relaxed'
  end
  return all, 'name'
end

--- The generated grpc server interface method, used when no impl exists yet.
function M.find_grpc_contract(name)
  local found = search('^[ \t]*' .. name .. '[ \t]*\\(', GRPC_GLOBS)
  if #found == 0 then
    found = search(name .. '[ \t]*\\(', GRPC_GLOBS)
  end
  return found
end

--- All `rpc Name(` declarations in .proto files.
function M.find_proto_rpcs(name)
  if not name or name == '' then
    return {}
  end
  return search('^[ \t]*rpc[ \t]+' .. name .. '[ \t]*\\(', PROTO_GLOBS)
end

--- The grpc interface method(s) a Go method satisfies, plus the proto rpc.
-- Ordered: server contract, proto rpc, client contract, anything else.
function M.go_contract_entries(name)
  iface_cache = {}
  local entries = {}
  for _, entry in ipairs(M.find_grpc_contract(name)) do
    entry.kind = 'grpc'
    entry.iface = enclosing_interface(entry.path, entry.lnum)
    entries[#entries + 1] = entry
  end
  for _, entry in ipairs(M.find_proto_rpcs(name)) do
    entry.kind = 'proto'
    entries[#entries + 1] = entry
  end
  table.sort(entries, function(a, b)
    return entry_rank(a) < entry_rank(b)
  end)
  return entries
end

--- Go implementation -> chooser with its grpc interface method(s) and proto rpc.
-- Returns true when it handled the jump; false means "not a grpc method, let the
-- caller fall back to LSP implementations".
function M.goto_go_contracts()
  local name = M.method_at_cursor()
  if not name then
    return false
  end
  local entries = M.go_contract_entries(name)
  if #entries == 0 then
    return false
  end
  open(entries, ('%s: grpc interface + proto rpc'):format(name), name)
  return true
end

--- proto -> Go implementation of the grpc server method.
function M.goto_go_impl()
  local decl = M.rpc_declaration()
  if not decl then
    vim.notify('rpc-jump: no `rpc` declaration under cursor', vim.log.levels.WARN)
    return
  end

  local impls, mode = M.find_go_impls(decl.name, { request = decl.request, response = decl.response })
  if #impls > 0 and mode == 'exact' then
    return open(impls, ('Go implementation of rpc %s'):format(decl.name), decl.name)
  end

  local contract = M.find_grpc_contract(decl.name)
  if #contract > 0 then
    return open(contract, ('grpc contract for %s (no matching Go impl)'):format(decl.name), decl.name)
  end

  if #impls > 0 then
    return open(impls, ('%s: name matches only, signature differs'):format(decl.name), decl.name)
  end

  vim.notify(
    ('rpc-jump: no Go implementation or grpc contract for %s'):format(decl.name),
    vim.log.levels.WARN
  )
end

--- Go receiver method -> proto rpc declaration.
function M.goto_proto_rpc()
  local name = M.method_at_cursor()
  if not name then
    vim.notify('rpc-jump: no `func (recv) Name(` under cursor', vim.log.levels.WARN)
    return
  end
  local decls = M.find_proto_rpcs(name)
  if #decls == 0 then
    vim.notify(('rpc-jump: no `rpc %s` found in any .proto'):format(name), vim.log.levels.WARN)
    return
  end
  return open(decls, ('proto rpc %s'):format(name), name)
end

--- Dispatcher for a single bidirectional key.
function M.jump()
  local ft = vim.bo.filetype
  local ext = vim.fn.expand('%:e')
  if ft == 'proto' or (ft == '' and ext == 'proto') then
    return M.goto_go_impl()
  elseif ft == 'go' or (ft == '' and ext == 'go') then
    return M.goto_proto_rpc()
  end
  vim.notify('rpc-jump: only .proto and .go buffers', vim.log.levels.WARN)
end

return M
