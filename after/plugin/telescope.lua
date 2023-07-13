local builtin = require("telescope.builtin")

-- Single key
vim.keymap.set('n', '<leader>f', builtin.find_files, { desc = "Find [F]iles" })

-- [P]roject
vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = "Find [F]iles" })
vim.keymap.set('n', '<leader>ps', function()
	builtin.grep_string({ search = vim.fn.input("Type (or press Enter) > ") })
end, { desc = "Find in [P]roject by grep [S]earch" })

-- [S]earch
vim.keymap.set('n', '<leader>sg', builtin.grep_string, { desc = "[S]earch by [G]rep" })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = "[S]earch [F]iles" })
vim.keymap.set('n', '<leader>sc', function()
	builtin.colorscheme({ enable_preview = true })
end, { desc = "[S]earch [C]olorschemes" })

-- [G]it
vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = "Find [G]it [F]iles" })
