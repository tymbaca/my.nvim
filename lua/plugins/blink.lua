return {
  "saghen/blink.cmp",
  lazy = false,
  version = "v0.*",
  
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
      default = { "lsp", "path", "snippets", "buffer" },
    },
  
    -- Replaces 'onsails/lspkind.nvim' (Blink builds icons natively)
    -- appearance = {
    --   use_nvim_cmp_as_default = true,
    --   nerd_font_variant = "mono",
    -- },
  
    completion = {
      menu = {
        max_height = 6,
        -- draw = {
        --   -- Instructs Blink to use Tree-sitter colors for rendering the labels
        --   treesitter = { "lsp" },
        --   columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
        -- },
      },
      documentation = {
        auto_show = true,
      },
    },
  },
}
