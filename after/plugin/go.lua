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

vim.keymap.set("n", "<leader>TG", function ()
  local file = vim.fn.expand('%')
  if vim.bo.filetype ~= "go" then
    return
  end
  -- "tail -n +3" will remove first 2 lines with "Generated ..."
  vim.cmd("!gotests -all -w " .. file)
end)
