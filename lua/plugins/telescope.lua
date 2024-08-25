return {
	'nvim-telescope/telescope.nvim', branch = '0.1.x',
	dependencies = { 'nvim-lua/plenary.nvim', 'mollerhoj/telescope-recent-files.nvim' },
	keys = {
		{"<leader>f", "<cmd>Telescope find_files<cr>"},
		{"<leader>T", "<cmd>Telescope<cr>"},
		{"<leader>sg", "<cmd>Telescope live_grep<cr>"},
		{"<leader>sc", function()
			require('telescope.builtin').colorscheme({ enable_preview = true })
		end, { desc = "[S]earch [C]olorschemes" }},
	},
	config = function()
		require('telescope').setup {}
		require("telescope").load_extension("recent-files")

    -- vim.keymap.set('n', '<leader><leader>', function()
    --   require('telescope').extensions['recent-files'].recent_files({})
    -- end, { noremap = true, silent = false })

		
		-- vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
		-- vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
		-- vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
		-- vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
		-- local builtin = require("telescope.builtin")
		-- -- require("telescope").load_extension("recent_files")

		-- -- Single key
		-- vim.keymap.set('n', '<leader>f', builtin.find_files, { desc = "Find [F]iles" })
		-- vim.keymap.set('n', '<leader>T', vim.cmd.Telescope, { desc = "Open [T]elescope" })
		-- -- vim.api.nvim_set_keymap("n", "<Leader><Leader>",
		-- -- 	[[<cmd>lua require('telescope').extensions.recent_files.pick()<CR>]],
		-- -- 	{ noremap = true, silent = true })

		-- -- [P]roject
		-- vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = "Find [F]iles" })
		-- vim.keymap.set('n', '<leader>ps', function()
		-- 	builtin.grep_string({ search = vim.fn.input("Type (or press Enter) > ") })
		-- end, { desc = "Find in [P]roject by grep [S]earch" })

		-- -- [S]earch
		-- vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = "[S]earch by [G]rep" })
		-- vim.keymap.set('n', '<leader>sb', builtin.git_branches, { desc = "[S]earch by [G]rep" })
		-- vim.keymap.set('n', '<leader>sc', function()
		-- 	builtin.colorscheme({ enable_preview = true })
		-- end, { desc = "[S]earch [C]olorschemes" })

		-- -- [G]it
		-- vim.keymap.set('n', '<leader>gf', builtin.git_files, { desc = "Find [G]it [F]iles" })
		-- vim.keymap.set('n', '<leader>gc', builtin.git_bcommits, { desc = "Find [G]it this file [C]ommits" })
		-- vim.keymap.set('n', '<leader>gC', builtin.git_commits, { desc = "Find [G]it [C]ommits" })
		-- vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = "Find [G]it [B]ranches" })
	end
}
