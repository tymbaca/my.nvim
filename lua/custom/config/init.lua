-- This file is a main user config entry. 
-- It's imported to main 'init.lua' at the bottom of file
--
--  User plugins are placed in 'lua/custom/plugins/init.lua' and imported to main 'init.lua' 
--  inside its plugins require block (at the and of that block)

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

------------------------------------

-- Limit cursor top and bottom position
vim.o.scrolloff = 10
vim.o.nu = true
vim.o.relativenumber = true

vim.cmd("colorscheme everforest")
require("lualine").setup({
  options = {
    -- ... other configuration
    theme = "auto", -- Can also be "auto" to detect automatically.
  }
})

-- Keymapping
vim.keymap.set('n', '<leader>f', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>co', open_config, { desc = '[C]onfig [O]pen' })
vim.keymap.set('n', '<leader>cg', open_global_config, { desc = '[C]onfig [G]lobal open' })
vim.keymap.set('n', '<leader>cp', open_plugins, { desc = '[C]onfig [P]lugins open' })
vim.keymap.set('n', '<leader>cs', require('telescope.builtin').colorscheme, { desc = '[C]olor[S]cheme select' })
vim.keymap.set('n', '<leader>t', function () vim.cmd(":Telescope") end, { desc = 'Open [T]elescope' })


