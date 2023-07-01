-- This file is a main user config entry. 
-- It's imported to main 'init.lua' at the bottom of file
--
--  User plugins are placed in 'lua/custom/plugins/init.lua' and imported to main 'init.lua' 
--  inside its plugins require block (at the and of that block)

local config_file_path = "~/.config/nvim/lua/custom/config/init.lua"
local function open_config()
  vim.cmd('e ' .. config_file_path)
end

------------------------------------

-- Limit cursor top and bottom position
vim.o.scrolloff = 10


-- Keymapping
vim.keymap.set('n', '<leader>f', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>co', open_config, { desc = '[C]onfig [O]pen' })


