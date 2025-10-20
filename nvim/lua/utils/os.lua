local M = {}
M.name = (vim.uv or vim.loop).os_uname().sysname
M.is_windows = M.name == 'Windows_NT'
M.is_mac = M.name == 'Darwin'
M.is_linux = M.name == 'Linux'
return M
