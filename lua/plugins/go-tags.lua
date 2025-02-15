return {
  'devkvlt/go-tags.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('go-tags').setup({
      commands = {
        ['GoTagsAddJSON'] = { '-add-tags', 'json' },
        ['GoTagsRemoveJSON'] = { '-remove-tags', 'json' },
      },
    })

    vim.keymap.set('n', "<leader>Gtj", "<cmd>GoTagsAddJSON<cr>", { desc = "Add json tags" })
    vim.keymap.set('n', "<leader>Gtr", "<cmd>GoTagsRemoveJSON<cr>", { desc = "Remove json tags" })
  end
}
