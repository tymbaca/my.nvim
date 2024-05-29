require("lsp-format").setup {}
require("lspconfig").gopls.setup { on_attach = require("lsp-format").on_attach }

-- Go import organize
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.go',
  callback = function()
    vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
  end
})

vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { "*.json", "*.lua", "*.rs", "*.odin" },
  callback = function()
    vim.lsp.buf.format()
  end
})

local autocmd_group = vim.api.nvim_create_augroup("Custom auto-commands", { clear = true })

-- vim.api.nvim_create_autocmd({ "BufWritePost" }, {
--   pattern = "*.go",
--   desc = "Shorten lines in GO files after saving",
--   callback = function()
--     if string.find(vim.bo.filetype, "_test") then
--       return
--     end

--     local fileName = vim.api.nvim_buf_get_name(0)
--     vim.cmd(":silent !golines -w -m 100 " .. fileName)
--   end,
--   group = autocmd_group,
-- })

-- vim.api.nvim_create_autocmd({ "BufWritePre" }, {
--   pattern = { "*.json", "*.lua", "*.rs", "*.odin" },
--   desc = "Format json on save",
--   callback = function()
--     vim.lsp.buf.format({ async = true })
--   end,
--   group = autocmd_group,
-- })

vim.keymap.set('n', '<leader>i', function()
  vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
end, { desc = '[D]iagnotics [H]over' })

vim.keymap.set('n', '<leader>F', function()
  vim.lsp.buf.format({ async = true })
end, { desc = '[D]iagnotics [H]over' })
