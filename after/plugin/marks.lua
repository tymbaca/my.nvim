require 'marks'.setup {
  -- whether to map keybinds or not. default true
  default_mappings = false,
  mappings = {
    toggle = "mm",
    next = "]m",
    delete_buf = "dam",
    prev = "[m", -- pass false to disable only this default mapping
  },
}
