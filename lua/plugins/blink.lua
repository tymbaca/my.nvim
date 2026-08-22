return {
  "saghen/blink.cmp",
  lazy = false,
  version = "v0.*",
  dependencies = {
    "ray-x/cmp-treesitter", 
    -- main branch: fixes cmp-treesitter "params (a nil value)" in get_keyword_pattern
    { "saghen/blink.compat", branch = "main", opts = {} },
  },
  
  opts = {
    keymap = {
      preset = "none",
     
      ["<CR>"] = { "accept", "fallback" },
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
     
      ["<C-n>"] = { "select_next", "fallback" },
      ["<C-p>"] = { "select_prev", "fallback" },
      ["<Down>"] = { "select_next", "fallback" },
      ["<Up>"] = { "select_prev", "fallback" },
    },
  
    sources = {
      default = { "lsp", "path", "snippets", "buffer", "treesitter" },
      providers = {
        treesitter = {
          name = "treesitter", -- name of the cmp source
          module = "blink.compat.source", -- mandatory compat module
          score_offset = -3,
        },
      },
    },
  
    -- Replaces 'onsails/lspkind.nvim' (Blink builds icons natively)
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "mono",
    },
  
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
  },
}
