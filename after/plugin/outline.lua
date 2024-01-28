local outline = require("outline")
outline.setup({})

vim.keymap.set("n", "<leader>o", outline.toggle)
