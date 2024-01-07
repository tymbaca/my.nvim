require'nvim-treesitter.configs'.setup {
	-- A list of parser names, or "all" (the five listed parsers should always be installed)
	ensure_installed = { 
		"javascript", 
		"typescript", 
		"c", 
		"lua", 
		"vim", 
		"vimdoc", 
		"query", 
		"go",
		"python",
		"rust",
    "templ"
	},

	-- Install parsers synchronously (only applied to `ensure_installed`)
	sync_install = false,

	-- Automatically install missing parsers when entering buffer
	-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
	auto_install = true,

	highlight = {
		enable = true,

		-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
		-- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
		-- Using this option may slow down your editor, and you may see some duplicate highlights.
		-- Instead of true it can also be a list of languages
		additional_vim_regex_highlighting = false,
	},
}

-- local util = require("nvim-treesitter.ts_utils")
-- local next = util.get_next_node
-- local prev = util.get_previous_node
-- local cur = util.get_node_at_cursor
-- local chil = util.get_named_children
-- local text = util.get_node_text

-- vim.keymap.set("n", "<leader>q1", function ()
--   print(text(prev(cur(), true, false))[1])
-- end)

-- -- vim.keymap.set("n", "<leader>q2", function ()
-- --   print(next(cur(), true, false))
-- -- end)
-- --
-- vim.keymap.set("n", "<leader>qq", function ()
--   -- print(util.get_node_at_cursor())
--   local line = vim.api.nvim_get_current_line()
--   local i, j = line:find("[^\t].+")
--   if not i or not j then
--     print("cannot find substring")
--     return
--   end
--   line = line:sub(i, j)
  
--   i, j = line:find(" *=.*")
--   line = line:sub(1, i-1)

--   print(line)
-- end)

-- -- vim.keymap.set("n", "<leader>qp", function ()
-- --   print(cur():parent())
-- -- end)

-- -- vim.keymap.set("n", "<leader>qc", function ()
-- --   local children = chil(cur())
-- --   print(children, children["left"], children["right"])
-- -- end)

-- local M = {}
-- function M.go_get_item_for_append()
--   -- local t = text(prev(cur(), true, false))[1]
--   -- return t
--   local line = vim.api.nvim_get_current_line()
--   local i, j = line:find("[^\t].+")
--   if not i or not j then
--     print("cannot find substring")
--     return
--   end
--   line = line:sub(i, j)
  
--   i, j = line:find(" *=.*")
--   line = line:sub(1, i-1)
--   return line
-- end

-- return M
