return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-buffer", -- source for text in buffer
    "hrsh7th/cmp-path",   -- source for file system paths
    {
      "L3MON4D3/LuaSnip",
      -- follow latest release.
      version = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
      -- install jsregexp (optional!).
      build = "make install_jsregexp",
    },
    "saadparwaiz1/cmp_luasnip",     -- for autocompletion
    "rafamadriz/friendly-snippets", -- useful snippets
    "onsails/lspkind.nvim",         -- vs-code like pictograms
    "hrsh7th/cmp-nvim-lsp",
    'neovim/nvim-lspconfig',
  },
  config = function()
    local cmp = require("cmp")

    cmp.setup({
      mapping = {
        -- `Enter` key to confirm completion
        ['<CR>'] = cmp.mapping.confirm({ select = false }),

        -- Ctrl+Space to trigger completion menu
        ['<C-Space>'] = cmp.mapping.complete(),

        -- Navigate with tabs
        ['<C-n>'] = cmp.mapping.select_next_item(),
        ['<C-p>'] = cmp.mapping.select_prev_item(),
      },
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      sources = cmp.config.sources({
        { name = 'luasnip' },
        { name = "nvim_lsp", max_item_count = 50 },
      }, {
        { name = 'buffer' }
      })
    })

    vim.cmd("set pumheight=10") -- Limit CMP list

    -- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
    local capabilities = require('cmp_nvim_lsp').default_capabilities()

    -- An example for configuring `clangd` LSP to use nvim-cmp as a completion engine
    local lspconfig = require('lspconfig')
    local language_servers = lspconfig.util.available_servers() -- or list servers manually like {'gopls', 'clangd'}
    for _, ls in ipairs(language_servers) do
      lspconfig[ls].setup({
        capabilities = capabilities
        -- you can add other fields for setting up lsp server in this table
      })
    end
  end
}
