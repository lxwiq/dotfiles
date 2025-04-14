-- Events configuration for WezTerm
local wezterm = require('wezterm')
local utils = require('config.utils')

local M = {}

function M.setup()
  -- Update the status bar every second
  wezterm.on('update-right-status', function(window, pane)
    -- Get current date and time
    local date = wezterm.strftime('%Y-%m-%d %H:%M:%S')
    
    -- Get current working directory
    local cwd = ''
    local cwd_uri = pane:get_current_working_dir()
    
    -- Handle different versions of WezTerm
    if type(cwd_uri) == 'userdata' then
      -- Newer versions of WezTerm return an object
      if cwd_uri.file_path then
        cwd = cwd_uri.file_path
      end
    elseif type(cwd_uri) == 'string' then
      -- Older versions return a string
      cwd_uri = cwd_uri:sub(8) -- Remove file:// prefix
      local slash = cwd_uri:find('/')
      if slash then
        cwd = cwd_uri:sub(slash)
      end
    end
    
    -- Replace home directory with ~
    local home = os.getenv('HOME')
    if home and cwd then
      cwd = cwd:gsub('^' .. home, '~')
    end
    
    -- Format status line
    local status = string.format(' %s | %s ', cwd, date)
    
    -- Set the status
    window:set_right_status(wezterm.format({
      { Foreground = { Color = '#cdd6f4' } },
      { Background = { Color = '#181825' } },
      { Text = status },
    }))
  end)
  
  -- Handle window config reloaded
  wezterm.on('window-config-reloaded', function(window, pane)
    window:toast_notification('WezTerm', 'Configuration reloaded!', nil, 2000)
  end)
end

return M
