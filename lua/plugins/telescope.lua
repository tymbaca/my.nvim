return {
	'nvim-telescope/telescope.nvim', tag = '0.1.7',
	dependencies = { 'nvim-lua/plenary.nvim' },
	config = function()
		local builtin = require("telescope.builtin")
		require("telescope").load_extension("recent_files")

		-- Single key
		vim.keymap.set('n', '<leader>f', builtin.find_files, { desc = "Find [F]iles" })
		vim.keymap.set('n', '<leader>T', vim.cmd.Telescope, { desc = "Open [T]elescope" })
		vim.api.nvim_set_keymap("n", "<Leader><Leader>",
			[[<cmd>lua require('telescope').extensions.recent_files.pick()<CR>]],
			{ noremap = true, silent = true })

		-- [P]roject
		vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = "Find [F]iles" })
		vim.keymap.set('n', '<leader>ps', function()
			builtin.grep_string({ search = vim.fn.input("Type (or press Enter) > ") })
		end, { desc = "Find in [P]roject by grep [S]earch" })

		-- [S]earch
		vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = "[S]earch by [G]rep" })
		vim.keymap.set('n', '<leader>sb', builtin.git_branches, { desc = "[S]earch by [G]rep" })
		vim.keymap.set('n', '<leader>sc', function()
			builtin.colorscheme({ enable_preview = true })
		end, { desc = "[S]earch [C]olorschemes" })

		-- [G]it
		vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = "Find [G]it [F]iles" })
		vim.keymap.set('n', '<leader>gc', builtin.git_bcommits, { desc = "Find [G]it this file [C]ommits" })
		vim.keymap.set('n', '<leader>gC', builtin.git_commits, { desc = "Find [G]it [C]ommits" })
		vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = "Find [G]it [B]ranches" })
	end
}
