-- WezTerm Configuration
-- Documentation: https://wezfurlong.org/wezterm/config/files.html

local wezterm = require('wezterm')
local act = wezterm.action

-- Configuration table
local config = {}

-- Use config builder object if available (newer versions of WezTerm)
if wezterm.config_builder then
  config = wezterm.config_builder()
end

-- Status bar functions
wezterm.on('update-right-status', function(window, pane)
  -- Get current date and time
  local date = wezterm.strftime('%Y-%m-%d %H:%M:%S')

  -- Get current working directory
  local cwd_uri = pane:get_current_working_dir()
  local cwd = ''
  if cwd_uri then
    cwd_uri = cwd_uri:sub(8) -- Remove file:// prefix
    local slash = cwd_uri:find('/')
    if slash then
      -- Remove the host name part
      cwd = cwd_uri:sub(slash)
      -- Replace home directory with ~
      local home = os.getenv('HOME')
      if home then
        cwd = cwd:gsub('^' .. home, '~')
      end
    end
  end

  -- Get current command
  local process_name = pane:get_foreground_process_name()
  if process_name then
    -- Extract just the basename from the path
    local basename = string.match(process_name, '[^/\\]+$')
    if basename then
      process_name = basename
    end
  end

  -- Format status line similar to tmux
  local status = string.format(' %s | %s | %s ', process_name or '', cwd, date)

  -- Set the status
  window:set_right_status(wezterm.format({
    { Foreground = { Color = '#eeeeee' } },
    { Background = { Color = '#333333' } },
    { Text = status },
  }))
end)

-- General settings
config.automatically_reload_config = true
config.check_for_updates = true
config.scrollback_lines = 10000
config.enable_scroll_bar = false
config.window_close_confirmation = 'NeverPrompt'
config.window_padding = {
  left = 5,
  right = 5,
  top = 5,
  bottom = 5,
}

-- Font configuration
config.font = wezterm.font_with_fallback({
  'JetBrains Mono',
  'Hack Nerd Font',
  'Menlo',
})
config.font_size = 13.0
config.line_height = 1.1
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' } -- Disable ligatures

-- Color scheme
config.color_scheme = 'Catppuccin Mocha' -- A popular modern theme
config.window_background_opacity = 0.95

-- Tab bar (tmux style)
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false
config.tab_bar_at_bottom = true
config.show_tab_index_in_tab_bar = true
config.tab_max_width = 25
config.status_update_interval = 1000

-- Custom tab bar colors (tmux style)
config.colors = {
  tab_bar = {
    background = '#1a1b26',
    active_tab = {
      bg_color = '#7aa2f7',
      fg_color = '#1a1b26',
      intensity = 'Bold',
    },
    inactive_tab = {
      bg_color = '#24283b',
      fg_color = '#a9b1d6',
    },
    inactive_tab_hover = {
      bg_color = '#414868',
      fg_color = '#c0caf5',
    },
    new_tab = {
      bg_color = '#1a1b26',
      fg_color = '#a9b1d6',
    },
    new_tab_hover = {
      bg_color = '#414868',
      fg_color = '#c0caf5',
    },
  },
}

-- Cursor
config.default_cursor_style = 'SteadyBlock'
config.cursor_blink_rate = 800

-- Keys
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }


-- Mouse bindings
config.mouse_bindings = {
  -- Right click pastes from the clipboard
  {
    event = { Down = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = act.PasteFrom 'Clipboard',
  },
  -- Change the default click behavior so that it only selects text and doesn't open hyperlinks
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'ClipboardAndPrimarySelection',
  },
  -- Ctrl-click to open hyperlinks
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  },
}

-- Domains (SSH, etc.)
-- Uncomment and customize if you want to set up SSH connections
-- config.ssh_domains = {
--   {
--     name = 'my-server',
--     remote_address = 'user@hostname',
--     multiplexing = 'None', -- or 'WezTerm' for connection sharing
--   },
-- }

-- Launch menu
config.launch_menu = {
  {
    label = 'Bash',
    args = { 'bash', '-l' },
  },
  {
    label = 'Zsh',
    args = { 'zsh', '-l' },
  },
}

-- Return the configuration
return config
