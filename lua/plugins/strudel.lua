local get_ext = function()
  return vim.fn.expand("%:e")
end

return {
  {
    "gruvw/strudel.nvim",
    build = "npm install",
    config = function()
      require("strudel").setup({
        ui = {
          -- Maximise the menu panel
          -- (optional, default: true)
          maximise_menu_panel = true,
          -- Hide the Strudel menu panel (and handle)
          -- (optional, default: false)
          hide_menu_panel = true,
          -- Hide the default Strudel top bar (controls)
          -- (optional, default: false)
          hide_top_bar = true,
          -- Hide the Strudel code editor
          -- (optional, default: false)
          hide_code_editor = false,
          -- Hide the Strudel eval error display under the editor
          -- (optional, default: false)
          hide_error_display = false,
        },
        update_on_save = true,
        sync_cursor = true,
        report_eval_errors = true,
        -- headless = true,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "javascript" },
        callback = function(ev)
          if get_ext() ~= "std" then
            return
          end
          vim.keymap.set({ "n" }, "<leader>st", "<cmd>silent StrudelToggle<cr>")
          vim.keymap.set({ "n" }, "<leader>su", "<cmd>silent StrudelUpdate<cr>")
          vim.keymap.set({ "n" }, "<leader>sl", "<cmd>silent StrudelLaunch<cr>")

          vim.keymap.set({ "n", "i" }, "<C-CR>", "<cmd>silent StrudelUpdate<cr>")
          vim.keymap.set({ "n", "i" }, "<C-.>", "<cmd>silent StrudelStop<cr>")
        end
      })
    end,
  }
}
