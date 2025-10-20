local osutil = require 'utils.os'
local M = {}

function M.normalize(path)
  path = vim.fs.normalize(path)
  if osutil.is_windows then
    path = path:gsub('^%a', string.lower)
  end
  return path
end

return M
