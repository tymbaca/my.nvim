local orig_notify = vim.notify
local filter_notify = function(text, level, opts)
  if type(text) == "string" and string.find(text, "is deprecated", 1, true) then
    return
  end
  if type(text) == "string" and string.find(text, "Defaulting to", 1, true) then
    return
  end

  orig_notify(text, level, opts)
end
vim.notify = filter_notify
vim.deprecate = function() end

--
-- require("transparent")
-- vim.cmd("!sleep 1")
-- vim.cmd("TransparentDisable")
-- vim.cmd("!sleep 1")
-- vim.cmd("TransparentEnable")
