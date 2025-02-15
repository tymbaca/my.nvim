return {
  'Wansmer/sibling-swap.nvim',
  requires = { 'nvim-treesitter' },
  config = function()
    local sibling = require('sibling-swap')
    sibling.setup({
      allow_interline_swaps = false,
    })
    -- vim.keymap.set({ "i", "n" }, "<M-[>", sibling.swap_with_left)
    -- vim.keymap.set({ "i", "n" }, "<M-]>", sibling.swap_with_right)
  end,
}
