return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup {}
      require("mason-lspconfig").setup()
    end
  },
  "williamboman/mason-lspconfig.nvim",
}
