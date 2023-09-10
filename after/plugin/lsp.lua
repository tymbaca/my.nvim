local lsp = require('lsp-zero').preset({})
local telescope_builtin = require('telescope.builtin')

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({buffer = bufnr})
end)

-- (Optional) Configure lua language server for neovim
require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

-- Ensure Language Server installed
lsp.ensure_installed({
})

lsp.setup()




-- You need to setup `cmp` after lsp-zero
local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
	mapping = {
		-- `Enter` key to confirm completion
		['<CR>'] = cmp.mapping.confirm({select = false}),

		-- Ctrl+Space to trigger completion menu
		['<C-Space>'] = cmp.mapping.complete(),

    -- Navigate with tabs
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),

		-- Navigate between snippet placeholder
		['<C-f>'] = cmp_action.luasnip_jump_forward(),
		['<C-b>'] = cmp_action.luasnip_jump_backward(),
	},
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
	sources = cmp.config.sources({
		{ name = "nvim_lsp" },
		{ name = 'luasnip' },
	}, {
		{ name = 'buffer' }
	})
})

vim.cmd("set pumheight=10") -- Limit CMP list

-- Keymap
-- For more default keymap go to https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#default_keymapsopts
vim.keymap.set('n', '<leader>dh', vim.diagnostic.open_float, { desc = '[D]iagnotics [H]over' })
vim.keymap.set('n', '<leader>de', vim.diagnostic.enable, { desc = '[D]iagnotics [E]nable' })
vim.keymap.set('n', '<leader>dd', vim.diagnostic.disable, { desc = '[D]iagnotics [D]isable' })

vim.keymap.set('n', '<leader>r', function()
  vim.lsp.buf.rename(vim.fn.input("Rename symbol: ", vim.fn.expand("<cword>")))
end, { desc = "[R]ename the symbol" })

vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, { desc = "Go to declaration" })
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set('n', 'gr', function ()
  telescope_builtin.lsp_references()
end, { desc = "List all references" })
vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { desc = "Go to implementation" })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "Hover documentation" })
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = "Jump to prev [D]iagnostic" })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = "Jump to next [D]iagnostic" })

vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = "[C]ode [A]ctions" })
