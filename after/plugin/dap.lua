-- local home_dir = os.getenv("HOME")
-- local rust_tools_path = home_dir .. "/.config/nvim/after/plugin/rusttools.lua"
-- dofile(rust_tools_path)

local dap = require("dap")


-- dap.adapters.rust = {
--   type = "executable",
--   command = "lldb-vscode",
--   name = "rt_lldb",
-- }

dap.configurations.rust = {
  {
    type = 'rt_lld',
    request = 'launch',
    name = 'Launch Rust debug session'
  }
}


vim.keymap.set('n', '<leader>Dc', dap.continue, { desc = '[C]ontinue debugging (or start)' })
vim.keymap.set('n', '<leader>Dx', dap.close, { desc = 'Close current debug session' })
-- vim.keymap.set('n', '<leader>DR', dap.run, { desc = '[R]un debug session' })
vim.keymap.set('n', '<leader>DL', dap.run_last, { desc = 'Re-run [L]ast debug session' })
vim.keymap.set('n', '<leader>Dr', dap.restart, { desc = '[R]estart debug session' })
vim.keymap.set('n', '<leader>Db', dap.toggle_breakpoint, { desc = 'Toggle a [B]reakpoint' })
vim.keymap.set('n', '<leader>DB', dap.list_breakpoints, { desc = 'List a [B]reakpoints list' })
vim.keymap.set('n', '<leader>DR', dap.repl.toggle, { desc = 'Open REPL / Debug-console' })


vim.keymap.set('n', '<F8>', dap.step_into, { desc = 'DAP: Step into' })
vim.keymap.set('n', '<F9>', dap.step_over, { desc = 'DAP: Step over' })
vim.keymap.set('n', '<F7>', dap.step_out, { desc = 'DAP: Step out' })
vim.keymap.set('n', '<leader><F9>', dap.run_to_cursor, { desc = 'DAP: Run to cursor' })


-- Widgets
--
-- The widgets may have the following custom mappings enabled:
-- - `<CR>` to expand or collapse an entry
-- - `a` to show a menu with available actions
--
local widgets = require('dap.ui.widgets')
local my_sidebar = widgets.sidebar(widgets.scopes)
vim.keymap.set('n', '<leader>Dl', my_sidebar.toggle, { desc = 'Toggle sidebar' })
