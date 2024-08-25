return {
  "folke/zen-mode.nvim",
  config = function()
    local zen = require("zen-mode")

    vim.keymap.set("n", "<leader>z", function()
      zen.toggle({
        window = {
          backdrop = 1,
          width = 0.7,
          options = {
            signcolumn = "no",
            -- number = false,
            -- relativenumber = false,
          }
        },
        gitsigns = { enabled = false },
      })
    end)
  end
}
