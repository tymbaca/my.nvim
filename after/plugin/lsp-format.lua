require("lsp-format").setup {}
require("lspconfig").gopls.setup { on_attach = require("lsp-format").on_attach }

-- Go import organize
-- vim.api.nvim_create_autocmd('BufWritePre', {
--   pattern = '*.go',
--   callback = function()
--     vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
--   end
-- })

local autocmd_group = vim.api.nvim_create_augroup("Custom auto-commands", { clear = true })

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    pattern = "*.go",
    desc = "Shorten lines in GO files after saving",
    callback = function()
        local fileName = vim.api.nvim_buf_get_name(0)
        vim.cmd(":silent !golines -w -m 140 " .. fileName)
    end,
    group = autocmd_group,
})

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    pattern = "*.rs",
    desc = "Format rust on save",
    callback = function()
      vim.lsp.buf.format({ async = true })
    end,
    group = autocmd_group,
})
