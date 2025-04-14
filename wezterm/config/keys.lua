-- Key bindings configuration for WezTerm
local wezterm = require('wezterm')
local act = wezterm.action
local utils = require('config.utils')

local M = {}

function M.apply_to_config(config)
  -- Leader key (CTRL+A, like tmux)
  config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

  -- Key bindings
  config.keys = {
    -- Pane management (similar to tmux)
    -- Split panes: Ctrl+A H for horizontal split, Ctrl+A V for vertical split
    { key = 'H', mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = 'V', mods = 'LEADER|SHIFT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

    -- Navigate between panes with hjkl keys: Ctrl+A hjkl
    { key = 'h', mods = 'LEADER', action = act.ActivatePaneDirection 'Left' },
    { key = 'j', mods = 'LEADER', action = act.ActivatePaneDirection 'Down' },
    { key = 'k', mods = 'LEADER', action = act.ActivatePaneDirection 'Up' },
    { key = 'l', mods = 'LEADER', action = act.ActivatePaneDirection 'Right' },

    -- Close pane: Ctrl+A x
    { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },

    -- Zoom pane: Ctrl+A z
    { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },

    -- Resize panes: Ctrl+A arrow keys
    { key = 'LeftArrow', mods = 'LEADER', action = act.AdjustPaneSize { 'Left', 5 } },
    { key = 'RightArrow', mods = 'LEADER', action = act.AdjustPaneSize { 'Right', 5 } },
    { key = 'UpArrow', mods = 'LEADER', action = act.AdjustPaneSize { 'Up', 3 } },
    { key = 'DownArrow', mods = 'LEADER', action = act.AdjustPaneSize { 'Down', 3 } },

    -- Rotate panes: Ctrl+A r
    { key = 'r', mods = 'LEADER', action = act.RotatePanes 'Clockwise' },

    -- Tab management
    -- New tab: Ctrl+A c
    { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },

    -- Next tab: Ctrl+A n
    { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },

    -- Previous tab: Ctrl+A p
    { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },

    -- Tab navigation: Ctrl+A [number]
    { key = '1', mods = 'LEADER', action = act.ActivateTab(0) },
    { key = '2', mods = 'LEADER', action = act.ActivateTab(1) },
    { key = '3', mods = 'LEADER', action = act.ActivateTab(2) },
    { key = '4', mods = 'LEADER', action = act.ActivateTab(3) },
    { key = '5', mods = 'LEADER', action = act.ActivateTab(4) },
    { key = '6', mods = 'LEADER', action = act.ActivateTab(5) },
    { key = '7', mods = 'LEADER', action = act.ActivateTab(6) },
    { key = '8', mods = 'LEADER', action = act.ActivateTab(7) },
    { key = '9', mods = 'LEADER', action = act.ActivateTab(-1) }, -- Last tab

    -- Close tab: Ctrl+A X
    { key = 'X', mods = 'LEADER|SHIFT', action = act.CloseCurrentTab { confirm = true } },

    -- Rename tab: Ctrl+A ,
    { key = ',', mods = 'LEADER', action = act.PromptInputLine {
      description = 'Enter new tab name',
      action = wezterm.action_callback(function(window, pane, line)
        if line then
          window:active_tab():set_title(line)
        end
      end),
    }},

    -- Copy mode (vi-like): Ctrl+A [
    { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },

    -- Paste from clipboard: Ctrl+A ]
    { key = ']', mods = 'LEADER', action = act.PasteFrom 'Clipboard' },

    -- Clear scrollback: Ctrl+A k
    { key = 'K', mods = 'LEADER|SHIFT', action = act.ClearScrollback 'ScrollbackAndViewport' },

    -- Reload configuration: Ctrl+A R
    { key = 'R', mods = 'LEADER|SHIFT', action = act.ReloadConfiguration },

    -- Font size
    { key = '+', mods = 'CTRL', action = act.IncreaseFontSize },
    { key = '-', mods = 'CTRL', action = act.DecreaseFontSize },
    { key = '0', mods = 'CTRL', action = act.ResetFontSize },

    -- Quick select mode: Ctrl+A s
    { key = 's', mods = 'LEADER', action = act.QuickSelect },

    -- Show launcher: Ctrl+A Space
    { key = 'Space', mods = 'LEADER', action = act.ShowLauncher },

    -- Toggle fullscreen: Ctrl+A f
    { key = 'f', mods = 'LEADER', action = act.ToggleFullScreen },

    -- Send CTRL-A to the terminal when pressing CTRL-A, CTRL-A
    { key = 'a', mods = 'LEADER', action = act.SendKey { key = 'a', mods = 'CTRL' } },

    -- cmd-sender plugin keybindings
    -- Enter command mode with Ctrl+A e
    { key = 'e', mods = 'LEADER', action = act.EmitEvent('cmd-sender:show') },
    -- Switch between modes with Ctrl+A m
    { key = 'm', mods = 'LEADER', action = act.EmitEvent('cmd-sender:switch-mode') },
  }

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

    -- Disable the 'Down' event of CTRL-Click to avoid weird program behaviors
    {
      event = { Down = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = act.Nop,
    },
  }
end

return M
