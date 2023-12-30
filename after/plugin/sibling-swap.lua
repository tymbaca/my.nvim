-- vim.keymap.set({"n", "i"}, "<C-]>", "<CMD>Hello")
vim.keymap.set({"i", "n"}, "<C-[>", require('sibling-swap').swap_with_left)
vim.keymap.set({"n", "i"}, "<C-]>", require('sibling-swap').swap_with_right)
