vim.cmd [[packadd packer.nvim]]

return require("packer").startup(function(use)
	-- Packer can manage itself
	use 'wbthomason/packer.nvim'

	-- Telescope
	use {
		'nvim-telescope/telescope.nvim', tag = '0.1.2',
		requires = { {'nvim-lua/plenary.nvim'} }
	}

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
			{'neovim/nvim-lspconfig'},             -- Required
			{                                      -- Optional
				'williamboman/mason.nvim',
				run = function()
					pcall(vim.cmd, 'MasonUpdate')
				end,
			},
			{'williamboman/mason-lspconfig.nvim'}, -- Optional

			-- Autocompletion
			{'hrsh7th/nvim-cmp'},     -- Required
			{'hrsh7th/cmp-nvim-lsp'}, -- Required
			{'L3MON4D3/LuaSnip'},     -- Required
		}
	}

  use 'mfussenegger/nvim-dap' -- DAP (Debugging)
  use 'leoluz/nvim-dap-go'
  use 'simrat39/rust-tools.nvim'

  -- Preconfigured Snippets
  use "rafamadriz/friendly-snippets"
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

end)
