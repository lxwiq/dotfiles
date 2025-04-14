#!/bin/bash

# Script d'installation pour les dotfiles
# Crée des liens symboliques pour les fichiers de configuration
# Compatible avec macOS, Linux et WSL

# Couleurs pour les messages
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Détection du système d'exploitation
detect_os() {
    if [ -f /proc/version ]; then
        if grep -q Microsoft /proc/version; then
            echo "wsl"
            return
        fi
    fi

    case "$(uname -s)" in
        Darwin*)
            echo "macos"
            ;;
        Linux*)
            echo "linux"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

OS=$(detect_os)
echo -e "${BLUE}Système détecté : ${GREEN}$(uname -s) (${OS})${NC}"

# Fonction pour créer un lien symbolique
create_symlink() {
    local source_file="$1"
    local target_file="$2"
    local backup_dir="$HOME/.dotfiles_backup/$(date +%Y%m%d_%H%M%S)"

    # Vérifier si le fichier cible existe déjà
    if [ -e "$target_file" ]; then
        # Créer le répertoire de sauvegarde si nécessaire
        mkdir -p "$backup_dir"

        # Sauvegarder le fichier existant
        mv "$target_file" "$backup_dir/$(basename "$target_file")"
        echo -e "${BLUE}Existing file backed up to $backup_dir/$(basename "$target_file")${NC}"
    fi

    # Créer le répertoire parent si nécessaire
    mkdir -p "$(dirname "$target_file")"

    # Créer le lien symbolique
    ln -sf "$source_file" "$target_file"
    echo -e "${GREEN}Symlink created: $target_file -> $source_file${NC}"
}

# Répertoire des dotfiles (chemin absolu)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}Installing dotfiles from $DOTFILES_DIR${NC}"

# Créer les liens symboliques pour zsh
echo -e "\n${BLUE}Configuring zsh...${NC}"
create_symlink "$DOTFILES_DIR/zsh/zshrc" "$HOME/.config/zsh/zshrc"
create_symlink "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"

# Créer les liens symboliques pour starship
echo -e "\n${BLUE}Configuring starship...${NC}"
create_symlink "$DOTFILES_DIR/starship.toml" "$HOME/.config/starship.toml"

# Créer les liens symboliques pour WezTerm
echo -e "\n${BLUE}Configuring WezTerm...${NC}"
create_symlink "$DOTFILES_DIR/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
create_symlink "$DOTFILES_DIR/wezterm/wezterm.lua" "$HOME/.wezterm.lua"

# Installation de WezTerm si nécessaire
if ! command -v wezterm &> /dev/null; then
    echo -e "\n${BLUE}WezTerm not found. Would you like to install it? (y/n)${NC}"
    read -r install_wezterm
    if [[ "$install_wezterm" =~ ^[Yy]$ ]]; then
        case "$OS" in
            macos)
                if command -v brew &> /dev/null; then
                    brew install --cask wezterm
                else
                    echo -e "${YELLOW}Homebrew not installed. Please install WezTerm manually from https://wezfurlong.org/wezterm/installation.html${NC}"
                fi
                ;;
            linux)
                echo -e "${YELLOW}Please install WezTerm manually from https://wezfurlong.org/wezterm/installation.html${NC}"
                ;;
            *)
                echo -e "${YELLOW}Please install WezTerm manually from https://wezfurlong.org/wezterm/installation.html${NC}"
                ;;
        esac
    fi
fi

# Créer le répertoire pour les plugins zsh
mkdir -p "$HOME/.zsh"

# Plugin zsh-autosuggestions
if [ ! -d "$HOME/.zsh/zsh-autosuggestions" ]; then
    echo -e "\n${BLUE}Installing zsh-autosuggestions plugin...${NC}"
    git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.zsh/zsh-autosuggestions"
fi

# Plugin zsh-syntax-highlighting
if [ ! -d "$HOME/.zsh/zsh-syntax-highlighting" ]; then
    echo -e "\n${BLUE}Installing zsh-syntax-highlighting plugin...${NC}"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.zsh/zsh-syntax-highlighting"
fi

# Installation de Starship
if ! command -v starship &> /dev/null; then
    echo -e "\n${BLUE}Installing Starship prompt...${NC}"
    curl -sS https://starship.rs/install.sh | sh -s -- -y
    echo -e "${GREEN}Starship installed successfully.${NC}"
fi

echo -e "\n${GREEN}Configuration complete!${NC}"
echo -e "${BLUE}To apply changes, restart your terminal or run:${NC}"
echo -e "${GREEN}source ~/.zshrc${NC}"

# Suggestion de changer le shell par défaut
if [ "$SHELL" != "$(which zsh)" ]; then
    echo -e "\n${YELLOW}Your default shell is not zsh. To change it, run:${NC}"
    echo -e "${GREEN}chsh -s $(which zsh)${NC}"
fi
