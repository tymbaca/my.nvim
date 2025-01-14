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
      "rachartier/tiny-code-action.nvim",
    },
    config = function()
      local lspconfig = require('lspconfig')
      local telescope_builtin = require('telescope.builtin')
      local configs = require('lspconfig.configs')
      local util = require('lspconfig.util')

      -- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      configs.elm_language_server = {
        default_config = {
          cmd = { 'elm-language-server' },
          -- TODO(ashkan) if we comment this out, it will allow elmls to operate on elm.json. It seems like it could do that, but no other editor allows it right now.
          filetypes = { 'elm' },
          root_dir = function(fname)
            local filetype = vim.api.nvim_buf_get_option(0, 'filetype')
            if filetype == 'elm' or (filetype == 'json' and fname:match 'elm%.json$') then
              return util.root_pattern('elm.json')(fname)
            end
          end,
          init_options = {
            elmReviewDiagnostics = 'off', -- 'off' | 'warning' | 'error'
            skipInstallPackageConfirmation = false,
            disableElmLSDiagnostics = false,
            onlyUpdateDiagnosticsOnSave = false,
          },
          capabilities = {
            offsetEncoding = { 'utf-8', 'utf-16' },
          },
        }
      }

      configs.protobuf_language_server = {
        default_config = {
          cmd = { 'protobuf-language-server' },
          filetypes = { 'proto', 'cpp' },
          root_fir = util.root_pattern('.git'),
          single_file_support = true,
        }
      }


      -- (Optional) Configure lua language server for neovim
      lspconfig.lua_ls.setup({})
      lspconfig.marksman.setup({})

      lspconfig.ols.setup({
        init_options = {
          checker_args = "-strict-style",
          -- collections = {
          --   { name = "shared", path = vim.fn.expand('$HOME/odin-lib') }
          -- },
          enable_snippets = true,
          enable_fake_methods = true,
          enable_inlay_hints = true,
          enable_references = true,
          enable_rename = true,
        },
      })
      lspconfig.zls.setup({})
      lspconfig.gleam.setup({})
      lspconfig.elp.setup({})
      -- lspconfig.elixirls.setup({
      --   cmd = { os.getenv("HOME") .. "/.local/share/nvim/mason/packages/elixir-ls/language_server.sh" },
      -- })
      lspconfig.lexical.setup({
        cmd = { os.getenv("HOME") .. "/.local/share/nvim/mason/packages/lexical/libexec/lexical/bin/start_lexical.sh" },
      })
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

      lspconfig.elm_language_server.setup({})
      lspconfig.protobuf_language_server.setup({})
      -- lspconfig.yamlls.setup({})

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

      vim.keymap.set({ 'n', 'v' }, "<leader>a", require("tiny-code-action").code_action,
        { desc = "Code [A]ctions", noremap = true, silent = true }
      )

      vim.keymap.set('n', '<leader>LR', "<cmd>LspRestart<cr>", { desc = "[L]SP [R]estart" })
      vim.keymap.set('n', '<leader>LS', "<cmd>LspStart<cr>", { desc = "[L]SP [S]tart" })
      vim.keymap.set('n', '<leader>LP', "<cmd>LspStop<cr>", { desc = "[L]SP Sto[p]" })
    end
  },
}
