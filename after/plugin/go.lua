-- local autocmd_group = vim.api.nvim_create_augroup("Custom auto-commands", { clear = true })

-- vim.api.nvim_create_autocmd({ "BufWritePost" }, {
--     pattern = { "*.go" },
--     desc = "Auto-format GO files after saving",
--     callback = function()
--         local fileName = vim.api.nvim_buf_get_name(0)
--         vim.cmd(":!yamlfmt " .. fileName)
--     end,
--     group = autocmd_group,
-- })

local ts_utils = require'nvim-treesitter.ts_utils'

local function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

local function get_current_function_name() 
  local current_node = ts_utils.get_node_at_cursor()
  if not current_node then
    return ""
  end

  local expr = current_node

  while expr do
      if expr:type() == 'function_declaration' or expr:type() == 'method_declaration' then
          break
      end
      expr = expr:parent()
  end

  if not expr then 
    return "" 
  end
  if expr:type() == 'function_declaration' then
    return ts_utils.get_node_text(expr:child(1))[1]
  else 
    return ts_utils.get_node_text(expr:child(2))[1]
  end
  -- local children = ts_utils.get_named_children(expr)
  -- print(dump(children))
end

-- gotests
vim.keymap.set("n", "<leader>GA", function ()
  local file = vim.fn.expand('%')
  if vim.bo.filetype ~= "go" then
    return
  end
  -- "tail -n +3" will remove first 2 lines with "Generated ..."
  vim.cmd("!gotests -all -w " .. file)
end)

vim.keymap.set("n", "<leader>GT", function ()
  local file = vim.fn.expand('%')
  if vim.bo.filetype ~= "go" then
    return
  end

  vim.cmd("!gotests -only " .. get_current_function_name() .. " -w " .. file)
end)

vim.keymap.set("n", "<leader>Gf", function ()
  print(get_current_function_name())
end)
