local M = {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    branch = 'master',
    config = function()
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "html", "odin", "zig", "go" },
        sync_install = false,
        highlight = { enable = true },
        -- indent = { enable = true },
      })
    end
  }
}

return { M }
