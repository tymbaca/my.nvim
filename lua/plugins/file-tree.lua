return {
  -- {
  --   "nvim-tree/nvim-tree.lua",
  --   version = "*",
  --   lazy = false,
  --   dependencies = {
  --     "nvim-tree/nvim-web-devicons",
  --   },
  --   config = function()
  --     -- disable netrw at the very start of your init.lua
  --     vim.g.loaded_netrw = 1
  --     vim.g.loaded_netrwPlugin = 1
  --
  --     require("nvim-tree").setup {
  --       view = {
  --         width = '30%',
  --       },
  --       update_focused_file = {
  --         enable = true,
  --       },
  --     }
  --   end,
  --   keys = {
  --     { "<leader>e", "<cmd>NvimTreeToggle<cr>" },
  --     { "<leader>E", "<cmd>NvimTreeFindFile<cr>" },
  --   },
  -- }

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons", -- optional, but recommended
    },
    lazy = false,                    -- neo-tree will lazily load itself
    keys = {
      { "<leader>e", "<cmd>Neotree toggle<cr>" },
      { "<leader>E", "<cmd>Neotree reveal<cr>" },
      { "<leader>D", "<cmd>Neotree diagnostics<cr>" },
      { "<leader>o", "<cmd>Neotree document_symbols<cr>" },
    },

    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,

    ---@module 'neo-tree'
    ---@type neotree.Config
    opts = {
      enable_diagnostics = false,
      sources = { "filesystem", "buffers", "git_status", "document_symbols", "diagnostics" },
      window = {
        width = "30%",
        position = "left",
      },
      filesystem = {
        follow_current_file = {
          enabled = true,         -- This will find and focus the file in the active buffer every time
          --               -- the current file is changed while the tree is open.
          leave_dirs_open = true, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
        },
        hijack_netrw_behavior = "open_default",
        window = {
          mappings = {
            ["/"] = "noop",
          },
        }
      },
      default_component_configs = {
        last_modified = { enabled = false },
      },
    },
  },
  {
    "mrbjarksen/neo-tree-diagnostics.nvim",
    dependencies = { "nvim-neo-tree/neo-tree.nvim" },
  }
}
