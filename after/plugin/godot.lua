require("lspconfig")["gdscript"].setup({
  name = "godot",
  cmd = vim.lsp.rpc.connect("127.0.0.1", "6005"),
})

local dap = require("dap")
dap.adapters.godot = {
  type = "server",
  host = "127.0.0.1",
  port = 6006,
}

dap.configurations.gdscript = {
  {
    type = "godot",
    request = "launch",
    name = "Launch scene",
    project = "${workspaceFolder}",
    launch_scene = true,
  },
}
