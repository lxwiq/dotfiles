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

# Fonction pour installer un paquet selon le système d'exploitation
install_package() {
    local package_name="$1"
    local macos_cmd="$2"
    local debian_cmd="$3"
    local fedora_cmd="$4"
    local arch_cmd="$5"

    echo -e "\n${BLUE}Installing $package_name...${NC}"

    case "$OS" in
        macos)
            if command -v brew &> /dev/null; then
                eval "$macos_cmd"
            else
                echo -e "${YELLOW}Homebrew not installed. Please install it first:${NC}"
                echo -e "${YELLOW}/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"${NC}"
                return 1
            fi
            ;;
        linux|wsl)
            if command -v apt-get &> /dev/null; then
                # Debian/Ubuntu/WSL
                eval "$debian_cmd"
            elif command -v dnf &> /dev/null; then
                # Fedora/RHEL
                eval "$fedora_cmd"
            elif command -v pacman &> /dev/null; then
                # Arch Linux
                eval "$arch_cmd"
            else
                echo -e "${RED}Unsupported Linux distribution. Please install $package_name manually.${NC}"
                return 1
            fi
            ;;
        *)
            echo -e "${RED}Unsupported operating system. Please install $package_name manually.${NC}"
            return 1
            ;;
    esac

    echo -e "${GREEN}$package_name installed successfully.${NC}"
    return 0
}

# Répertoire des dotfiles (chemin absolu)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}Installing dotfiles from $DOTFILES_DIR${NC}"

# Créer les liens symboliques pour zsh
echo -e "\n${BLUE}Configuring zsh...${NC}"
create_symlink "$DOTFILES_DIR/zsh/zshrc" "$HOME/.config/zsh/zshrc"
create_symlink "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"

# Créer les liens symboliques pour tmux
echo -e "\n${BLUE}Configuring tmux...${NC}"
create_symlink "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"

# Créer les liens symboliques pour alacritty
echo -e "\n${BLUE}Configuring alacritty...${NC}"
for file in "$DOTFILES_DIR"/alacritty/*.toml; do
    filename=$(basename "$file")
    create_symlink "$file" "$HOME/.config/alacritty/$filename"
done

# Vérifier si les plugins tmux sont installés
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo -e "\n${BLUE}Installing tmux plugin manager (tpm)...${NC}"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    echo -e "${GREEN}tpm installed. Don't forget to press prefix + I in tmux to install plugins.${NC}"
fi

# Vérifier si Oh My Zsh est installé
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "\n${BLUE}Installing Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo -e "${GREEN}Oh My Zsh installed.${NC}"
fi

# Vérifier si les plugins zsh sont installés
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

# Plugin zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo -e "\n${BLUE}Installing zsh-autosuggestions plugin...${NC}"
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# Plugin zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo -e "\n${BLUE}Installing zsh-syntax-highlighting plugin...${NC}"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Installation de Oh My Posh
if ! command -v oh-my-posh &> /dev/null; then
    install_package "Oh My Posh" \
        "brew install jandedobbeleer/oh-my-posh/oh-my-posh" \
        "curl -s https://ohmyposh.dev/install.sh | bash -s" \
        "curl -s https://ohmyposh.dev/install.sh | bash -s" \
        "curl -s https://ohmyposh.dev/install.sh | bash -s"
fi

# Installation de lsd (ls deluxe)
if ! command -v lsd &> /dev/null; then
    install_package "lsd" \
        "brew install lsd" \
        "sudo apt-get update && sudo apt-get install -y lsd" \
        "sudo dnf install -y lsd" \
        "sudo pacman -S --noconfirm lsd"
fi

# Installation de fzf
if ! command -v fzf &> /dev/null; then
    install_package "fzf" \
        "brew install fzf && $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc" \
        "sudo apt-get update && sudo apt-get install -y fzf && echo 'y' | /usr/share/doc/fzf/examples/install" \
        "sudo dnf install -y fzf && echo 'y' | /usr/share/fzf/shell/install" \
        "sudo pacman -S --noconfirm fzf && echo 'y' | /usr/share/fzf/install"
fi

# Installation de tmux si nécessaire
if ! command -v tmux &> /dev/null; then
    install_package "tmux" \
        "brew install tmux" \
        "sudo apt-get update && sudo apt-get install -y tmux" \
        "sudo dnf install -y tmux" \
        "sudo pacman -S --noconfirm tmux"
fi

# Installation de zsh si nécessaire
if ! command -v zsh &> /dev/null; then
    install_package "zsh" \
        "brew install zsh" \
        "sudo apt-get update && sudo apt-get install -y zsh" \
        "sudo dnf install -y zsh" \
        "sudo pacman -S --noconfirm zsh"
fi

echo -e "\n${GREEN}Installation complete!${NC}"
echo -e "${BLUE}To apply changes, restart your terminal or run:${NC}"
echo -e "${GREEN}source ~/.zshrc${NC}"

# Suggestion de changer le shell par défaut
if [ "$SHELL" != "$(which zsh)" ]; then
    echo -e "\n${YELLOW}Your default shell is not zsh. To change it, run:${NC}"
    echo -e "${GREEN}chsh -s $(which zsh)${NC}"
fi
