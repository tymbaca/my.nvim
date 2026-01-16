return {
  "xiyaowong/transparent.nvim",
  -- dependencies = "typicode/bg.nvim",
  -- priority = 800,
  -- lazy = true,
  keys = {
    { "<leader>UT", "<cmd>TransparentToggle<cr>" },
  },
  config = function()
    local transparent = require("transparent")
    transparent.setup {}

    vim.cmd("TransparentDisable")
    -- transparent.clear_prefix('NvimTree')
    -- vim.keymap.set("n", "<leader>UT", "<cmd>TransparentToggle<cr>")
  end
}
