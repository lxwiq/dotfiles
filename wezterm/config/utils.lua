-- Utility functions for WezTerm configuration
local wezterm = require('wezterm')

local M = {}

-- Detect OS
M.is_macos = string.find(wezterm.target_triple, 'apple') ~= nil
M.is_windows = string.find(wezterm.target_triple, 'windows') ~= nil
M.is_linux = string.find(wezterm.target_triple, 'linux') ~= nil

-- Get system appearance (dark/light mode)
function M.get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end
  return 'Dark'
end

-- Check if dark mode is active
function M.is_dark_mode()
  return M.get_appearance():find('Dark') ~= nil
end

-- Get home directory
function M.get_home()
  if M.is_windows then
    return os.getenv('USERPROFILE')
  end
  return os.getenv('HOME')
end

-- Join path components
function M.join_path(...)
  local path_sep = M.is_windows and '\\' or '/'
  local result = table.concat({...}, path_sep)
  return result
end

-- Log a message to the debug console
function M.log(message)
  wezterm.log_info(message)
end

-- Get hostname
function M.get_hostname()
  local success, stdout, stderr = wezterm.run_child_process({'hostname'})
  if success then
    -- Trim whitespace
    return stdout:gsub("^%s*(.-)%s*$", "%1")
  end
  return 'unknown-host'
end

-- Get username
function M.get_username()
  if M.is_windows then
    return os.getenv('USERNAME')
  end
  return os.getenv('USER')
end

-- Format bytes to human-readable string
function M.format_bytes(bytes)
  local units = {'B', 'KB', 'MB', 'GB', 'TB'}
  local size = bytes
  local unit_index = 1
  
  while size > 1024 and unit_index < #units do
    size = size / 1024
    unit_index = unit_index + 1
  end
  
  return string.format("%.1f %s", size, units[unit_index])
end

return M
