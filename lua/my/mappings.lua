vim.g.mapleader = " "
vim.keymap.set("n", "<leader>e", vim.cmd.Ex) -- Jump to file tree
vim.keymap.set('n', ';', vim.cmd.noh) -- Cancel search highlighting

vim.keymap.set('n', 'gp', function() vim.cmd("b#") end) -- Jump to previous buffer
