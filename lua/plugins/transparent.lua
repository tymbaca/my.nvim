return {
  "xiyaowong/transparent.nvim",
  config = function()
    local transparent = require("transparent")
    transparent.setup {}

    transparent.clear_prefix('NvimTree')
    vim.keymap.set("n", "<leader>Ut", "<cmd>TransparentToggle<cr>")

    vim.cmd("TransparentEnable")
    -- vim.cmd("TransparentDisable")
  end
}
