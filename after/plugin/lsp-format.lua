require("lsp-format").setup {}
require("lspconfig").gopls.setup { on_attach = require("lsp-format").on_attach }

-- Go import organize
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = '*.go',
  callback = function()
    vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
  end
})
