  #!/bin/bash

# Script d'installation pour les dotfiles
# Crée des liens symboliques pour les fichiers de configuration
# Compatible avec macOS, Linux et WSL

# Variables globales
INSTALL_ZSH=true
INSTALL_WEZTERM=true
INSTALL_FONTS=true
REMOVE_MODE=false
SHOW_HELP=false

# Fonction d'aide
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options d'installation:"
    echo "  --help, -h          Afficher cette aide"
    echo "  --all               Installer tout (défaut)"
    echo "  --zsh-only          Installer uniquement la configuration zsh"
    echo "  --wezterm-only      Installer uniquement la configuration WezTerm"
    echo "  --no-fonts          Ne pas installer les polices"
    echo "  --no-zsh            Ne pas installer la configuration zsh"
    echo "  --no-wezterm        Ne pas installer la configuration WezTerm"
    echo ""
    echo "Options de suppression:"
    echo "  --remove, -r        Supprimer tous les liens symboliques"
    echo "  --remove-zsh        Supprimer uniquement les liens zsh"
    echo "  --remove-wezterm    Supprimer uniquement les liens WezTerm"
    echo ""
    echo "Exemples:"
    echo "  $0                     # Installation complète"
    echo "  $0 --zsh-only          # Installer uniquement zsh"
    echo "  $0 --remove            # Supprimer tous les liens symboliques"
    echo "  $0 --remove-wezterm    # Supprimer uniquement les liens WezTerm"
    echo "  $0 --no-fonts          # Installer sans les polices"
    exit 0
}

# Fonction pour supprimer les liens symboliques zsh
remove_zsh_links() {
    echo -e "${BLUE}Suppression des liens symboliques zsh...${NC}"
    [ -L "$HOME/.config/zsh/zshrc" ] && rm "$HOME/.config/zsh/zshrc" && echo -e "${GREEN}Supprimé: ~/.config/zsh/zshrc${NC}"
    [ -L "$HOME/.zshrc" ] && rm "$HOME/.zshrc" && echo -e "${GREEN}Supprimé: ~/.zshrc${NC}"
    [ -L "$HOME/.config/zsh/fzf.zsh" ] && rm "$HOME/.config/zsh/fzf.zsh" && echo -e "${GREEN}Supprimé: ~/.config/zsh/fzf.zsh${NC}"
    echo -e "${GREEN}Suppression des liens zsh terminée!${NC}"
}

# Fonction pour supprimer les liens symboliques WezTerm
remove_wezterm_links() {
    echo -e "${BLUE}Suppression des liens symboliques WezTerm...${NC}"
    [ -L "$HOME/.config/wezterm/wezterm.lua" ] && rm "$HOME/.config/wezterm/wezterm.lua" && echo -e "${GREEN}Supprimé: ~/.config/wezterm/wezterm.lua${NC}"
    [ -L "$HOME/.wezterm.lua" ] && rm "$HOME/.wezterm.lua" && echo -e "${GREEN}Supprimé: ~/.wezterm.lua${NC}"

    # Supprimer les liens des fichiers de configuration modulaires WezTerm
    for config_file in appearance.lua events.lua fonts.lua general.lua keys.lua utils.lua; do
        if [ -L "$HOME/.config/wezterm/config/$config_file" ]; then
            rm "$HOME/.config/wezterm/config/$config_file"
            echo -e "${GREEN}Supprimé: ~/.config/wezterm/config/$config_file${NC}"
        fi
    done
    echo -e "${GREEN}Suppression des liens WezTerm terminée!${NC}"
}

# Fonction pour supprimer tous les liens symboliques
remove_all_dotfiles() {
    echo -e "${BLUE}Suppression de tous les liens symboliques des dotfiles...${NC}"
    remove_zsh_links
    echo ""
    remove_wezterm_links
    echo -e "\n${GREEN}Suppression complète terminée!${NC}"
    echo -e "${BLUE}Note: Les sauvegardes dans ~/.dotfiles_backup/ sont conservées.${NC}"
}

# Analyser les arguments de ligne de commande
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            SHOW_HELP=true
            shift
            ;;
        --remove|-r)
            REMOVE_MODE=true
            shift
            ;;
        --remove-zsh)
            remove_zsh_links
            exit 0
            ;;
        --remove-wezterm)
            remove_wezterm_links
            exit 0
            ;;
        --all)
            INSTALL_ZSH=true
            INSTALL_WEZTERM=true
            INSTALL_FONTS=true
            shift
            ;;
        --zsh-only)
            INSTALL_ZSH=true
            INSTALL_WEZTERM=false
            INSTALL_FONTS=false
            shift
            ;;
        --wezterm-only)
            INSTALL_ZSH=false
            INSTALL_WEZTERM=true
            INSTALL_FONTS=false
            shift
            ;;
        --no-fonts)
            INSTALL_FONTS=false
            shift
            ;;
        --no-zsh)
            INSTALL_ZSH=false
            shift
            ;;
        --no-wezterm)
            INSTALL_WEZTERM=false
            shift
            ;;
        *)
            echo -e "${RED}Option inconnue: $1${NC}"
            echo "Utilisez --help pour voir les options disponibles."
            exit 1
            ;;
    esac
done

# Afficher l'aide si demandé
if [ "$SHOW_HELP" = true ]; then
    show_help
fi

# Mode suppression
if [ "$REMOVE_MODE" = true ]; then
    remove_all_dotfiles
    exit 0
fi

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

                # Installer les dépendances
                if [ ${#missing_deps[@]} -gt 0 ]; then
                    sudo apt install -y ${missing_deps[@]}
                fi
                ;;
            linux-fedora)
                # Installer les dépendances
                if [ ${#missing_deps[@]} -gt 0 ]; then
                    sudo dnf install -y ${missing_deps[@]}
                fi
                ;;
            linux-arch|linux-manjaro)
                # Installer les dépendances
                if [ ${#missing_deps[@]} -gt 0 ]; then
                    sudo pacman -S --needed ${missing_deps[@]}
                fi
                ;;
            macos)
                if command -v brew &> /dev/null; then
                    # Installer les dépendances
                    if [ ${#missing_deps[@]} -gt 0 ]; then
                        brew install ${missing_deps[@]}
                    fi
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

# Afficher les options sélectionnées
echo -e "\n${BLUE}Options d'installation:${NC}"
echo -e "  Zsh: $([ "$INSTALL_ZSH" = true ] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}")"
echo -e "  WezTerm: $([ "$INSTALL_WEZTERM" = true ] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}")"
echo -e "  Polices: $([ "$INSTALL_FONTS" = true ] && echo -e "${GREEN}✓${NC}" || echo -e "${RED}✗${NC}")"

# Créer les liens symboliques pour zsh
if [ "$INSTALL_ZSH" = true ]; then
    echo -e "\n${BLUE}Configuring zsh...${NC}"
    create_symlink "$DOTFILES_DIR/zsh/zshrc" "$HOME/.config/zsh/zshrc"
    create_symlink "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc"

    # Configurer fzf pour zsh
    mkdir -p "$HOME/.config/zsh"
    create_symlink "$DOTFILES_DIR/zsh/fzf.zsh" "$HOME/.config/zsh/fzf.zsh"
else
    echo -e "\n${YELLOW}Configuration zsh ignorée (--no-zsh ou option sélective)${NC}"
fi

# Pas besoin de configurer starship car nous utilisons un prompt zsh natif

# Créer les liens symboliques pour WezTerm (si installé et demandé)
if [ "$INSTALL_WEZTERM" = true ]; then
    if command -v wezterm &> /dev/null; then
        echo -e "\n${BLUE}WezTerm détecté, configuration des dotfiles...${NC}"

        # Créer les répertoires de configuration WezTerm
        mkdir -p "$HOME/.config/wezterm/config"

        # Lier le fichier principal
        create_symlink "$DOTFILES_DIR/wezterm/wezterm.lua" "$HOME/.config/wezterm/wezterm.lua"
        create_symlink "$DOTFILES_DIR/wezterm/wezterm.lua" "$HOME/.wezterm.lua"

        # Lier les fichiers de configuration modulaires
        for config_file in "$DOTFILES_DIR"/wezterm/config/*.lua; do
            if [ -f "$config_file" ]; then
                filename=$(basename "$config_file")
                create_symlink "$config_file" "$HOME/.config/wezterm/config/$filename"
            fi
        done

        echo -e "${GREEN}Configuration WezTerm terminée!${NC}"
    else
        echo -e "\n${YELLOW}WezTerm non détecté. Les fichiers de configuration WezTerm ne seront pas liés.${NC}"
        echo -e "${BLUE}Si vous installez WezTerm plus tard, relancez ce script pour configurer les dotfiles.${NC}"
    fi
else
    echo -e "\n${YELLOW}Configuration WezTerm ignorée (--no-wezterm ou option sélective)${NC}"
fi









# Installer les plugins zsh si demandé
if [ "$INSTALL_ZSH" = true ]; then
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
            # Vérifier dans plusieurs emplacements possibles sur macOS
            local font_found=false

            # Vérifier dans le répertoire utilisateur
            if [ -d "$HOME/Library/Fonts" ]; then
                if ls "$HOME/Library/Fonts/"*Hack*Nerd*Font*.ttf &> /dev/null || \
                   ls "$HOME/Library/Fonts/"Hack*.ttf &> /dev/null || \
                   ls "$HOME/Library/Fonts/"*HackNerd*.ttf &> /dev/null; then
                    font_found=true
                fi
            fi

            # Vérifier dans le répertoire système
            if [ "$font_found" = false ] && [ -d "/Library/Fonts" ]; then
                if ls "/Library/Fonts/"*Hack*Nerd*Font*.ttf &> /dev/null || \
                   ls "/Library/Fonts/"Hack*.ttf &> /dev/null || \
                   ls "/Library/Fonts/"*HackNerd*.ttf &> /dev/null; then
                    font_found=true
                fi
            fi

            # Vérifier avec fc-list si disponible
            if [ "$font_found" = false ] && command -v fc-list &> /dev/null; then
                if fc-list | grep -i "hack.*nerd" &> /dev/null || \
                   fc-list | grep -i "hacknerd" &> /dev/null; then
                    font_found=true
                fi
            fi

            if [ "$font_found" = true ]; then
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

# Installer Hack Nerd Font si nécessaire et demandé
if [ "$INSTALL_FONTS" = true ]; then
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
else
    echo -e "\n${YELLOW}Installation des polices ignorée (--no-fonts ou option sélective)${NC}"
fi

echo -e "\n${GREEN}Configuration complete!${NC}"

# Instructions spécifiques au système d'exploitation
case "$OS" in
    windows)
        echo -e "${BLUE}To apply changes on Windows:${NC}"
        echo -e "${GREEN}1. Restart your terminal${NC}"
        echo -e "${GREEN}2. If using Git Bash or MSYS, you may need to run 'source ~/.zshrc'${NC}"
        echo -e "${GREEN}3. If WezTerm was detected, restart WezTerm to apply the new configuration${NC}"
        ;;
    wsl)
        echo -e "${BLUE}To apply changes on WSL:${NC}"
        echo -e "${GREEN}1. Restart your terminal or run: source ~/.zshrc${NC}"
        echo -e "${GREEN}2. If WezTerm was detected, restart WezTerm to apply the new configuration${NC}"
        ;;
    *)
        echo -e "${BLUE}To apply changes, restart your terminal or run:${NC}"
        echo -e "${GREEN}source ~/.zshrc${NC}"
        echo -e "${GREEN}If WezTerm was detected, restart WezTerm to apply the new configuration${NC}"
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
    echo -e "${GREEN}1. For zsh, you'll need to install it via MSYS2, Cygwin, or WSL${NC}"
    echo -e "${GREEN}2. WezTerm configuration will be automatically linked if WezTerm is detected${NC}"
fi
