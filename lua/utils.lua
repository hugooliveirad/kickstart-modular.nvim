local M = {}

--- Get the parent branch using Graphite CLI, defaulting to 'main' on error.
--- @return string The parent branch name
function M.get_parent_branch()
  local result = vim.fn.systemlist('gt parent 2>/dev/null')
  if vim.v.shell_error ~= 0 or #result == 0 or result[1] == '' then
    return 'main'
  end
  return result[1]
end

return M
