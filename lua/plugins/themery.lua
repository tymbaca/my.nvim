return {
  "zaldih/themery.nvim",
  lazy = false,
  keys = {
    { "<leader>sc", "<cmd>Themery<cr>", desc = "[S]earch [C]olorschemes" },
  },
  config = function()
    -- local available_colorschemes = vim.fn.getcompletion("", "color")
    -- local colorschemes = {}
    -- for _, colorscheme in ipairs(available_colorschemes) do
    --   table.insert(colorschemes, colorscheme)
    -- end

    require("themery").setup({
      themes = {
        "nordic", "blue", "catppuccin", "catppuccin-frappe", "catppuccin-latte", "catppuccin-macchiato",
        "catppuccin-mocha", "darkblue", "default", "delek", "desert", "duckbones", "elflord", "evening", "everforest",
        "forestbones", "habamax", "habamax.nvim", "industry", "kanagawabones", "koehler", "lunaperche", "morning",
        "murphy", "neobones", "nord", "nordbones", "pablo", "peachpuff", "quiet", "randombones",
        "retrobox", "ron", "rosebones", "sakura", "seoulbones", "shine", "slate", "sorbet", "tokyobones", "torte",
        "unokai", "vim", "vimbones", "wildcharm", "zaibatsu", "zellner", "zenbones", "zenburned", "zenwritten",
      },
      livePreview = true,
    })
  end
}
