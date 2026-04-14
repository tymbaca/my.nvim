return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.8',
  dependencies = {
    'nvim-lua/plenary.nvim',
  },
  keys = {
    { "<leader>f",  "<cmd>Telescope find_files<cr>" },
    { "<leader>T",  "<cmd>Telescope<cr>" },
    { "<leader>sg", "<cmd>Telescope live_grep<cr>" },
    { "<leader>sb", function()
      vim.cmd("Telescope lsp_dynamic_workspace_symbols")
      -- if vim.bo.filetype == "go" then
      --   vim.cmd("Telescope lsp_dynamic_workspace_symbols")
      -- else
      --   vim.cmd("Telescope lsp_workspace_symbols")
      -- end
    end },
    { "gw",               "<cmd>Telescope grep_string<cr>" },
    { "<leader>mr",       "<cmd>Telescope marks<cr>" },
    -- { "<leader>sc",       function() require('telescope.builtin').colorscheme({ enable_preview = true }) end, desc = "[S]earch [C]olorschemes" },
    { '<leader><leader>', "<cmd>Telescope oldfiles<cr>" },
    { '<leader>gc',       "<cmd>Telescope git_bcommits<cr>",                                               desc = "Find [G]it this file [C]ommits" },
    { '<leader>gf',       "<cmd>Telescope git_files<cr>",                                                  desc = "Find [G]it [F]iles" },
    { '<leader>gc',       "<cmd>Telescope git_bcommits<cr>",                                               desc = "Find [G]it this file [C]ommits" },
    { '<leader>gC',       "<cmd>Telescope git_commits<cr>",                                                desc = "Find [G]it [C]ommits" },
    { '<leader>gb',       "<cmd>Telescope git_branches<cr>",                                               desc = "Find [G]it [B]ranches" },
    { '<leader>gk',       function() require("telescope.builtin").live_grep({ default_text = "<<<" }) end, desc = "Find [G]it [K]onflicts" },
    { '<leader>ls',       "<cmd>Telescope resume<cr>",                                                     desc = "[L]ast [S]earch" },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup {
      defaults = {
        preview = {
          filesize_limit = 0.1, -- MB
        },
      },
    }
  end
}
