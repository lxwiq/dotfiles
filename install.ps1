# Script d'installation PowerShell pour Windows
# Ce script installe les dotfiles pour zsh sur Windows

# Fonction pour afficher des messages colorés
function Write-ColorOutput {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,

        [Parameter(Mandatory=$false)]
        [string]$ForegroundColor = "White"
    )

    Write-Host $Message -ForegroundColor $ForegroundColor
}

# Fonction pour créer un lien symbolique
function Create-Symlink {
    param(
        [string]$Source,
        [string]$Target
    )

    # Vérifier si le fichier cible existe déjà
    if (Test-Path $Target) {
        $backupDir = Join-Path $env:USERPROFILE ".dotfiles_backup\$(Get-Date -Format 'yyyyMMdd_HHmmss')"

        # Créer le répertoire de sauvegarde si nécessaire
        if (-not (Test-Path $backupDir)) {
            New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        }

        # Sauvegarder le fichier existant
        $fileName = Split-Path $Target -Leaf
        $backupPath = Join-Path $backupDir $fileName
        Move-Item -Path $Target -Destination $backupPath -Force
        Write-ColorOutput "Existing file backed up to $backupPath" "Cyan"
    }

    # Créer le répertoire parent si nécessaire
    $parentDir = Split-Path $Target -Parent
    if (-not (Test-Path $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    # Créer le lien symbolique
    try {
        if (Test-Path $Source -PathType Container) {
            # C'est un dossier
            New-Item -ItemType SymbolicLink -Path $Target -Target $Source -Force | Out-Null
        } else {
            # C'est un fichier
            New-Item -ItemType SymbolicLink -Path $Target -Target $Source -Force | Out-Null
        }
        Write-ColorOutput "Symlink created: $Target -> $Source" "Green"
    } catch {
        Write-ColorOutput "Failed to create symlink: $($_.Exception.Message)" "Red"
        Write-ColorOutput "Copying file instead..." "Yellow"
        Copy-Item -Path $Source -Destination $Target -Force -Recurse
        Write-ColorOutput "File copied: $Target" "Green"
    }
}

# Vérifier si le script est exécuté en tant qu'administrateur
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-ColorOutput "This script requires administrator privileges to create symbolic links." "Yellow"
    Write-ColorOutput "Please run PowerShell as Administrator and try again." "Yellow"
    Write-ColorOutput "Continuing without admin rights will result in copying files instead of creating symlinks." "Yellow"
    $continue = Read-Host "Do you want to continue anyway? (y/n)"
    if ($continue -ne "y") {
        exit
    }
}

# Répertoire des dotfiles (chemin absolu)
$scriptPath = $MyInvocation.MyCommand.Path
$dotfilesDir = Split-Path $scriptPath -Parent

Write-ColorOutput "Installing dotfiles from $dotfilesDir" "Cyan"

# Créer les liens symboliques pour WezTerm (si installé)
$weztermInstalled = $false
$weztermPaths = @(
    "C:\Program Files\WezTerm\wezterm.exe",
    "C:\Program Files (x86)\WezTerm\wezterm.exe",
    "$env:LOCALAPPDATA\Programs\WezTerm\wezterm.exe",
    "$env:PROGRAMFILES\WezTerm\wezterm.exe",
    "$env:SCOOP\apps\wezterm\current\wezterm.exe",
    "$env:USERPROFILE\scoop\apps\wezterm\current\wezterm.exe"
)

# Vérifier aussi dans le PATH
$weztermInPath = Get-Command "wezterm" -ErrorAction SilentlyContinue

foreach ($path in $weztermPaths) {
    if (Test-Path $path) {
        $weztermInstalled = $true
        break
    }
}

if ($weztermInPath) {
    $weztermInstalled = $true
}

if ($weztermInstalled) {
    Write-ColorOutput "`nWezTerm détecté, configuration des dotfiles..." "Cyan"

    # Créer les répertoires de configuration WezTerm
    $weztermConfigDir = Join-Path $env:USERPROFILE ".config\wezterm"
    $weztermConfigModulesDir = Join-Path $weztermConfigDir "config"

    if (-not (Test-Path $weztermConfigModulesDir)) {
        New-Item -ItemType Directory -Path $weztermConfigModulesDir -Force | Out-Null
    }

    # Lier le fichier principal
    $weztermLuaSource = Join-Path $dotfilesDir "wezterm\wezterm.lua"
    $weztermLuaTarget1 = Join-Path $weztermConfigDir "wezterm.lua"
    $weztermLuaTarget2 = Join-Path $env:USERPROFILE ".wezterm.lua"

    Create-Symlink -Source $weztermLuaSource -Target $weztermLuaTarget1
    Create-Symlink -Source $weztermLuaSource -Target $weztermLuaTarget2

    # Lier les fichiers de configuration modulaires
    $configFiles = Get-ChildItem -Path (Join-Path $dotfilesDir "wezterm\config") -Filter "*.lua" -ErrorAction SilentlyContinue
    foreach ($file in $configFiles) {
        $source = $file.FullName
        $target = Join-Path $weztermConfigModulesDir $file.Name
        Create-Symlink -Source $source -Target $target
    }

    Write-ColorOutput "Configuration WezTerm terminée!" "Green"
} else {
    Write-ColorOutput "`nWezTerm non détecté. Les fichiers de configuration WezTerm ne seront pas liés." "Yellow"
    Write-ColorOutput "Si vous installez WezTerm plus tard, relancez ce script pour configurer les dotfiles." "Cyan"
}

# Créer les liens symboliques pour zsh (si utilisé avec MSYS2, Cygwin ou Git Bash)
Write-ColorOutput "`nConfiguring zsh..." "Cyan"
$zshrcSource = Join-Path $dotfilesDir "zsh\zshrc"
$zshrcTarget = Join-Path $env:USERPROFILE ".zshrc"

Create-Symlink -Source $zshrcSource -Target $zshrcTarget

# Créer le répertoire pour les plugins zsh
$zshPluginsDir = Join-Path $env:USERPROFILE ".zsh"
if (-not (Test-Path $zshPluginsDir)) {
    New-Item -ItemType Directory -Path $zshPluginsDir -Force | Out-Null
}

# Vérifier si Git est installé
$gitInstalled = $null -ne (Get-Command "git" -ErrorAction SilentlyContinue)

if ($gitInstalled) {
    # Plugin zsh-autosuggestions
    $autosuggestionDir = Join-Path $zshPluginsDir "zsh-autosuggestions"
    if (-not (Test-Path $autosuggestionDir)) {
        Write-ColorOutput "`nInstalling zsh-autosuggestions plugin..." "Cyan"
        git clone https://github.com/zsh-users/zsh-autosuggestions $autosuggestionDir
    }

    # Plugin zsh-syntax-highlighting
    $syntaxHighlightingDir = Join-Path $zshPluginsDir "zsh-syntax-highlighting"
    if (-not (Test-Path $syntaxHighlightingDir)) {
        Write-ColorOutput "`nInstalling zsh-syntax-highlighting plugin..." "Cyan"
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $syntaxHighlightingDir
    }
} else {
    Write-ColorOutput "`nGit not found. Please install Git to download zsh plugins." "Yellow"
    Write-ColorOutput "You can download the plugins manually from:" "Yellow"
    Write-ColorOutput "https://github.com/zsh-users/zsh-autosuggestions" "White"
    Write-ColorOutput "https://github.com/zsh-users/zsh-syntax-highlighting" "White"
}

Write-ColorOutput "`nConfiguration complete!" "Green"
# Télécharger et installer Hack Nerd Font
Write-ColorOutput "`nChecking for Hack Nerd Font..." "Cyan"
$fontInstalled = $false
$fontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
$fontFiles = Get-ChildItem -Path "$fontDir" -Filter "Hack*Nerd*Font*.ttf" -ErrorAction SilentlyContinue

if ($fontFiles.Count -gt 0) {
    Write-ColorOutput "Hack Nerd Font is already installed." "Green"
    $fontInstalled = $true
}

if (-not $fontInstalled) {
    Write-ColorOutput "Hack Nerd Font not found. Would you like to download and install it? (y/n)" "Cyan"
    $installFont = Read-Host
    if ($installFont -eq "y") {
        Write-ColorOutput "Downloading Hack Nerd Font..." "Cyan"
        $tempDir = Join-Path $env:TEMP "HackNerdFont"
        $zipFile = Join-Path $env:TEMP "HackNerdFont.zip"

        # Créer le répertoire temporaire
        if (-not (Test-Path $tempDir)) {
            New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        }

        # Télécharger le fichier ZIP
        try {
            $url = "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/Hack.zip"
            Invoke-WebRequest -Uri $url -OutFile $zipFile

            # Extraire le fichier ZIP
            Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force

            # Installer les polices
            $fontFiles = Get-ChildItem -Path $tempDir -Filter "*.ttf"
            foreach ($fontFile in $fontFiles) {
                $fontPath = $fontFile.FullName

                # Utiliser l'objet Shell.Application pour installer la police
                $shellApp = New-Object -ComObject Shell.Application
                $fonts = $shellApp.Namespace(0x14) # Le dossier Fonts

                if ($fonts.Self.Path) {
                    $fonts.CopyHere($fontPath)
                    Write-ColorOutput "Installed font: $($fontFile.Name)" "Green"
                } else {
                    Write-ColorOutput "Failed to access Fonts folder. Installing manually..." "Yellow"
                    Copy-Item -Path $fontPath -Destination "$env:WINDIR\Fonts" -Force
                    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" -Name $fontFile.Name -Value $fontFile.Name -PropertyType String -Force
                }
            }

            Write-ColorOutput "Hack Nerd Font installed successfully!" "Green"
        } catch {
            Write-ColorOutput "Failed to download or install Hack Nerd Font: $($_.Exception.Message)" "Red"
            Write-ColorOutput "Please download and install it manually from: https://www.nerdfonts.com/font-downloads" "Yellow"
        } finally {
            # Nettoyer les fichiers temporaires
            if (Test-Path $zipFile) {
                Remove-Item -Path $zipFile -Force
            }
            if (Test-Path $tempDir) {
                Remove-Item -Path $tempDir -Recurse -Force
            }
        }
    } else {
        Write-ColorOutput "Skipping Hack Nerd Font installation. Please install it manually for best experience." "Yellow"
        Write-ColorOutput "Download from: https://www.nerdfonts.com/font-downloads" "Yellow"
    }
}

Write-ColorOutput "Windows-specific notes:" "Cyan"
Write-ColorOutput "1. For zsh, you'll need to install it via MSYS2, Cygwin, Git Bash, or WSL" "White"
Write-ColorOutput "2. WezTerm configuration was automatically linked if WezTerm was detected" "White"
Write-ColorOutput "3. If you install WezTerm later, re-run this script to configure the dotfiles" "White"

Write-Host "`nPress any key to exit..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
