vim.g.mapleader = " "
vim.keymap.set("n", "<leader>e", vim.cmd.Ex) -- Jump to file tree
vim.keymap.set('n', ';', vim.cmd.noh) -- Cancel search highlighting

vim.keymap.set('n', 'gp', function() vim.cmd("b#") end) -- Jump to previous buffer

-- Fast escape from normal mode
vim.keymap.set('i', 'jk', function () vim.cmd("stopinsert") end)

-- Move selected lines
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Centered half-page move
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- greatest remap ever
vim.keymap.set("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
vim.keymap.set({"n", "v"}, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])
