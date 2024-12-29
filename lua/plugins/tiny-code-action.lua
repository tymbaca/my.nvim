return {
  "rachartier/tiny-code-action.nvim",
  dependencies = {
    { "nvim-lua/plenary.nvim" },
    { "nvim-telescope/telescope.nvim" },
  },
  event = "LspAttach",
  config = function()
    require('tiny-code-action').setup({
      backend = "delta",
      backend_opts = {
        delta = {
          -- Header from delta can be quite large.
          -- You can remove them by setting this to the number of lines to remove
          header_lines_to_remove = 4,

          -- The arguments to pass to delta
          -- If you have a custom configuration file, you can set the path to it like so:
          -- args = {
          --     "--config" .. os.getenv("HOME") .. "/.config/delta/config.yml",
          -- }
          args = {
            -- "--use-colors",
            "--line-numbers",
          },
        },
      },
    })
  end
}
