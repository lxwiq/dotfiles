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
    # Détection de Windows (via MSYS, Git Bash, Cygwin ou WSL)
    if [ -f /proc/version ]; then
        if grep -q Microsoft /proc/version; then
            echo "wsl"
            return
        fi
    fi

    if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
        return
    fi

    case "$(uname -s)" in
        Darwin*)
            echo "macos"
            ;;
        Linux*)
            # Détection de la distribution Linux
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                echo "linux-$ID"
            else
                echo "linux"
            fi
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

    # Créer le lien symbolique en fonction du système d'exploitation
    case "$OS" in
        windows)
            # Sous Windows (MSYS, Git Bash), utiliser mklink via cmd.exe
            # Convertir les chemins Unix en chemins Windows
            local win_source="$(cygpath -w "$source_file")"
            local win_target="$(cygpath -w "$target_file")"
            cmd.exe /c "mklink "$win_target" "$win_source"" > /dev/null 2>&1 || \
            cmd.exe /c "mklink /D "$win_target" "$win_source"" > /dev/null 2>&1
            ;;
        wsl)
            # Sous WSL, utiliser ln -sf
            ln -sf "$source_file" "$target_file"
            ;;
        *)
            # Sous macOS et Linux, utiliser ln -sf
            ln -sf "$source_file" "$target_file"
            ;;
    esac

    echo -e "${GREEN}Symlink created: $target_file -> $source_file${NC}"
}

# Répertoire des dotfiles (chemin absolu)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}Installing dotfiles from $DOTFILES_DIR${NC}"

# Créer les liens symboliques pour zsh
echo -e "\n${BLUE}Configuring zsh...${NC}"
create_symlink "$DOTFILES_DIR/zsh/zshrc" "$HOME/.config/zsh/zshrc"
create_symlink "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"

# Pas besoin de configurer starship car nous utilisons un prompt zsh natif

# Créer les liens symboliques pour WezTerm
echo -e "\n${BLUE}Configuring WezTerm...${NC}"

# Créer les répertoires de configuration WezTerm
mkdir -p "$HOME/.config/wezterm/config"

# Lier le fichier principal
create_symlink "$DOTFILES_DIR/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
create_symlink "$DOTFILES_DIR/wezterm/wezterm.lua" "$HOME/.wezterm.lua"

# Lier les fichiers de configuration modulaires
for config_file in "$DOTFILES_DIR"/wezterm/config/*.lua; do
  filename=$(basename "$config_file")
  create_symlink "$config_file" "$HOME/.config/wezterm/config/$filename"
done

# Installation de WezTerm si nécessaire
install_wezterm() {
    echo -e "\n${BLUE}Installing WezTerm...${NC}"

    case "$OS" in
        macos)
            if command -v brew &> /dev/null; then
                brew install --cask wezterm
            else
                echo -e "${YELLOW}Homebrew not installed. Installing WezTerm manually...${NC}"
                curl -LO https://github.com/wez/wezterm/releases/download/nightly/WezTerm-macos-nightly.zip
                unzip WezTerm-macos-nightly.zip
                mv WezTerm.app /Applications/
                rm WezTerm-macos-nightly.zip
            fi
            ;;
        linux-ubuntu|linux-debian|linux-pop)
            # Pour Ubuntu, Debian, Pop!_OS
            echo -e "${BLUE}Installing WezTerm for $OS...${NC}"
            curl -fsSL https://apt.fury.io/wez/gpg.key | sudo gpg --yes --dearmor -o /usr/share/keyrings/wezterm-fury.gpg
            echo "deb [signed-by=/usr/share/keyrings/wezterm-fury.gpg] https://apt.fury.io/wez/ * *" | sudo tee /etc/apt/sources.list.d/wezterm.list
            sudo apt update
            sudo apt install -y wezterm
            ;;
        linux-fedora)
            # Pour Fedora
            echo -e "${BLUE}Installing WezTerm for Fedora...${NC}"
            sudo dnf copr enable wez/wezterm
            sudo dnf install -y wezterm
            ;;
        linux-arch|linux-manjaro)
            # Pour Arch Linux et Manjaro
            echo -e "${BLUE}Installing WezTerm for $OS...${NC}"
            if command -v yay &> /dev/null; then
                yay -S wezterm
            else
                sudo pacman -S wezterm
            fi
            ;;
        windows|wsl)
            echo -e "${BLUE}For Windows, please download WezTerm from:${NC}"
            echo -e "${GREEN}https://wezfurlong.org/wezterm/installation.html${NC}"
            echo -e "${BLUE}Or install with:${NC}"
            echo -e "${GREEN}winget install wez.wezterm${NC}"
            echo -e "${GREEN}scoop install wezterm${NC}"
            echo -e "${GREEN}choco install wezterm${NC}"
            ;;
        *)
            echo -e "${YELLOW}Please install WezTerm manually from:${NC}"
            echo -e "${GREEN}https://wezfurlong.org/wezterm/installation.html${NC}"
            ;;
    esac
}

# Vérifier si WezTerm est installé
if ! command -v wezterm &> /dev/null && [ "$OS" != "windows" ]; then
    echo -e "\n${BLUE}WezTerm not found. Would you like to install it? (y/n)${NC}"
    read -r install_wezterm_choice
    if [[ "$install_wezterm_choice" =~ ^[Yy]$ ]]; then
        install_wezterm
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

# Nous utilisons un prompt zsh natif, pas besoin d'installer Starship

echo -e "\n${GREEN}Configuration complete!${NC}"

# Instructions spécifiques au système d'exploitation
case "$OS" in
    windows)
        echo -e "${BLUE}To apply changes on Windows:${NC}"
        echo -e "${GREEN}1. Restart your terminal${NC}"
        echo -e "${GREEN}2. Make sure WezTerm is installed${NC}"
        echo -e "${GREEN}3. If using Git Bash or MSYS, you may need to run 'source ~/.zshrc'${NC}"
        ;;
    wsl)
        echo -e "${BLUE}To apply changes on WSL:${NC}"
        echo -e "${GREEN}1. Restart your terminal or run: source ~/.zshrc${NC}"
        echo -e "${GREEN}2. Make sure WezTerm is installed on Windows${NC}"
        ;;
    *)
        echo -e "${BLUE}To apply changes, restart your terminal or run:${NC}"
        echo -e "${GREEN}source ~/.zshrc${NC}"
        ;;
esac

# Suggestion de changer le shell par défaut (sauf sur Windows)
if [ "$OS" != "windows" ] && [ "$SHELL" != "$(which zsh)" ]; then
    echo -e "\n${YELLOW}Your default shell is not zsh. To change it, run:${NC}"

    case "$OS" in
        macos)
            echo -e "${GREEN}chsh -s $(which zsh)${NC}"
            echo -e "${BLUE}Note: You may need to add $(which zsh) to /etc/shells first${NC}"
            ;;
        linux*)
            echo -e "${GREEN}chsh -s $(which zsh)${NC}"
            echo -e "${BLUE}Or: sudo usermod -s $(which zsh) $(whoami)${NC}"
            ;;
        wsl)
            echo -e "${GREEN}chsh -s $(which zsh)${NC}"
            ;;
    esac
fi

# Instructions pour Windows
if [ "$OS" = "windows" ]; then
    echo -e "\n${BLUE}Windows-specific notes:${NC}"
    echo -e "${GREEN}1. For WezTerm, make sure the config files are in:${NC}"
    echo -e "${GREEN}   %USERPROFILE%\.wezterm.lua${NC}"
    echo -e "${GREEN}   %USERPROFILE%\.config\wezterm\${NC}"
    echo -e "${GREEN}2. For zsh, you'll need to install it via MSYS2, Cygwin, or WSL${NC}"
fi
