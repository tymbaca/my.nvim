-- Neovide
-- vim.g.neovide_cursor_vfx_mode = "railgun"
if vim.g.neovide then
  vim.opt.linespace = 5
  vim.g.neovide_cursor_animation_length = 0.050
  vim.g.neovide_scroll_animation_length = 0.2

  -- vim.g.neovide_show_border = true
  vim.g.neovide_macos_simple_fullscreen = true
  vim.g.neovide_padding_top = 70
  -- vim.g.neovide_fullscreen = true

  vim.g.neovide_hide_mouse_when_typing = true
  vim.g.neovide_scale_factor = 1.0

  local change_scale_factor = function(delta)
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
  end
  vim.keymap.set("n", "<C-=>", function()
    change_scale_factor(1.05)
  end)
  vim.keymap.set("n", "<C-->", function()
    change_scale_factor(1 / 1.05)
  end)
  
  vim.keymap.set("n", "<D-CR>", function()
    vim.g.neovide_macos_simple_fullscreen = not vim.g.neovide_macos_simple_fullscreen
  end)

  vim.keymap.del("n", "<C-Q>d")

  vim.cmd [[
" Allow copy paste in neovide
let g:neovide_input_use_logo = 1
map <D-v> "+p<CR>
map! <D-v> <C-R>+
tmap <D-v> <C-R>+
vmap <D-c> "+y<CR> ]]
end
