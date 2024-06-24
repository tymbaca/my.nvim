local lualine = require('lualine')
lualine.setup()

local state = true

vim.o.laststatus = 0
lualine.hide({ unhide = true })

vim.keymap.set("n", "<leader>UL", function()
  if state == true then
    lualine.hide()
    state = false
  else
    lualine.hide({ unhide = true })
    state = true
  end
end)
