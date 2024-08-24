local twilight = require "twilight"
twilight.setup {
  context = 0,
}

vim.keymap.set("n", "<leader>tw", "<cmd>Twilight<cr>")
