-- vim.cmd.colorscheme('gruvbox')
vim.cmd.colorscheme('kanagawabones')
-- vim.cmd.colorscheme('zenwritten')
-- vim.cmd.colorscheme('forestbones')
-- vim.cmd.colorscheme('nordbones')
-- vim.cmd.colorscheme('randombones')
-- vim.cmd.colorscheme('zenburned')
-- vim.cmd.colorscheme('neobones')
-- vim.cmd.colorscheme('everforest')
-- vim.cmd.colorscheme('everforest')
-- vim.cmd.colorscheme('everforest')


vim.opt.guicursor = "i:ver100" -- Cursor Block style always
vim.o.nu = true
vim.wo.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50
