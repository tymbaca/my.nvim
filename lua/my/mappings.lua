local map = vim.keymap.set

vim.g.mapleader = " "
map("n", "<leader>e", vim.cmd.Ex) -- Jump to file tree
map('n', ';', vim.cmd.noh) -- Cancel search highlighting

map('n', 'gp', function() vim.cmd("b#") end) -- Jump to previous buffer

-- Fast escape from normal mode
map('i', 'jk', function () vim.cmd("stopinsert") end)

-- Move selected lines
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Centered half-page move
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- greatest remap ever
map("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
map({"n", "v"}, "<leader>y", [["+y]])
map("n", "<leader>Y", [["+Y]])

map("n", "<leader>s{", [[@s]])

map("n", "<leader>w", "<cmd>write<cr>")
map("i", "<C-w>", "<cmd>write<cr>")

vim.cmd [[source ~/.config/nvim/lua/my/mappings.vim]]
