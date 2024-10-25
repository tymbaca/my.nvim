-- Neovide
-- vim.g.neovide_cursor_vfx_mode = "railgun"
vim.g.neovide_fullscreen = true

vim.g.neovide_scale_factor = 1.0

local change_scale_factor = function(delta)
  vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
end
vim.keymap.set("n", "<C-=>", function()
  change_scale_factor(1.25)
end)
vim.keymap.set("n", "<C-->", function()
  change_scale_factor(1 / 1.25)
end)

vim.cmd [[
" Allow copy paste in neovide
let g:neovide_input_use_logo = 1
map <D-v> "+p<CR>
map! <D-v> <C-R>+
tmap <D-v> <C-R>+
vmap <D-c> "+y<CR>
]]
