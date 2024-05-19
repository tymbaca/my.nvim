require("blame").setup({
  date_format = "%d.%m.%Y",
  virtual_style = "right",
  merge_consecutive = false,
  max_summary_width = 30,
  colors = nil,
  commit_detail_view = "vsplit",
  mappings = {
    commit_info = "K",
    stack_push = "<TAB>",
    stack_pop = "<BS>",
    show_commit = "<CR>",
    close = { "<esc>", "q" },
  }
})

vim.keymap.set("n", "<leader>b", "<cmd>BlameToggle window<cr>")
