-- This file is a main user config entry. 
-- It's imported to main 'init.lua' at the bottom of file
--
--  User plugins are placed in 'lua/custom/plugins/init.lua' and imported to main 'init.lua' 
--  inside its plugins require block (at the and of that block)

local nvim_config_folder = "~/.config/nvim/"
local config_path = "~/.config/nvim/lua/custom/config/init.lua"
local plugins_path = "~/.config/nvim/lua/custom/plugins/init.lua"
local global_config_path = "~/.config/nvim/init.lua"
local function open_config()
  vim.cmd('e ' .. config_path)
end

local function open_plugins()
  vim.cmd('e ' .. plugins_path)
end

local function open_global_config()
  vim.cmd('e ' .. global_config_path)
end

local function table_contains(table_, value)
  for _, element in ipairs(table_) do
    if element == value then
      return true
    end
  end
  return false
end

local function map(mode, keys, action, etc)
  etc = etc or {}  -- Default value
  vim.keymap.set(mode, keys, action, etc)
end

--------------------------------------------------------------------
-------------------- Plugin Configurations -------------------------
--------------------------------------------------------------------

require'lspconfig'.cssmodules_ls.setup {}

--------------------------------------------------------------------

require("autoclose").setup()

--------------------------------------------------------------------

require'nvim-treesitter.configs'.setup {
  autotag = {
    enable = true,
    enable_rename = true,
    enable_close = true,
    enable_close_on_slash = true,
  }
}

--------------------------------------------------------------------

-- local on_attach = function(client)
--     require'completion'.on_attach(client)
-- end
--
-- local util = require("lspconfig.util")
--
-- require"lspconfig".rust_analyzer.setup {
--     on_attach=on_attach,
--     settings = {
--         ["rust-analyzer"] = {
--             imports = {
--                 granularity = {
--                     group = "module",
--                 },
--                 prefix = "self",
--             },
--             cargo = {
--                 buildScripts = {
--                     enable = true,
--                 },
--             },
--             procMacro = {
--                 enable = true
--             },
--         }
--     }
-- }
--------------------------------------------------------------------

require("everforest").setup({
})

--------------------------------------------------------------------

local auto_dark_mode = require('auto-dark-mode')

auto_dark_mode.setup({
	update_interval = 1000,
	set_dark_mode = function()
		vim.api.nvim_set_option('background', 'dark')
		vim.cmd('colorscheme everforest')
	end,
	set_light_mode = function()
		vim.api.nvim_set_option('background', 'light')
		vim.cmd('colorscheme everforest')
	end,
})
auto_dark_mode.init()

--------------------------------------------------------------------

local leap = require('leap')
leap.add_default_mappings()

--------------------------------------------------------------------

local rt = require("rust-tools")

rt.setup({
  server = {
    on_attach = function(_, bufnr)
      -- Hover actions
      vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
      -- Code action groups
      vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
    end,
  },
})

--------------------------------------------------------------------
------------------ Options and Keymappings -------------------------
--------------------------------------------------------------------

-- Limit cursor top and bottom position
vim.o.scrolloff = 10
vim.o.nu = true
vim.o.relativenumber = true

-- vim.cmd("colorscheme everforest")
require("lualine").setup({
  options = {
    -- ... other configuration
    theme = "auto", -- Can also be "auto" to detect automatically.
  }
})

-- Keymapping
map('n', '<leader>f', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
map('n', '<leader>co', open_config, { desc = '[C]onfig [O]pen' })
map('n', '<leader>cg', open_global_config, { desc = '[C]onfig [G]lobal open' })
map('n', '<leader>cp', open_plugins, { desc = '[C]onfig [P]lugins open' })
map('n', '<leader>cs', require('telescope.builtin').colorscheme, { desc = '[C]olor[S]cheme select' })
map('n', '<leader>t', function () vim.cmd("Telescope") end, { desc = 'Open [T]elescope' })
map('i', 'jk', function () vim.cmd("stopinsert") end, {})
map('n', 'gn', function () vim.cmd("bnext") end, { desc = '[G]o to [N]ext buffer' })
map('n', 'gp', function () vim.cmd("bprev") end, { desc = '[G]o to [P]revious buffer' })

vim.keymap.set({'n', 'v'}, 'f', function ()
  local current_window = vim.fn.win_getid()
  require('leap').leap { target_windows = { current_window } }
end)


-- Snippets
require("luasnip.loaders.from_vscode").lazy_load({ paths = { './snippets' } })


-- Wrap rules
local wrap_filetypes = {"markdown", "txt", "tex"}
vim.cmd("set nowrap")
if table_contains(wrap_filetypes, vim.bo.filetype) then
  vim.cmd(":set wrap")
end

-- Tab size

vim.o.expandtab = true
vim.opt_global.tabstop = 4
vim.opt_global.shiftwidth = 4
vim.opt_global.softtabstop = 4

vim.cmd("source " .. nvim_config_folder .. "user.vim")
