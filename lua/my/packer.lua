vim.cmd [[packadd packer.nvim]]

return require("packer").startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -- Telescope
  use {
    'nvim-telescope/telescope.nvim', tag = '0.1.2',
    requires = { { 'nvim-lua/plenary.nvim' } }
  }
  use "smartpde/telescope-recent-files"

  -- Tree-sitter
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  use 'nvim-treesitter/playground'


  -- Autoclose
  use 'm4xshen/autoclose.nvim'
  use 'windwp/nvim-ts-autotag'

  use 'christoomey/vim-tmux-navigator'
  use 'rhysd/conflict-marker.vim'
  use 'lewis6991/gitsigns.nvim'
  use 'ThePrimeagen/harpoon'
  use 'mbbill/undotree'

  -- TODO's and Trouble
  use "folke/todo-comments.nvim"
  use {
    "folke/trouble.nvim",
    requires = "nvim-tree/nvim-web-devicons"
  }

  use 'lervag/vimtex'

  -- THEMES
  use 'f-person/auto-dark-mode.nvim'
  use 'morhetz/gruvbox'
  use 'sainnhe/everforest'
  use 'AlexvZyl/nordic.nvim'

  -- LSP
  use {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    requires = {
      -- LSP Support
      { 'neovim/nvim-lspconfig' }, -- Required
      {                       -- Optional
        'williamboman/mason.nvim',
        run = function()
          pcall(vim.cmd, 'MasonUpdate')
        end,
      },
      { 'williamboman/mason-lspconfig.nvim' }, -- Optional

      -- Autocompletion
      { 'hrsh7th/nvim-cmp' }, -- Required
      { 'hrsh7th/cmp-nvim-lsp' }, -- Required
      { 'L3MON4D3/LuaSnip' }, -- Required
    }
  }
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      'saadparwaiz1/cmp_luasnip'
    }
  }
  use 'mfussenegger/nvim-dap' -- DAP (Debugging)
  use 'leoluz/nvim-dap-go'
  use 'simrat39/rust-tools.nvim'

  use {
    "L3MON4D3/LuaSnip",
    -- follow latest release.
    -- tag = "v2.*", -- Replace <CurrentMajor> by the latest released major (first number of latest release)
    -- install jsregexp (optional!:).
    run = "make install_jsregexp"
  }

  use { 'saadparwaiz1/cmp_luasnip' }

  -- Preconfigured Snippets
  -- use "rafamadriz/friendly-snippets"

  use 'ggandor/leap.nvim'
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'nvim-tree/nvim-web-devicons', opt = true }
  }

  use 'terrortylor/nvim-comment' -- Comments
  use {
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
  }

  use "lukas-reineke/lsp-format.nvim"
  use 'iamcco/markdown-preview.nvim'
  use({
    "andrewferrier/wrapping.nvim",
    config = function()
      require("wrapping").setup()
    end,
  })

  use {
    "kylechui/nvim-surround",
    tag = "*", -- Use for stability; omit to use `main` branch for the latest features
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  }

  use({ 'scalameta/nvim-metals', requires = { "nvim-lua/plenary.nvim" } })

  use "joerdav/templ.vim"
  use "folke/zen-mode.nvim"

  use({
    'Wansmer/sibling-swap.nvim',
    requires = { 'nvim-treesitter' },
    config = function()
      require("sibling-swap").setup({})
    end
  })

  use "buoto/gotests-vim"
  -- packer.nvim
  use { 'akinsho/git-conflict.nvim', tag = "*" }
  use "hedyhli/outline.nvim"
  use "nvim-tree/nvim-tree.lua"
  use "nvim-tree/nvim-web-devicons"
  -- use "tpope/vim-repeat"
  use {
    "mcchrish/zenbones.nvim",
    -- Optionally install Lush. Allows for more configuration or extending the colorscheme
    -- If you don't want to install lush, make sure to set g:zenbones_compat = 1
    -- In Vim, compat mode is turned on as Lush only works in Neovim.
    requires = "rktjmp/lush.nvim"
  }
end)
