local ls = require("luasnip")

local snippet_from_nodes = ls.sn

local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require("luasnip.util.events")
local ai = require("luasnip.nodes.absolute_indexer")
local extras = require("luasnip.extras")
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local fmt = require("luasnip.extras.fmt").fmt
local fmta = require("luasnip.extras.fmt").fmta
local conds = require("luasnip.extras.expand_conditions")
local postfix = require("luasnip.extras.postfix").postfix
local types = require("luasnip.util.types")
local parse = require("luasnip.util.parser").parse_snippet
local ms = ls.multi_snippet
local k = require("luasnip.nodes.key_indexer").new_key

ls.config.set_config {
  history = true
}


local ts_locals = require "nvim-treesitter.locals"
local ts_utils = require "nvim-treesitter.ts_utils"

local get_node_text = vim.treesitter.get_node_text

local transforms = {
  int = function(_, _)
    return t "0"
  end,

  bool = function(_, _)
    return t "false"
  end,

  string = function(_, _)
    return t [[""]]
  end,

  error = function(_, info)
    if info then
      info.index = info.index + 1

      return c(info.index, {
        t(info.err_name),
        -- fmt('errors.Wrap("{message}")', { message = i(6, "message") }),
        t(string.format('errors.Wrap(%s, "%s")', info.err_name, info.func_name)),
      })
    else
      return t "err"
    end
  end,

  -- Types with a "*" mean they are pointers, so return nil
  [function(text)
    return string.find(text, "*", 1, true) ~= nil
  end] = function(_, _)
    return t "nil"
  end,
}

local transform = function(text, info)
  local condition_matches = function(condition, ...)
    if type(condition) == "string" then
      return condition == text
    else
      return condition(...)
    end
  end

  for condition, result in pairs(transforms) do
    if condition_matches(condition, text, info) then
      return result(text, info)
    end
  end

  return t(text)
end

local handlers = {
  parameter_list = function(node, info)
    local result = {}

    local count = node:named_child_count()
    for idx = 0, count - 1 do
      local matching_node = node:named_child(idx)
      local type_node = matching_node:field("type")[1]
      table.insert(result, transform(get_node_text(type_node, 0), info))
      if idx ~= count - 1 then
        table.insert(result, t { ", " })
      end
    end

    return result
  end,

  type_identifier = function(node, info)
    local text = get_node_text(node, 0)
    return { transform(text, info) }
  end,
}

local function_node_types = {
  function_declaration = true,
  method_declaration = true,
  func_literal = true,
}

local function go_result_type(info)
  local cursor_node = ts_utils.get_node_at_cursor()
  local scope = ts_locals.get_scope_tree(cursor_node, 0)

  local function_node
  for _, v in ipairs(scope) do
    if function_node_types[v:type()] then
      function_node = v
      break
    end
  end

  if not function_node then
    print "Not inside of a function"
    return t ""
  end

  local query = vim.treesitter.query.parse(
    "go",
    [[
      [
        (method_declaration result: (_) @id)
        (function_declaration result: (_) @id)
        (func_literal result: (_) @id)
      ]
    ]]
  )
  for _, node in query:iter_captures(function_node, 0) do
    if handlers[node:type()] then
      return handlers[node:type()](node, info)
    end
  end
end

local go_ret_vals = function(args)
  return snippet_from_nodes(
    nil,
    go_result_type {
      index = 0,
      err_name = args[1][1],
      func_name = args[2][1],
    }
  )
end

local go_ret_vals_now_func = function(args)
  return snippet_from_nodes(
    nil,
    go_result_type {
      index = 0,
      err_name = args[1][1],
      func_name = "func()",
    }
  )
end

-------------------------------------------------------------------------------

ls.add_snippets("go", {
  s("trig", c(1, {
    t("Ugh boring, a text node"),
    i(nil, "At least I can edit something now..."),
    f(function(args) return "Still only counts as text!!" end, {})
  })),

  s("v", fmta("<val>, <err> := <fn>\nif <err_rep> != nil {\n\treturn <ret>\n}\n<final>", {
    val = i(1, "val"),
    err = i(2, "err"),
    fn = i(3, "fn"),
    ret = d(4, go_ret_vals, { 2, 3 }),
    err_rep = rep(2),
    final = i(0)
  })),

  s("i", fmta("if <err> != nil {\n\treturn <ret>\n}\n<final>", {
    err = i(1, "err"),
    ret = d(2, go_ret_vals_now_func, { 1 }),
    final = i(0)
  })),

  s("ie", fmta("if err != nil {\n\t<ret>\n}\n<final>", {
    ret = i(1),
    final = i(0)
  })),

  s("iee", fmta("if err != nil {\n\t<ret>\n}\n<final>", {
    ret = i(1),
    final = i(0)
  }))
})


-- ----------------------------------------------------------------------------


vim.keymap.set({ "i", "s", "n"}, "<c-k>", function ()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end)

vim.keymap.set({ "i", "s", "n"}, "<c-j>", function ()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end)

vim.keymap.set({ "i", "s", "n"}, "<c-l>", function ()
  if ls.choice_active() then
    return ls.change_choice(1)
  end
end)
vim.keymap.set({ "i", "s", "n"}, "<c-s-l>", function ()
  if ls.choice_active() then
    return ls.change_choice(-1)
  end
end)
-- vim.api.nvim_set_keymap("i", "<C-l>", "<Plug>luasnip-next-choice", {})
-- vim.api.nvim_set_keymap("i", "<C-S-l>", "<Plug>luasnip-prev-choice", {})

----------------


