local map = vim.keymap.set

vim.g.mapleader = " "
-- map("n", "<leader>e", vim.cmd.Ex) -- Jump to file tree
map('n', ';', vim.cmd.noh)                   -- Cancel search highlighting

map('n', 'gp', function() vim.cmd("b#") end) -- Jump to previous buffer

-- Fast escape from normal mode
map('i', 'jk', function() vim.cmd("stopinsert") end)

-- Move selected lines
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- Centered half-page move
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")

-- greatest remap ever
map("x", "<leader>p", [["_dP]])

-- next greatest remap ever : asbjornHaland
map({ "n", "v" }, "<leader>y", [["+y]])
map("n", "<leader>Y", [["+Y]])

map("n", "<leader>s{", [[@s]])

map("n", "<leader>w", "<cmd>w<cr>")
map("n", "<leader>W", "<cmd>wall<cr>")
map("n", "<leader>ц", "<cmd>w<cr>")

map("n", "<C-q><C-q>", "<cmd>wqall<cr>")

map("i", "<S-CR>", "<ESC>O")

map("n", "Ж", ":")

map("n", "]c", "<cmd>cnext<cr>")
map("n", "[c", "<cmd>cprev<cr>")

map({ "n", "v" }, "$", "g_")
map({ "n", "v" }, "^", "^")
map({ "n", "v" }, "gh", "^")
map({ "n", "v" }, "gj", "G")
map({ "n", "v" }, "gk", "gg")
map({ "n", "v" }, "gl", "g_")

map("i", "<M-,>", "<><Esc>i")
map("n", "<leader>R", function()
  local word = vim.fn.expand("<cword>")
  vim.api.nvim_feedkeys(":%s/" .. word .. "/" .. word, 'n', false)
end)

map("n", "<leader>m", "<cmd>make<cr>")

vim.cmd("map [[ [m")
vim.cmd("map ]] ]m")
vim.cmd("map {{ [{")
vim.cmd("map }} ]}")

vim.cmd [[
vnoremap <C-r> "hy:s/<C-r>h/<C-r>h/g<left><left>
vnoremap <S-r> "hy:%s/<C-r>h/<C-r>h/g<left><left>
]]

local switch_case = require 'config.switch-case'

map('n', '<Leader>cs', switch_case.switch_case,
  { noremap = true, silent = true })
