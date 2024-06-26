local lualine = require('lualine')
lualine.setup()

local showed = false

vim.o.laststatus = 0
vim.o.cmdheight = 0

if showed then
  lualine.hide({ unhide = true })
  vim.o.cmdheight = 1
end

vim.keymap.set("n", "<leader>UL", function()
  if showed then
    lualine.hide()
    vim.o.cmdheight = 0
    showed = false
  else
    lualine.hide({ unhide = true })
    vim.o.cmdheight = 1
    showed = true
  end
end)
