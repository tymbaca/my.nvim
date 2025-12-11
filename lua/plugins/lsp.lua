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
      local telescope_builtin = require('telescope.builtin')
      -- local configs = require('vim.lsp.config.configs')
      -- local util = require('vim.lsp.config.util')

      -- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- configs.haskell_language_server = {
      --   default_config = {
      --     cmd = { 'haskell-language-server-wrapper --lsp' },
      --     filetypes = { 'haskell', 'lhaskell' },
      --     root_fir = util.root_pattern('*.cabal'),
      --     single_file_support = true,
      --   }
      -- }

      -- configs.elm_language_server = {
      --   default_config = {
      --     cmd = { 'elm-language-server' },
      --     -- TODO(ashkan) if we comment this out, it will allow elmls to operate on elm.json. It seems like it could do that, but no other editor allows it right now.
      --     filetypes = { 'elm' },
      --     root_dir = function(fname)
      --       local filetype = vim.api.nvim_buf_get_option(0, 'filetype')
      --       if filetype == 'elm' or (filetype == 'json' and fname:match 'elm%.json$') then
      --         return util.root_pattern('elm.json')(fname)
      --       end
      --     end,
      --     init_options = {
      --       elmReviewDiagnostics = 'off', -- 'off' | 'warning' | 'error'
      --       skipInstallPackageConfirmation = false,
      --       disableElmLSDiagnostics = false,
      --       onlyUpdateDiagnosticsOnSave = false,
      --     },
      --     capabilities = {
      --       offsetEncoding = { 'utf-8', 'utf-16' },
      --     },
      --   }
      -- }


      -- TODO: remove?
      -- configs.protobuf_language_server = {
      --   default_config = {
      --     cmd = { 'protobuf-language-server' },
      --     filetypes = { 'proto' },
      --     root_fir = util.root_pattern('.git'),
      --     single_file_support = true,
      --   }
      -- }

      -- configs.typescript_language_server = {
      --   default_config = {
      --     cmd = { 'typescript-language-server', '--stdio' },
      --     filetypes = { 'javascript', 'typescript' },
      --     root_fir = util.root_pattern('.git'),
      --     single_file_support = true,
      --   }
      -- }

      -- (Optional) Configure lua language server for neovim
      -- vim.lsp.config.haskell_language_server.setup({})
      vim.lsp.config("hls", {})
      vim.lsp.config("lua_ls", {})
      vim.lsp.config("marksman", {})
      vim.lsp.config("glsl_analyzer", {})
      vim.lsp.config("tinymist", {
        -- offset_encoding = "utf-8",
        settings = {
          formatterMode = "typstyle",
          exportPdf = "onType",
          semanticTokens = "disable"
        }
      })

      vim.lsp.config("ols", {
        init_options = {
          checker_args = "-strict-style",
          collections = {
            { name = "src", path = vim.fn.expand('$PWD/src') }
          },
          enable_snippets = true,
          enable_procedure_snippet = true,
          enable_fake_methods = true,
          enable_inlay_hints = true,
          enable_references = true,
          enable_rename = true,
        },
      })


      -- vim.lsp.config.typescript_language_server.setup {}

      -- require('java').setup()
      -- vim.lsp.config.jdtls.setup({})

      -- don't show parse errors in a separate window
      vim.g.zig_fmt_parse_errors = 0
      vim.lsp.config("zls", {
        -- Server-specific settings. See `:help vim.lsp.config-setup`

        -- There are two ways to set config options:
        --   - edit your `zls.json` that applies to any editor that uses ZLS
        --   - set in-editor config options with the `settings` field below.
        --
        -- Further information on how to configure ZLS:
        -- https://zigtools.org/zls/configure/
        settings = {
          zls = {
            -- Whether to enable build-on-save diagnostics
            --
            -- Further information about build-on save:
            -- https://zigtools.org/zls/guides/build-on-save/
            enable_build_on_save = true,
          }
        }
      })

      vim.lsp.config("gleam", {})
      vim.lsp.config("elp", {})
      -- vim.lsp.config.elixirls.setup({
      --   cmd = { os.getenv("HOME") .. "/.local/share/nvim/mason/packages/elixir-ls/language_server.sh" },
      -- })
      vim.lsp.config("lexical", {
        cmd = { os.getenv("HOME") .. "/.local/share/nvim/mason/packages/lexical/libexec/lexical/bin/start_lexical.sh" },
      })
      vim.lsp.config("ocamllsp", {
        cmd = { "ocamllsp" },
        filetypes = { "ocaml", "ocaml.menhir", "ocaml.interface", "ocaml.ocamllex", "reason", "dune" },
        root_markers = { "*.opam", "esy.json", "package.json", ".git", "dune-project", "dune-workspace" },
      })

      vim.lsp.config("rust_analyzer", {})

      vim.lsp.config("ccls", {
        cmd = { "ccls" },
        init_options = {
          cache = {
            directory = ".ccls-cache",
          },
        }
      })

      vim.lsp.config("gopls", {
        capabilities = capabilities,
        filetypes = { "go", "gomod", "gosum", "template" },
        settings = {
          gopls = {
            ["local"] = "gitlab-internal.wildberries.ru",
            staticcheck = true,
            gofumpt = true,
            -- usePlaceholders = true,
            completeFunctionCalls = true,
            templateExtensions = { "go.tmpl" },
            experimentalPostfixCompletions = true,
            hints = {
              ignoredError = true,
              parameterNames = true,
            },
            codelenses = {
              generate = true,
              test = true,
            },
          },
        },
      })

      vim.lsp.config("elm_language_server", {})
      vim.lsp.config("protols", {})
      vim.lsp.config("yamlls", {})
      vim.lsp.config("svelte", {})

      vim.lsp.enable({
        "gopls",
        "protols",
        "ols",
        "lua_ls",
        "svelte",
        "yamlls",
      })

      vim.keymap.set('n', '<leader>dh', vim.diagnostic.open_float, { desc = '[D]iagnotics [H]over' })
      vim.keymap.set('n', '<leader>de', vim.diagnostic.enable, { desc = '[D]iagnotics [E]nable' })
      vim.keymap.set('n', '<leader>dd', vim.diagnostic.disable, { desc = '[D]iagnotics [D]isable' })

      vim.keymap.set('n', '<leader>r', function()
        vim.lsp.buf.rename(vim.fn.input("Rename symbol: ", vim.fn.expand("<cword>")))
      end, { desc = "[R]ename the symbol" })

      vim.keymap.set('n', 'gd', telescope_builtin.lsp_definitions, { desc = "Go to definition" })
      vim.keymap.set('n', 'gT', telescope_builtin.lsp_type_definitions, { desc = "Go to type definition" })
      vim.keymap.set('n', 'gr', telescope_builtin.lsp_references, { desc = "List all references" })
      vim.keymap.set('n', 'gi', telescope_builtin.lsp_implementations, { desc = "Go to implementation" })
      vim.keymap.set('n', 'gm', function()
        local gtm = require("plugins.custom.go-to-methods")
        telescope_builtin.lsp_references({ default_text = gtm.get_method_search_query(vim.bo.filetype) })
      end, { desc = "Go to implementation" })
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "Hover documentation" })
      vim.keymap.set('i', '<c-h>', vim.lsp.buf.signature_help, { desc = "Signature help" })
      vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Jump to prev [D]iagnostic" })
      vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Jump to next [D]iagnostic" })

      vim.keymap.set({ 'n', 'v' }, "<leader>a", require("tiny-code-action").code_action,
        { desc = "Code [A]ctions", noremap = true, silent = true }
      )

      vim.keymap.set('n', '<leader>lr', "<cmd>LspRestart<cr>", { desc = "[L]SP [R]estart" })
      vim.keymap.set('n', '<leader>ls', "<cmd>LspStart<cr>", { desc = "[L]SP [S]tart" })
      vim.keymap.set('n', '<leader>lp', "<cmd>LspStop<cr>", { desc = "[L]SP Sto[p]" })
      vim.keymap.set('n', '<leader>li', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
      end, { desc = "[L]SP [i]nlay hints" })
    end
  },
}
