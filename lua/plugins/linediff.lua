return {
  "AndrewRadev/linediff.vim",
  config = function()
    vim.keymap.set('v', '<leader>ld', "<cmd>'<,'>Linediff<cr>", { desc = "[L]ine [D]iff" })
  end,
}
