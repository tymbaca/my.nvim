local M = {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    branch = 'master',
    config = function()
      local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

      parser_config.cql = {
        install_info = {
          url = "https://github.com/Akzestia/tree-sitter-cql", -- Parser repository
          files = { "src/parser.c" },                         -- Core parser file
          branch = "main", 
        },
        filetype = "cql", -- Associate with the cql filetype
      }

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
