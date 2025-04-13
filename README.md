# Dotfiles

Configuration personnalisée pour zsh, tmux et alacritty, inspirée par la configuration PowerShell avec Oh My Posh.

## Aperçu

Cette collection de dotfiles comprend :

- **zsh** : Configuration zsh avec Oh My Posh, autosuggestions, syntax highlighting et fzf
- **tmux** : Configuration tmux avec thème Catppuccin Macchiato et plugins utiles
- **alacritty** : Configuration alacritty avec support des polices Nerd Font

## Prérequis

- [Homebrew](https://brew.sh/) (pour macOS)
- [Git](https://git-scm.com/)
- Une police [Nerd Font](https://www.nerdfonts.com/) (JetBrains Mono Nerd Font recommandée)

## Installation

1. Clonez ce dépôt :
   ```bash
   git clone https://github.com/VOTRE_NOM_UTILISATEUR/dotfiles.git ~/dotfiles
   ```

2. Exécutez le script d'installation :
   ```bash
   cd ~/dotfiles
   chmod +x install.sh
   ./install.sh
   ```

3. Redémarrez votre terminal ou rechargez votre configuration :
   ```bash
   source ~/.zshrc
   ```

## Fonctionnalités

### ZSH

- Thème Oh My Posh (catppuccin_macchiato)
- Autosuggestions basées sur l'historique
- Coloration syntaxique
- Intégration fzf pour la recherche
- Alias et fonctions utiles
- Navigation rapide avec z

### Tmux

- Thème Catppuccin Macchiato
- Préfixe Ctrl+A
- Gestion des sessions et fenêtres améliorée
- Plugins pour la productivité
- Raccourcis clavier intuitifs
- Intégration avec vim/neovim

### Alacritty

- Support des polices Nerd Font
- Thème assorti à la configuration tmux et zsh
- Performance optimisée

## Raccourcis clavier

### ZSH

- `Ctrl+R` : Recherche dans l'historique avec fzf
- `Ctrl+F` : Recherche de fichiers avec fzf
- `Alt+C` : Navigation rapide entre répertoires avec fzf

### Tmux

- `Ctrl+A` : Préfixe tmux
- `Préfixe + r` : Recharger la configuration
- `Préfixe + v` : Split vertical
- `Préfixe + h` : Split horizontal
- `Préfixe + Ctrl+L` : Effacer l'écran
- `Ctrl+h/j/k/l` : Navigation entre les panneaux

## Personnalisation

Vous pouvez personnaliser ces configurations en modifiant les fichiers dans le répertoire `~/dotfiles`. Après modification, exécutez à nouveau le script d'installation pour mettre à jour les liens symboliques.

## Mise à jour

Pour mettre à jour vos dotfiles :

1. Accédez au répertoire des dotfiles :
   ```bash
   cd ~/dotfiles
   ```

2. Tirez les dernières modifications (si vous avez cloné depuis un dépôt distant) :
   ```bash
   git pull
   ```

3. Exécutez le script d'installation :
   ```bash
   ./install.sh
   ```

## Licence

Ce projet est sous licence MIT. Voir le fichier LICENSE pour plus de détails.
# dotfiles
