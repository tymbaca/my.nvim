return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    -- disable netrw at the very start of your init.lua
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    require("nvim-tree").setup {}
  end,
  keys = {
    { "<leader>e", "<cmd>NvimTreeToggle<cr>" },
    { "<leader>E", "<cmd>NvimTreeFindFile<cr>" },
  },
}
