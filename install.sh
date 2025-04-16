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

# Vérification et installation des dépendances
check_dependencies() {
    local missing_deps=()

    # Vérifier les dépendances essentielles
    echo -e "\n${BLUE}Vérification des dépendances...${NC}"
    for cmd in curl unzip git zsh; do
        if ! command -v $cmd &> /dev/null; then
            missing_deps+=("$cmd")
            echo -e "${YELLOW}Dépendance manquante: $cmd${NC}"
        else
            echo -e "${GREEN}✓ $cmd est installé${NC}"
        fi
    done

    # Installer les dépendances manquantes
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo -e "\n${YELLOW}Dépendances manquantes: ${missing_deps[*]}${NC}"
        echo -e "${BLUE}Installation des dépendances manquantes...${NC}"

        case "$OS" in
            linux-ubuntu|linux-debian|linux-pop|wsl)
                echo -e "${BLUE}Mise à jour des paquets...${NC}"
                sudo apt update
                echo -e "${BLUE}Installation des paquets: ${missing_deps[*]}${NC}"
                sudo apt install -y ${missing_deps[@]}
                ;;
            linux-fedora)
                sudo dnf install -y ${missing_deps[@]}
                ;;
            linux-arch|linux-manjaro)
                sudo pacman -S --needed ${missing_deps[@]}
                ;;
            macos)
                if command -v brew &> /dev/null; then
                    brew install ${missing_deps[@]}
                else
                    echo -e "${RED}Homebrew non trouvé. Veuillez installer les dépendances manuellement: ${missing_deps[*]}${NC}"
                    echo -e "${YELLOW}Pour installer Homebrew: /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"${NC}"
                fi
                ;;
            windows)
                echo -e "${YELLOW}Sur Windows, veuillez installer manuellement: ${missing_deps[*]}${NC}"
                ;;
        esac

        # Vérifier si l'installation a réussi
        local failed_deps=()
        for cmd in "${missing_deps[@]}"; do
            if ! command -v $cmd &> /dev/null; then
                failed_deps+=("$cmd")
            fi
        done

        if [ ${#failed_deps[@]} -gt 0 ]; then
            echo -e "\n${RED}Certaines dépendances n'ont pas pu être installées: ${failed_deps[*]}${NC}"
            echo -e "${YELLOW}Veuillez les installer manuellement avant de continuer.${NC}"
            read -p "Continuer quand même? (y/n) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo -e "${RED}Installation annulée.${NC}"
                exit 1
            fi
        else
            echo -e "\n${GREEN}Toutes les dépendances sont maintenant installées!${NC}"
        fi
    else
        echo -e "${GREEN}Toutes les dépendances sont déjà installées!${NC}"
    fi

    # Vérifier si les locales sont configurées correctement
    if [ "$OS" = "linux-ubuntu" ] || [ "$OS" = "linux-debian" ] || [ "$OS" = "linux-pop" ] || [ "$OS" = "wsl" ]; then
        if ! locale -a 2>/dev/null | grep -q "fr_FR.utf8"; then
            echo -e "\n${YELLOW}Locale française non trouvée. Configuration des locales...${NC}"
            sudo apt install -y locales
            sudo locale-gen fr_FR.UTF-8
            sudo update-locale LANG=fr_FR.UTF-8 LC_ALL=fr_FR.UTF-8
            echo -e "${GREEN}Locales configurées!${NC}"
        else
            echo -e "${GREEN}Locales françaises déjà configurées.${NC}"
        fi
    fi
}

OS=$(detect_os)
echo -e "${BLUE}Système détecté : ${GREEN}$(uname -s) (${OS})${NC}"

# Vérifier et installer les dépendances nécessaires
check_dependencies

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

# Configurer fzf pour zsh
mkdir -p "$HOME/.config/zsh"
create_symlink "$DOTFILES_DIR/zsh/fzf.zsh" "$HOME/.config/zsh/fzf.zsh"

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

# Installation de Hack Nerd Font
install_hack_nerd_font() {
    echo -e "\n${BLUE}Installation de Hack Nerd Font...${NC}"

    # Créer un répertoire temporaire
    local temp_dir="$(mktemp -d)"
    local font_zip="$temp_dir/Hack.zip"

    # Vérifier que curl est disponible
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}curl n'est pas installé. Impossible de télécharger la police.${NC}"
        echo -e "${YELLOW}Veuillez installer curl ou télécharger manuellement Hack Nerd Font depuis:${NC}"
        echo -e "${GREEN}https://www.nerdfonts.com/font-downloads${NC}"
        return 1
    fi

    # Vérifier que unzip est disponible
    if ! command -v unzip &> /dev/null; then
        echo -e "${RED}unzip n'est pas installé. Impossible d'extraire la police.${NC}"
        echo -e "${YELLOW}Veuillez installer unzip ou télécharger manuellement Hack Nerd Font depuis:${NC}"
        echo -e "${GREEN}https://www.nerdfonts.com/font-downloads${NC}"
        return 1
    fi

    # Télécharger la police
    echo -e "${BLUE}Téléchargement de Hack Nerd Font...${NC}"
    if ! curl -fsSL -o "$font_zip" "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Hack.zip"; then
        echo -e "${RED}Échec du téléchargement de Hack Nerd Font.${NC}"
        echo -e "${YELLOW}Veuillez vérifier votre connexion internet ou télécharger manuellement depuis:${NC}"
        echo -e "${GREEN}https://www.nerdfonts.com/font-downloads${NC}"
        rm -rf "$temp_dir"
        return 1
    fi

    # Extraire et installer la police
    if [ -f "$font_zip" ]; then
        echo -e "${BLUE}Extraction des fichiers de police...${NC}"
        if ! unzip -q "$font_zip" -d "$temp_dir"; then
            echo -e "${RED}Échec de l'extraction des fichiers de police.${NC}"
            rm -rf "$temp_dir"
            return 1
        fi

        # Vérifier que les fichiers TTF ont bien été extraits
        if ! ls "$temp_dir"/*.ttf &> /dev/null; then
            echo -e "${RED}Aucun fichier TTF trouvé après l'extraction.${NC}"
            rm -rf "$temp_dir"
            return 1
        fi

        case "$OS" in
            macos)
                # Installer sur macOS
                echo -e "${BLUE}Installation des polices sur macOS...${NC}"
                mkdir -p "$HOME/Library/Fonts"
                cp "$temp_dir"/*.ttf "$HOME/Library/Fonts/"
                echo -e "${GREEN}Polices installées dans $HOME/Library/Fonts/${NC}"
                ;;
            linux*|wsl)
                # Installer sur Linux/WSL
                echo -e "${BLUE}Installation des polices sur Linux...${NC}"
                mkdir -p "$HOME/.local/share/fonts/HackNerdFont"
                cp "$temp_dir"/*.ttf "$HOME/.local/share/fonts/HackNerdFont/"
                echo -e "${BLUE}Mise à jour du cache de polices...${NC}"
                if command -v fc-cache &> /dev/null; then
                    fc-cache -f -v > /dev/null
                    echo -e "${GREEN}Cache de polices mis à jour.${NC}"
                else
                    echo -e "${YELLOW}fc-cache non trouvé. Le cache de polices n'a pas été mis à jour.${NC}"
                fi
                echo -e "${GREEN}Polices installées dans $HOME/.local/share/fonts/HackNerdFont/${NC}"
                ;;
            windows)
                # Instructions pour Windows
                echo -e "${YELLOW}Pour Windows, veuillez installer les polices manuellement:${NC}"
                echo -e "${GREEN}1. Télécharger depuis: https://www.nerdfonts.com/font-downloads${NC}"
                echo -e "${GREEN}2. Extraire le fichier ZIP${NC}"
                echo -e "${GREEN}3. Sélectionner tous les fichiers TTF, faire un clic droit et sélectionner 'Installer'${NC}"
                ;;
        esac

        echo -e "${GREEN}Hack Nerd Font installée avec succès!${NC}"
    else
        echo -e "${RED}Échec du téléchargement de Hack Nerd Font.${NC}"
        echo -e "${YELLOW}Veuillez l'installer manuellement depuis: https://www.nerdfonts.com/font-downloads${NC}"
        rm -rf "$temp_dir"
        return 1
    fi

    # Nettoyer les fichiers temporaires
    rm -rf "$temp_dir"
    return 0
}

# Vérifier si Hack Nerd Font est déjà installée
check_hack_font() {
    echo -e "\n${BLUE}Vérification de l'installation de Hack Nerd Font...${NC}"

    case "$OS" in
        macos)
            if [ -d "$HOME/Library/Fonts" ] && ls "$HOME/Library/Fonts/Hack*Nerd*Font*.ttf" &> /dev/null; then
                echo -e "${GREEN}Hack Nerd Font est déjà installée sur macOS.${NC}"
                return 0
            fi
            ;;
        linux*|wsl)
            if [ -d "$HOME/.local/share/fonts/HackNerdFont" ] && ls "$HOME/.local/share/fonts/HackNerdFont"/*.ttf &> /dev/null; then
                echo -e "${GREEN}Hack Nerd Font est déjà installée dans le répertoire utilisateur.${NC}"
                return 0
            elif command -v fc-list &> /dev/null && fc-list | grep -i "Hack Nerd Font" &> /dev/null; then
                echo -e "${GREEN}Hack Nerd Font est déjà installée dans le système.${NC}"
                return 0
            fi
            ;;
        windows)
            # Difficult to check on Windows from bash
            echo -e "${YELLOW}Impossible de vérifier l'installation de la police sur Windows.${NC}"
            return 1
            ;;
    esac

    echo -e "${YELLOW}Hack Nerd Font n'est pas installée.${NC}"
    return 1
}

# Installer Hack Nerd Font si nécessaire
if check_hack_font; then
    echo -e "${GREEN}Hack Nerd Font est déjà installée.${NC}"
else
    echo -e "\n${BLUE}Hack Nerd Font n'a pas été trouvée. Voulez-vous l'installer? (y/n)${NC}"
    read -r install_font_choice
    if [[ "$install_font_choice" =~ ^[Yy]$ ]]; then
        if install_hack_nerd_font; then
            echo -e "${GREEN}Installation de Hack Nerd Font terminée avec succès.${NC}"
        else
            echo -e "${RED}L'installation de Hack Nerd Font a échoué.${NC}"
            echo -e "${YELLOW}Vous pouvez continuer sans cette police, mais certains icônes pourraient ne pas s'afficher correctement.${NC}"
        fi
    else
        echo -e "${YELLOW}Installation de Hack Nerd Font ignorée. Veuillez l'installer manuellement pour une meilleure expérience.${NC}"
        echo -e "${YELLOW}Télécharger depuis: https://www.nerdfonts.com/font-downloads${NC}"
    fi
fi

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
    echo -e "\n${YELLOW}Votre shell par défaut n'est pas zsh. Voulez-vous le changer maintenant? (y/n)${NC}"
    read -r change_shell_choice

    if [[ "$change_shell_choice" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Changement du shell par défaut pour zsh...${NC}"

        case "$OS" in
            macos)
                # Vérifier si zsh est dans /etc/shells
                if ! grep -q "$(which zsh)" /etc/shells; then
                    echo -e "${YELLOW}Ajout de $(which zsh) à /etc/shells...${NC}"
                    echo "$(which zsh)" | sudo tee -a /etc/shells > /dev/null
                fi

                # Changer le shell
                chsh -s "$(which zsh)"
                ;;
            linux*|wsl)
                # Essayer chsh d'abord
                if command -v chsh &> /dev/null; then
                    echo -e "${BLUE}Utilisation de chsh pour changer le shell...${NC}"
                    chsh -s "$(which zsh)"
                else
                    # Sinon, essayer usermod
                    echo -e "${BLUE}Utilisation de usermod pour changer le shell...${NC}"
                    sudo usermod -s "$(which zsh)" "$(whoami)"
                fi
                ;;
        esac

        echo -e "${GREEN}Shell changé avec succès! Les changements prendront effet après votre prochaine connexion.${NC}"
        echo -e "${BLUE}Pour utiliser zsh immédiatement, exécutez: ${GREEN}zsh${NC}"
    else
        echo -e "${YELLOW}Pour changer votre shell plus tard, exécutez:${NC}"

        case "$OS" in
            macos)
                echo -e "${GREEN}chsh -s $(which zsh)${NC}"
                echo -e "${BLUE}Note: Vous devrez peut-être ajouter $(which zsh) à /etc/shells d'abord${NC}"
                ;;
            linux*)
                echo -e "${GREEN}chsh -s $(which zsh)${NC}"
                echo -e "${BLUE}Ou: sudo usermod -s $(which zsh) $(whoami)${NC}"
                ;;
            wsl)
                echo -e "${GREEN}chsh -s $(which zsh)${NC}"
                ;;
        esac
    fi
fi

# Instructions pour Windows
if [ "$OS" = "windows" ]; then
    echo -e "\n${BLUE}Windows-specific notes:${NC}"
    echo -e "${GREEN}1. For WezTerm, make sure the config files are in:${NC}"
    echo -e "${GREEN}   %USERPROFILE%\.wezterm.lua${NC}"
    echo -e "${GREEN}   %USERPROFILE%\.config\wezterm\${NC}"
    echo -e "${GREEN}2. For zsh, you'll need to install it via MSYS2, Cygwin, or WSL${NC}"
fi
