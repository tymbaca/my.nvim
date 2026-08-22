return {
  "saghen/blink.cmp",
  lazy = false, -- Load early for crisp autocompletion
  dependencies = {
    "rafamadriz/friendly-snippets", -- Kept from your old setup for snippet data
  },
  version = "v0.*", -- Tracks stable releases
  
  opts = {
    -- Matches your old nvim-cmp shortcuts
    keymap = {
      preset = "none", -- Disable defaults to explicitly use your mappings
      
      ["<CR>"] = { "accept", "fallback" }, -- Enter to accept (select = false behavior)
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      
      ["<C-n>"] = { "select_next", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<Up>"] = { "select_prev", "fallback" },
    },

    -- Cleaned up valid providers: No crashing 'treesitter' source module
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },

    -- Replaces 'onsails/lspkind.nvim' (Blink builds icons natively)
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "mono",
    },

    -- Replaces 'vim.cmd("set pumheight=10")'
    completion = {
      menu = {
        max_height = 6,
        draw = {
          -- Instructs Blink to use Tree-sitter colors for rendering the labels
          treesitter = { "lsp" },
          columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
      },
    },

    -- Active signature help (Replaces 'nvim_lsp_signature_help')
    -- signature = { enabled = true },
  },
}

