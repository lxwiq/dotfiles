-- Font configuration for WezTerm
local wezterm = require('wezterm')
local utils = require('config.utils')

local M = {}

function M.apply_to_config(config)
  -- Font configuration optimisée pour bar.wezterm
  -- Utiliser une police Nerd Font pour les icônes si disponible
  -- Sinon, utiliser une police standard
  config.font = wezterm.font_with_fallback({
    { family = 'Hack Nerd Font', weight = 'Regular' },
    { family = 'Symbols Nerd Font Mono', weight = 'Regular' },
    { family = 'JetBrainsMono Nerd Font', weight = 'Regular' },
    { family = 'Menlo', weight = 'Regular' },
  })

  -- Font size (taille confortable)
  config.font_size = 12.0

  -- Line height
  config.line_height = 1.1

  -- Font features
  config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

  -- Font rendering
  -- Utiliser les options de rendu par défaut de WezTerm
  -- qui sont généralement optimales

  -- Font rules for specific text
  config.font_rules = {
    -- Bold text
    {
      intensity = 'Bold',
      font = wezterm.font_with_fallback({
        { family = 'Hack Nerd Font', weight = 'Bold' },
        { family = 'JetBrains Mono', weight = 'Bold' },
      }),
    },

    -- Italic text
    {
      italic = true,
      font = wezterm.font_with_fallback({
        { family = 'Hack Nerd Font', weight = 'Regular', italic = true },
        { family = 'JetBrains Mono', weight = 'Regular', italic = true },
      }),
    },

    -- Bold italic text
    {
      italic = true,
      intensity = 'Bold',
      font = wezterm.font_with_fallback({
        { family = 'Hack Nerd Font', weight = 'Bold', italic = true },
        { family = 'JetBrains Mono', weight = 'Bold', italic = true },
      }),
    },
  }

  -- Use cap height to scale fallback fonts
  config.use_cap_height_to_scale_fallback_fonts = true
end

return M
