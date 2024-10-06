return {
  "lewis6991/gitsigns.nvim",
  keys = {
    { "<leader>gd", "<cmd>Gitsigns diffthis<cr>" },
    { "<leader>gs", "<cmd>Gitsigns toggle_signs<cr>" },
  },
  config = function()
    require("gitsigns").setup {}
  end,
}
