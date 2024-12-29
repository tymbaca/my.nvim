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
  "anAcc22/sakura.nvim",
  'AlexvZyl/nordic.nvim',
  "shaunsingh/nord.nvim",
  { "catppuccin/nvim",      name = "catppuccin",                  priority = 1000 },
  'christoomey/vim-tmux-navigator',
  'rhysd/conflict-marker.vim',
  {
    "sindrets/diffview.nvim",
    config = function()
      vim.keymap.set("n", "<leader>dfm", "<cmd>DiffviewOpen master<cr>")
      vim.keymap.set("n", "<leader>df1", "<cmd>DiffviewOpen HEAD~1<cr>")
      vim.keymap.set("n", "<leader>df2", "<cmd>DiffviewOpen HEAD~2<cr>")
      vim.keymap.set("n", "<leader>df3", "<cmd>DiffviewOpen HEAD~3<cr>")
      vim.keymap.set("n", "<C-Q>d", "<cmd>DiffviewClose<cr>")
    end,
  },
  {
    "jaimecgomezz/here.term",
    opts = {
      mappings = {
        toggle = "<C-;>",
        kill = "<C-'>",
      },
    },
  },
}
