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
      { "<leader>O", "<cmd>Neotree document_symbols<cr>" },
    },
    init = function()
      -- disable netrw at the very start of your init.lua
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      vim.api.nvim_create_autocmd('BufEnter', {
        -- make a group to be able to delete it later
        group = vim.api.nvim_create_augroup('NeoTreeInit', { clear = true }),
        callback = function()
          local f = vim.fn.expand('%:p')
          if vim.fn.isdirectory(f) ~= 0 then
            vim.cmd('Neotree current dir=' .. f)
            -- neo-tree is loaded now, delete the init autocmd
            vim.api.nvim_clear_autocmds { group = 'NeoTreeInit' }
          end
        end
      })
    end,
    ---@module 'neo-tree'
    ---@type neotree.Config
    opts = {
      sources = { "filesystem", "buffers", "git_status", "document_symbols", },
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
        hijack_netrw_behavior = "disabled",
      },
      default_component_configs = {
        last_modified = { enabled = false },
      },
    },
  },
  {
    "antosha417/nvim-lsp-file-operations",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neo-tree/neo-tree.nvim", -- makes sure that this loads after Neo-tree.
    },
    config = function()
      require("lsp-file-operations").setup()
    end,
  },
}
