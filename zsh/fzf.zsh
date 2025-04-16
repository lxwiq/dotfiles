# fzf configuration for zsh
# This file enhances the default fzf integration with custom settings

# Setup fzf
# ---------
if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/opt/homebrew/opt/fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"

# Options
# -------
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"

# CTRL-R - Paste the selected command from history into the command line
# Enhanced with better preview and sorting
export FZF_CTRL_R_OPTS="
  --preview 'echo {}' 
  --preview-window up:3:hidden:wrap
  --bind 'ctrl-/:toggle-preview'
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command to clipboard'
  --sort"

# CTRL-T - Paste the selected file path(s) into the command line
export FZF_CTRL_T_OPTS="
  --preview 'bat --color=always --style=numbers --line-range=:500 {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

# ALT-C - cd into the selected directory
export FZF_ALT_C_OPTS="
  --preview 'ls -la {} | head -200'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

# Use fd (find alternative) if available
if command -v fd > /dev/null; then
  export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
fi
