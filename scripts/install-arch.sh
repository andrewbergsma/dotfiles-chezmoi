#!/usr/bin/env bash
# ============================================================================
# Arch Linux Bootstrap Script
# Installs CLI tools and dependencies for dotfiles
# ============================================================================

set -euo pipefail

echo "=== Arch Linux Dotfiles Bootstrap ==="
echo ""

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo "Warning: Running as root. Some operations may behave differently."
fi

# ============================================================================
# SYSTEM UPDATE
# ============================================================================
echo "Updating system..."
sudo pacman -Syu --noconfirm

# ============================================================================
# CORE CLI TOOLS (from official repos)
# ============================================================================
echo ""
echo "Installing core CLI tools..."

CORE_PACKAGES=(
    # Shell & prompt
    zsh
    starship

    # Terminal multiplexer
    tmux

    # Editor
    neovim

    # Version control
    git
    github-cli

    # Search & navigation
    ripgrep
    fd
    fzf
    zoxide

    # File viewing
    bat
    eza

    # Utilities
    curl
    jq
    tree
    unzip
    wget

    # File manager
    yazi

    # Yazi preview dependencies
    chafa
    ffmpegthumbnailer
    poppler
    imagemagick

    # Clipboard
    wl-clipboard
    xclip

    # Python (for neovim and other tools)
    python
    python-pip
)

echo "Installing from pacman..."
sudo pacman -S --needed --noconfirm "${CORE_PACKAGES[@]}"

# ============================================================================
# AUR PACKAGES (using yay if available)
# ============================================================================
echo ""

AUR_PACKAGES=(
    atuin
)

if command -v yay &> /dev/null; then
    echo "Installing AUR packages with yay..."
    for pkg in "${AUR_PACKAGES[@]}"; do
        if yay -Q "$pkg" &> /dev/null; then
            echo "  ✓ $pkg (already installed)"
        else
            echo "  Installing $pkg..."
            yay -S --noconfirm "$pkg" || echo "  Warning: Failed to install $pkg"
        fi
    done
elif command -v paru &> /dev/null; then
    echo "Installing AUR packages with paru..."
    for pkg in "${AUR_PACKAGES[@]}"; do
        if paru -Q "$pkg" &> /dev/null; then
            echo "  ✓ $pkg (already installed)"
        else
            echo "  Installing $pkg..."
            paru -S --noconfirm "$pkg" || echo "  Warning: Failed to install $pkg"
        fi
    done
else
    echo "No AUR helper found. To install AUR packages, install yay or paru first:"
    echo "  git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si"
    echo ""
    echo "AUR packages to install manually: ${AUR_PACKAGES[*]}"
fi

# ============================================================================
# FONTS (Nerd Fonts)
# ============================================================================
echo ""
echo "Installing Nerd Fonts..."

FONT_PACKAGES=(
    ttf-jetbrains-mono-nerd
    ttf-firacode-nerd
)

sudo pacman -S --needed --noconfirm "${FONT_PACKAGES[@]}" || true

# ============================================================================
# TPM (Tmux Plugin Manager)
# ============================================================================
echo ""
echo "Installing TPM (Tmux Plugin Manager)..."

TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ -d "$TPM_DIR" ]]; then
    echo "  ✓ TPM already installed"
else
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    echo "  ✓ TPM installed"
fi

# ============================================================================
# CHEZMOI
# ============================================================================
echo ""
echo "Installing chezmoi..."

if command -v chezmoi &> /dev/null; then
    echo "  ✓ chezmoi already installed"
else
    sudo pacman -S --needed --noconfirm chezmoi || {
        # Fallback: install from binary
        sh -c "$(curl -fsLS get.chezmoi.io)"
    }
    echo "  ✓ chezmoi installed"
fi

# ============================================================================
# SET ZSH AS DEFAULT SHELL
# ============================================================================
echo ""
if [[ "$SHELL" != "$(which zsh)" ]]; then
    echo "Setting zsh as default shell..."
    chsh -s "$(which zsh)"
    echo "  ✓ Default shell changed to zsh"
else
    echo "Default shell already set to zsh"
fi

# ============================================================================
# DONE
# ============================================================================
echo ""
echo "=== Bootstrap Complete ==="
echo ""
echo "Next steps:"
echo "  1. Initialize chezmoi with your dotfiles repo:"
echo "     chezmoi init https://github.com/YOUR_USER/dotfiles"
echo ""
echo "  2. Preview changes:"
echo "     chezmoi diff"
echo ""
echo "  3. Apply configuration:"
echo "     chezmoi apply"
echo ""
echo "  4. Start a new shell or run: exec zsh"
echo ""
echo "  5. In tmux, install plugins: prefix + I"
