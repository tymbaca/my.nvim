return {
  "lukas-reineke/lsp-format.nvim",
  dependencies = {
    'neovim/nvim-lspconfig',
  },
  config = function()
    require("lsp-format").setup {}

    -- this was the problem with correect lsp config
    -- require("lspconfig").gopls.setup { on_attach = require("lsp-format").on_attach }


    local function golines() -- TODO: move to go.lua
      if string.find(vim.bo.filetype, "_test") then
        return
      end

      local fileName = vim.api.nvim_buf_get_name(0)
      vim.cmd(":silent !golines -w -m 120 " .. fileName)
    end
    vim.keymap.set("n", "<leader>GL", golines)


    local function goimports()
      if string.find(vim.bo.filetype, "_test") then
        return
      end

      local fileName = vim.api.nvim_buf_get_name(0)
      vim.cmd(":silent !goimports -w " .. fileName)
    end
    vim.keymap.set("n", "<leader>GI", goimports)

    -- Go import organize
    vim.api.nvim_create_autocmd('BufWritePost', {
      pattern = '*.go',
      callback = function()
        -- golines()
        goimports()
        vim.lsp.buf.format()
        -- vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
      end
    })

    vim.api.nvim_create_autocmd('BufWritePre', {
      pattern = { "*.json", "*.lua", "*.rs", "*.ml" }, -- "*.odin", "*.gleam"
      -- pattern = { "*.json", "*.lua", "*.rs" },
      callback = function()
        vim.lsp.buf.format()
      end
    })

    vim.api.nvim_create_autocmd('BufWritePre', {
      pattern = { "*.ex", "*.exs" },
      callback = function()
        -- vim.cmd [[silent exec "!mix format"]]
        vim.lsp.buf.format({ async = true })
      end
    })

    local autocmd_group = vim.api.nvim_create_augroup("Custom auto-commands", { clear = true })

    -- vim.api.nvim_create_autocmd({ "BufWritePre" }, {
    --   pattern = "*.go",
    --   desc = "Shorten lines in GO files after saving",
    --   callback = golines,
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
  end
}
