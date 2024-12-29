return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    -- local lualine = require('lualine')
    -- lualine.setup {
    --   winbar = {
    --     lualine_a = { require 'doing.api'.status },
    --   },
    -- }

    local showed = false

    vim.o.laststatus = 0
    vim.o.cmdheight = 0

    if showed then
      -- lualine.hide({ place = { 'statusline', 'tabline', 'winbar' }, unhide = true })
      vim.o.cmdheight = 1
    end

    vim.keymap.set("n", "<leader>Ul", "<cmd>lua require 'lualine'.hide()<cr>")
    vim.keymap.set("n", "<leader>UL", function()
      if showed then
        -- lualine.hide({ place = { 'statusline', 'tabline', 'winbar' }, unhide = false })
        vim.o.cmdheight = 0
        showed = false
      else
        -- lualine.hide({ place = { 'statusline', 'tabline', 'winbar' }, unhide = true })
        vim.o.cmdheight = 1
        showed = true
      end
    end)
  end
}
