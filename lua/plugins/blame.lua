return {
  "FabijanZulj/blame.nvim",
  cmd = { "BlameToggle" },
  config = function()
    require("blame").setup({
      date_format = "%d.%m.%Y",
      virtual_style = "right_align",
      views = {
        window = window_view,
        virtual = virtual_view,
        default = window_view,
      },
      focus_blame = true,
      merge_consecutive = false,
      max_summary_width = 30,
      colors = nil,
      blame_options = nil,
      commit_detail_view = "vsplit",
      format_fn = require("blame.formats.default_formats").date_message,
      mappings = {
        commit_info = "K",
        stack_push = "<TAB>",
        stack_pop = "<BS>",
        show_commit = "<CR>",
        close = { "<esc>", "q" },
      }
    })
  end,
  -- opts = {
  --   date_format = "%d.%m.%Y",
  --   virtual_style = "right",
  --   merge_consecutive = false,
  --   max_summary_width = 30,
  --   colors = nil,
  --   commit_detail_view = "vsplit",
  --   mappings = {
  --     commit_info = "K",
  --     stack_push = "<TAB>",
  --     stack_pop = "<BS>",
  --     show_commit = "<CR>",
  --     close = { "<esc>", "q" },
  --   }
  -- },
  keys = {
    { "<leader>b", "<cmd>BlameToggle window<cr>" },
    -- { "<leader>b", "<cmd>BlameToggle virtual<cr>" },
  },
}
