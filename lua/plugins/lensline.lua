return {
  {
    'oribarilan/lensline.nvim',
    tag = '1.0.0', -- or: branch = 'release/1.x' for latest non-breaking updates
    event = 'LspAttach',
    config = function()
      local lensline = require("lensline")
      lensline.setup()
      lensline.disable()
    end,
    keys = {
      { "<leader>ll", "<cmd>LenslineToggle<cr>" }
    }
  },
}
