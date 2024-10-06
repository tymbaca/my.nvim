return {
  {
    'windwp/nvim-autopairs',
    -- event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup {}
    end
  },
  {
    "folke/which-key.nvim",
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require("which-key").setup {
        -- your configuration comes here
        -- or leave it empty to use the default settings
        -- refer to the configuration section below
      }
    end
  },

  {
    "kylechui/nvim-surround",
    config = function()
      require("nvim-surround").setup({})
    end
  },

  {
    "mcchrish/zenbones.nvim",
    -- Optionally install Lush. Allows for more configuration or extending the colorscheme
    -- If you don't want to install lush, make sure to set g:zenbones_compat = 1
    -- In Vim, compat mode is turned on as Lush only works in Neovim.
    dependencies = "rktjmp/lush.nvim"
  },
  { "ntk148v/habamax.nvim", dependencies = { "rktjmp/lush.nvim" } },

  "folke/todo-comments.nvim",
  'sainnhe/everforest',
  'AlexvZyl/nordic.nvim',
  'christoomey/vim-tmux-navigator',
  'rhysd/conflict-marker.vim',
  "sindrets/diffview.nvim",



}
