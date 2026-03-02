require("config.lazy")
require("config.filetype")
require("config.mappings")
require("config.colors")
vim.cmd [[source ~/.config/nvim/lua/config/init.vim]]

require("langmapper").automapping({ global = true, buffer = true })

require("config.neovide")
require("config.after")
