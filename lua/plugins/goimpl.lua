return {
  "edolphin-ydf/goimpl.nvim",
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-lua/popup.nvim',
    'nvim-telescope/telescope.nvim',
    'nvim-treesitter/nvim-treesitter',
  },
  config = function()
    require 'telescope'.load_extension 'goimpl'
    vim.keymap.set('n', '<leader>im', [[<cmd>lua require'telescope'.extensions.goimpl.goimpl{}<CR>]],
      { noremap = true, silent = true })
  end,
}
