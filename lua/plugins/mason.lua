return {
	{
		"williamboman/mason.nvim",
		-- "williamboman/mason-lspconfig.nvim",
		config = function() 
			require("mason").setup {}
			require("mason-lspconfig").setup()
		end
	},
}
