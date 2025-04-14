-- Appearance configuration for WezTerm
local wezterm = require('wezterm')
local utils = require('config.utils')

local M = {}

function M.apply_to_config(config)
  -- Color scheme
  config.color_scheme = 'Catppuccin Mocha'

  -- Window appearance
  config.window_background_opacity = 0.95
  config.macos_window_background_blur = 20
  config.window_decorations = "TITLE | RESIZE"
  config.window_close_confirmation = "AlwaysPrompt"

  -- Allow square glyphs to overflow their cells
  config.allow_square_glyphs_to_overflow_width = "Always"

  -- Configuration minimale de la barre d'onglets (gérée par bar.wezterm)
  config.enable_tab_bar = true
  config.hide_tab_bar_if_only_one_tab = false
  config.use_fancy_tab_bar = false
  config.tab_bar_at_bottom = true

  -- Désactiver les fonctionnalités qui pourraient interférer avec bar.wezterm
  config.show_new_tab_button_in_tab_bar = false
  config.show_tab_index_in_tab_bar = false

  -- Couleurs simplifiées (bar.wezterm gère ses propres couleurs)
  config.colors = {

    -- Cursor colors
    cursor_bg = '#cba6f7',
    cursor_fg = '#11111b',
    cursor_border = '#cba6f7',

    -- Selection colors
    selection_fg = '#11111b',
    selection_bg = '#cba6f7',

    -- Split line color
    split = '#313244',

    -- Scrollbar color
    scrollbar_thumb = '#45475a',

    -- Visual bell
    visual_bell = '#cba6f7',
  }

  -- Visual bell (flash the screen instead of making a sound)
  config.audible_bell = "Disabled"
  config.visual_bell = {
    fade_in_duration_ms = 75,
    fade_out_duration_ms = 75,
    target = 'CursorColor',
  }

  -- Cursor style
  config.default_cursor_style = 'SteadyBlock'
  config.cursor_blink_rate = 800

  -- Window padding
  config.window_padding = {
    left = 10,
    right = 10,
    top = 10,
    bottom = 10,
  }

  -- Inactive pane styling
  config.inactive_pane_hsb = {
    saturation = 0.8,
    brightness = 0.7,
  }
end

return M
