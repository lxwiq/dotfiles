#!/bin/bash

# Script d'installation pour les dotfiles
# Crée des liens symboliques pour les fichiers de configuration

# Couleurs pour les messages
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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
        echo -e "${BLUE}Fichier existant sauvegardé dans $backup_dir/$(basename "$target_file")${NC}"
    fi
    
    # Créer le répertoire parent si nécessaire
    mkdir -p "$(dirname "$target_file")"
    
    # Créer le lien symbolique
    ln -sf "$source_file" "$target_file"
    echo -e "${GREEN}Lien symbolique créé : $target_file -> $source_file${NC}"
}

# Répertoire des dotfiles (chemin absolu)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}Installation des dotfiles depuis $DOTFILES_DIR${NC}"

# Créer les liens symboliques pour zsh
echo -e "\n${BLUE}Configuration de zsh...${NC}"
create_symlink "$DOTFILES_DIR/zsh/zshrc" "$HOME/.config/zsh/zshrc"
create_symlink "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"

# Créer les liens symboliques pour tmux
echo -e "\n${BLUE}Configuration de tmux...${NC}"
create_symlink "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.config/tmux/tmux.conf"

# Créer les liens symboliques pour alacritty
echo -e "\n${BLUE}Configuration d'alacritty...${NC}"
for file in "$DOTFILES_DIR"/alacritty/*.toml; do
    filename=$(basename "$file")
    create_symlink "$file" "$HOME/.config/alacritty/$filename"
done

# Vérifier si les plugins tmux sont installés
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    echo -e "\n${BLUE}Installation du gestionnaire de plugins tmux (tpm)...${NC}"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    echo -e "${GREEN}tpm installé. N'oubliez pas d'appuyer sur prefix + I dans tmux pour installer les plugins.${NC}"
fi

# Vérifier si Oh My Zsh est installé
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo -e "\n${BLUE}Installation de Oh My Zsh...${NC}"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    echo -e "${GREEN}Oh My Zsh installé.${NC}"
fi

# Vérifier si les plugins zsh sont installés
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

# Plugin zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo -e "\n${BLUE}Installation du plugin zsh-autosuggestions...${NC}"
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

# Plugin zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo -e "\n${BLUE}Installation du plugin zsh-syntax-highlighting...${NC}"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Vérifier si Oh My Posh est installé
if ! command -v oh-my-posh &> /dev/null; then
    echo -e "\n${BLUE}Installation de Oh My Posh...${NC}"
    if command -v brew &> /dev/null; then
        brew install jandedobbeleer/oh-my-posh/oh-my-posh
    else
        echo -e "${RED}Homebrew n'est pas installé. Veuillez installer Oh My Posh manuellement.${NC}"
    fi
fi

# Vérifier si lsd est installé
if ! command -v lsd &> /dev/null; then
    echo -e "\n${BLUE}Installation de lsd...${NC}"
    if command -v brew &> /dev/null; then
        brew install lsd
    else
        echo -e "${RED}Homebrew n'est pas installé. Veuillez installer lsd manuellement.${NC}"
    fi
fi

# Vérifier si fzf est installé
if ! command -v fzf &> /dev/null; then
    echo -e "\n${BLUE}Installation de fzf...${NC}"
    if command -v brew &> /dev/null; then
        brew install fzf
        $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc
    else
        echo -e "${RED}Homebrew n'est pas installé. Veuillez installer fzf manuellement.${NC}"
    fi
fi

echo -e "\n${GREEN}Installation terminée !${NC}"
echo -e "${BLUE}Pour appliquer les changements, redémarrez votre terminal ou exécutez :${NC}"
echo -e "${GREEN}source ~/.zshrc${NC}"
