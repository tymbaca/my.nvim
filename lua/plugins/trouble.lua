return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
  config = function()
    require('trouble').setup({
      action_keys = { -- key mappings for actions in the trouble list
        -- map to {} to remove a mapping, for example:
        -- close = {},
        close = "q",                  -- close the list
        cancel = "<esc>",             -- cancel the preview and get back to your last window / buffer / cursor
        refresh = "r",                -- manually refresh
        jump = { "<cr>", "<tab>" },   -- jump to the diagnostic or open / close folds
        open_split = { "<c-x>" },     -- open buffer in new split
        open_vsplit = { "<c-v>" },    -- open buffer in new vsplit
        open_tab = { "<c-t>" },       -- open buffer in new tab
        jump_close = { "o" },         -- jump to the diagnostic and close the list
        toggle_mode = "m",            -- toggle between "workspace" and "document" diagnostics mode
        switch_severity = "s",        -- switch "diagnostics" severity filter level to HINT / INFO / WARN / ERROR
        toggle_preview = "P",         -- toggle auto_preview
        hover = "K",                  -- opens a small popup with the full multiline message
        preview = "p",                -- preview the diagnostic location
        close_folds = { "zM", "zm" }, -- close all folds
        open_folds = { "zR", "zr" },  -- open all folds
        toggle_fold = { "zA", "za" }, -- toggle fold of current file
        previous = "k",               -- previous item
        next = "j"                    -- next item
      },
    })

    vim.keymap.set('n', '<leader>tr', '<cmd>Trouble diagnostics toggle<cr>',
      { desc = 'Toggle [T][R]ouble workspace diagnostics' })

    vim.keymap.set('n', '<leader>to', '<cmd>Trouble todo toggle<cr>', { desc = 'Toggle [T]rouble [T]ODO' })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "trouble", "Trouble" },
      callback = function()
        vim.keymap.set("n", "<C-q>", function()
          local ok, trouble = pcall(require, "trouble")
          if not ok then return end

          local items = trouble.get_items()
          if not items or #items == 0 then
            vim.notify("No Trouble items to send to quickfix", vim.log.levels.WARN)
            return
          end

          -- Normalise Trouble items to quickfix-compatible entries
          local qf_items = {}
          for _, item in ipairs(items) do
            -- Prefer lnum/col, fall back to pos {row, col}
            local lnum = item.lnum
            local col  = item.col
            if (not lnum or lnum == 0) and item.pos then
              lnum = item.pos[1]
              col  = item.pos[2]
            end

            -- Quickfix requires lnum >= 1
            lnum = math.max(lnum or 1, 1)
            col  = math.max(col  or 1, 1)

            table.insert(qf_items, {
              filename = item.filename,          -- Trouble usually provides this
              lnum     = lnum,
              col      = col,
              text     = item.text or item.message or "",
            })
          end

          vim.fn.setqflist({}, " ", { title = "Trouble → Quickfix", items = qf_items })
          vim.cmd("copen")
          trouble.close()
        end, { buffer = true, desc = "Send Trouble list to Quickfix (normalised) and close Trouble" })
      end,
    })
  end,
}
