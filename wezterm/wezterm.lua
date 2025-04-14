-- WezTerm Configuration (Main File)
-- Documentation: https://wezfurlong.org/wezterm/config/files.html

local wezterm = require('wezterm')
local config = wezterm.config_builder()

-- Import modules
local utils = require('config.utils')
local appearance = require('config.appearance')
local fonts = require('config.fonts')
local keys = require('config.keys')
local general = require('config.general')
local events = require('config.events')

-- Apply configurations from modules
appearance.apply_to_config(config)
fonts.apply_to_config(config)
keys.apply_to_config(config)
general.apply_to_config(config)

-- Désactiver les events personnalisés pour éviter les conflits avec bar.wezterm
-- events.setup()

-- Import plugins (after basic configuration is set)
local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
local cmd_sender = wezterm.plugin.require("https://github.com/aureolebigben/wezterm-cmd-sender")

-- Configuration de bar.wezterm avec une approche différente
local bar_config = {
  position = "bottom",
  max_width = 32,
  dividers = "slant_right", -- Essayer un style différent

  -- Activer seulement quelques modules statiques
  clock = {
    enabled = true,
    format = "%H:%M",
  },
  leader = { enabled = true },
  tabs = {
    numerals = "arabic",
    pane_count = true,
    brackets = {
      active = { left = " ", right = " " },
      inactive = { left = " ", right = " " },
    },
  },

  -- Désactiver les modules qui pourraient causer des problèmes
  battery = { enabled = false },
  spotify = { enabled = false },
  workspace = { enabled = false },
  zoom = { enabled = false },
  pane = { enabled = false },
  username = { enabled = false },
  hostname = { enabled = false },
  cwd = { enabled = false },

  -- Paramètres avancés
  update_interval = 10000, -- 10 secondes entre les mises à jour
  force_kitty_cell_width = true, -- Peut aider avec certains problèmes d'affichage
}

-- Appliquer la configuration
bar.apply_to_config(config, bar_config)

-- Apply cmd-sender plugin
cmd_sender.apply_to_config(config, {
  default_mode = "current_pane", -- current_pane, all_panes, or all_tabs
  exit_mode_after_execution = true,
})

-- Return the configuration
return config
