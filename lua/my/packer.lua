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
	use 'ThePrimeagen/harpoon'
	use 'mbbill/undotree'

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
	-- Preconfigured Snippets
	use "rafamadriz/friendly-snippets"
	use 'ggandor/leap.nvim'
	use {
		'nvim-lualine/lualine.nvim',
		requires = { 'nvim-tree/nvim-web-devicons', opt = true }
	}
end)
