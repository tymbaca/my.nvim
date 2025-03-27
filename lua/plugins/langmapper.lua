return {
  'Wansmer/langmapper.nvim',
  lazy = false,
  priority = 999, -- High priority is needed if you will use `autoremap()`
  config = function()
    require('langmapper').setup({
      hack_keymap = false,
    })
  end,
}
