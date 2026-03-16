return {
  {
    "lewis6991/gitsigns.nvim",
    keys = {
      { "<leader>gd", "<cmd>Gitsigns diffthis<cr>" },
      { "<leader>gs", "<cmd>Gitsigns toggle_signs<cr>" },
    },
    lazy = false,
    config = function()
      local gitsigns = require("gitsigns")
      gitsigns.setup {}
      gitsigns.toggle_signs()
    end,
  }
}
