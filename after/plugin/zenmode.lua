local zen = require("zen-mode")

vim.keymap.set("n", "<leader>z", function ()
  require("zen-mode").toggle({
  window = {
    width = .65 -- width will be 85% of the editor width
  }
})
end)
