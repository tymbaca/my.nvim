local M = {}

M.filetype_to_query = {
  go = "func (",
  lua = "function",
}

function M.get_method_search_query(filetype)
  return M.filetype_to_query[filetype]
end

return M
