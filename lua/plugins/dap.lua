return { 
   "mfussenegger/nvim-dap", 
  dependencies = {
    "rcarriga/nvim-dap-ui", 
    "nvim-neotest/nvim-nio",
  },
  config = function()
    local dap = require('dap')

    local dapui = require("dapui")
    dapui.setup()

    -- configure codelldb adapter
    dap.adapters.codelldb = {
      type = "server",
      port = "${port}",
      executable = {
        command = "codelldb",
        args = { "--port", "${port}" },
      },
    }

    dap.configurations.odin = {
      {
        type = 'codelldb',
        request = 'launch',
        name = "Launch file",
        program = "${workspaceFolder}/bin/debug",
        cwd = '${workspaceFolder}',
      },
    }

    vim.keymap.set("n", "<F1>", dap.step_over)
    vim.keymap.set("n", "<F2>", dap.step_into)
    vim.keymap.set("n", "<F3>", dap.step_out)
    vim.keymap.set("n", "<F4>", dap.continue)
    vim.keymap.set("n", "<F5>", dap.restart)
    vim.keymap.set("n", "<leader>?", function()
      dapui.eval(nil, { enter = true })
    end)
    vim.keymap.set("n", "<leader>B", dap.toggle_breakpoint)
    vim.keymap.set("n", "<leader>GB", dap.run_to_cursor)
  end
}
