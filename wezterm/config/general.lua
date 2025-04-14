-- General settings for WezTerm
local wezterm = require('wezterm')
local utils = require('config.utils')

local M = {}

function M.apply_to_config(config)
  -- General settings
  config.automatically_reload_config = false -- Désactiver le rechargement automatique
  config.check_for_updates = false -- Désactiver les vérifications de mises à jour
  config.scrollback_lines = 10000
  config.enable_scroll_bar = true
  config.min_scroll_bar_height = "2cell"
  config.exit_behavior = "Close"

  -- Réduire les mises à jour de l'interface
  config.status_update_interval = 10000 -- 10 secondes entre les mises à jour

  -- Terminal settings
  config.term = "wezterm"
  config.warn_about_missing_glyphs = false
  config.enable_kitty_graphics = true
  config.treat_east_asian_ambiguous_width_as_wide = true
  config.allow_square_glyphs_to_overflow_width = "Always"
  config.cell_width = 1.0

  -- Improve text rendering
  config.freetype_load_target = "Light"
  config.freetype_render_target = "HorizontalLcd"

  -- Adjust underline position
  config.underline_thickness = 2.0
  config.underline_position = -4.0

  -- Taille de fenêtre modérée (ni trop grande, ni trop petite)
  config.initial_cols = 80
  config.initial_rows = 24

  -- Désactiver le mode plein écran au démarrage
  config.default_gui_startup_args = { 'start' }

  -- Désactiver la mémorisation de la taille de la fenêtre
  config.window_close_confirmation = "NeverPrompt"

  -- Adjust window size when changing font size
  config.adjust_window_size_when_changing_font_size = true

  -- Disable ligatures
  config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

  -- Clipboard settings
  config.selection_word_boundary = " \t\n{}[]()'\""

  -- Mouse settings
  config.hide_mouse_cursor_when_typing = true

  -- Hyperlinks
  config.hyperlink_rules = wezterm.default_hyperlink_rules()

  -- Add custom hyperlink rules
  table.insert(config.hyperlink_rules, {
    regex = [[\b[a-zA-Z0-9\-_]+/[a-zA-Z0-9\-_]+(?:#[a-zA-Z0-9\-_]+)?]],
    format = 'https://github.com/$0',
  })

  -- Launch menu
  config.launch_menu = {
    {
      label = "Bash",
      args = { "bash", "-l" },
    },
    {
      label = "Zsh",
      args = { "zsh", "-l" },
    },
    {
      label = "PowerShell",
      args = { "pwsh", "-l" },
    },
    {
      label = "Python",
      args = { "python", "-i" },
    },
    {
      label = "System Info",
      args = { "bash", "-c", "neofetch; read -p 'Press Enter to close...'" },
    },
  }

  -- Set environment variables
  config.set_environment_variables = {
    TERM = "xterm-256color",
    COLORTERM = "truecolor",
  }

  -- OS-specific settings
  if utils.is_macos then
    config.native_macos_fullscreen_mode = true
    config.macos_window_background_blur = 20
  end

  if utils.is_windows then
    config.default_prog = { "pwsh.exe", "-NoLogo" }
    config.win32_system_backdrop = "Acrylic"
  end

  if utils.is_linux then
    config.enable_wayland = true
  end
end

return M
