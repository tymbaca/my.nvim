if vim.env.PROF then
  -- example for lazy.nvim
  -- change this to the correct path for your plugin manager
  local snacks = vim.fn.stdpath("data") .. "/lazy/snacks.nvim"
  vim.opt.rtp:append(snacks)
  require("snacks.profiler").startup({
    startup = {
      event = "VimEnter", -- stop profiler on this event. Defaults to `VimEnter`
      -- event = "UIEnter",
      -- event = "VeryLazy",
    },
  })
end

require("config.lazy")
require("config.filetype")
require("config.mappings")
require("config.colors")
vim.cmd [[source ~/.config/nvim/lua/config/init.vim]]

require("langmapper").automapping({ global = true, buffer = true })

-- per-region indentation in markdown: 2 spaces in prose, the block filetype's own
-- settings inside fenced code blocks, and per-block tab widths
require("config.mdtab").setup({
  -- e.g. javascript = { spaces = 2 }, make = { tabs = 4 }
  overrides = {},
})

require("config.neovide")
require("config.after")
