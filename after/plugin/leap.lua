local leap = require('leap')

vim.keymap.set({'n', 'v'}, '<C-f>', function ()
  local current_window = vim.fn.win_getid()
  leap.leap { target_windows = { current_window } }
end)
