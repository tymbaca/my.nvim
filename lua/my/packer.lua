vim.cmd [[packadd packer.nvim]]

return require("packer").startup(function(use)
	-- Packer can manage itself
	use 'wbthomason/packer.nvim'

	-- Telescope
	use {
		'nvim-telescope/telescope.nvim', tag = '0.1.2',
		requires = { {'nvim-lua/plenary.nvim'} }
	}

	use { 
		'nvim-treesitter/nvim-treesitter', 
		run = ':TSUpdate' }
	
	-- Autoclose
	use 'm4xshen/autoclose.nvim'
	use 'windwp/nvim-ts-autotag'
end)
