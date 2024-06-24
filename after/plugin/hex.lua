local hex = require('hex')
hex.setup()

vim.keymap.set("n", "<leader>h", hex.toggle)
