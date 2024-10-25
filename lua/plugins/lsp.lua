return {
  {
    "folke/neodev.nvim",
    opts = {},
    config = function()
      require("neodev").setup({
        -- add any options here, or leave empty to use the default settings
      })
    end
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      "folke/neodev.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      local lspconfig = require('lspconfig')
      local telescope_builtin = require('telescope.builtin')
      local configs = require('lspconfig.configs')
      local util = require('lspconfig.util')

      -- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- (Optional) Configure lua language server for neovim
      lspconfig.lua_ls.setup({})
      lspconfig.marksman.setup({})

      lspconfig.ols.setup({})
      lspconfig.zls.setup({})
      lspconfig.gleam.setup({})
      lspconfig.ocamllsp.setup({
        cmd = { "ocamllsp" },
        filetypes = { "ocaml", "ocaml.menhir", "ocaml.interface", "ocaml.ocamllex", "reason", "dune" },
        root_dir = lspconfig.util.root_pattern("*.opam", "esy.json", "package.json", ".git", "dune-project",
          "dune-workspace"),
      })

      lspconfig.rust_analyzer.setup({})

      lspconfig.ccls.setup({
        cmd = { "ccls" },
        init_options = {
          cache = {
            directory = ".ccls-cache",
          },
        }
      })

      lspconfig.gopls.setup({
        capabilities = capabilities,
        settings = {
          gopls = {
            staticcheck = true,
            gofumpt = true,
            -- usePlaceholders = true,
            completeFunctionCalls = true,
          },
        },
      })

      configs["protobuf-language-server"] = {
        default_config = {
          cmd = { 'protobuf-language-server' },
          filetypes = { 'proto', 'cpp' },
          root_fir = util.root_pattern('.git'),
          single_file_support = true,
        }
      }

      lspconfig["protobuf-language-server"].setup {}

      vim.keymap.set('n', '<leader>dh', vim.diagnostic.open_float, { desc = '[D]iagnotics [H]over' })
      vim.keymap.set('n', '<leader>de', vim.diagnostic.enable, { desc = '[D]iagnotics [E]nable' })
      vim.keymap.set('n', '<leader>dd', vim.diagnostic.disable, { desc = '[D]iagnotics [D]isable' })

      vim.keymap.set('n', '<leader>r', function()
        vim.lsp.buf.rename(vim.fn.input("Rename symbol: ", vim.fn.expand("<cword>")))
      end, { desc = "[R]ename the symbol" })

      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = "Go to declaration" })
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "Go to definition" })
      vim.keymap.set('n', 'gr', function() telescope_builtin.lsp_references() end, { desc = "List all references" })
      vim.keymap.set('n', 'gi', telescope_builtin.lsp_implementations, { desc = "Go to implementation" })
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "Hover documentation" })
      vim.keymap.set('i', '<c-h>', vim.lsp.buf.signature_help, { desc = "Signature help" })
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Jump to prev [D]iagnostic" })
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Jump to next [D]iagnostic" })

      vim.keymap.set({ 'n', 'v' }, '<leader>a', vim.lsp.buf.code_action, { desc = "Code [A]ctions" })

      vim.keymap.set('n', '<leader>LR', "<cmd>LspRestart<cr>", { desc = "[L]SP [R]estart" })
      vim.keymap.set('n', '<leader>LS', "<cmd>LspStart<cr>", { desc = "[L]SP [S]tart" })
      vim.keymap.set('n', '<leader>LP', "<cmd>LspStop<cr>", { desc = "[L]SP Sto[p]" })
    end
  },
}
