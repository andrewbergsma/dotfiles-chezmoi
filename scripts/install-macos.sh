#!/usr/bin/env bash
# ============================================================================
# macOS Bootstrap Script
# Installs CLI tools and dependencies for dotfiles
# ============================================================================

set -euo pipefail

echo "=== macOS Dotfiles Bootstrap ==="
echo ""

# ============================================================================
# HOMEBREW
# ============================================================================
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for this session
    if [[ -d /opt/homebrew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
else
    echo "Homebrew already installed"
fi

echo ""
echo "Updating Homebrew..."
brew update

# ============================================================================
# CORE CLI TOOLS
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
    gh

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

    # File manager
    yazi

    # Yazi preview dependencies
    chafa
    ffmpegthumbnailer
    poppler
    imagemagick

    # Optional: shell history
    atuin
)

for pkg in "${CORE_PACKAGES[@]}"; do
    if brew list "$pkg" &> /dev/null; then
        echo "  ✓ $pkg (already installed)"
    else
        echo "  Installing $pkg..."
        brew install "$pkg"
    fi
done

# ============================================================================
# FONTS (Nerd Fonts for icons)
# ============================================================================
echo ""
echo "Installing Nerd Fonts..."

# Add cask-fonts tap
brew tap homebrew/cask-fonts 2>/dev/null || true

FONTS=(
    font-jetbrains-mono-nerd-font
    font-fira-code-nerd-font
)

for font in "${FONTS[@]}"; do
    if brew list --cask "$font" &> /dev/null; then
        echo "  ✓ $font (already installed)"
    else
        echo "  Installing $font..."
        brew install --cask "$font" || true
    fi
done

# ============================================================================
# UV (Python Package Manager)
# ============================================================================
echo ""
echo "Installing uv (Python package manager)..."

if command -v uv &> /dev/null; then
    echo "  ✓ uv already installed"
else
    curl -LsSf https://astral.sh/uv/install.sh | sh
    # Add uv to PATH for this session
    export PATH="$HOME/.local/bin:$PATH"
    echo "  ✓ uv installed"
fi

# ============================================================================
# CLAUDE-CODE-LOG (Claude Code transcript viewer)
# ============================================================================
echo ""
echo "Installing claude-code-log..."

if command -v claude-code-log &> /dev/null; then
    echo "  ✓ claude-code-log already installed"
else
    uv tool install claude-code-log
    echo "  ✓ claude-code-log installed"
fi

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
    brew install chezmoi
    echo "  ✓ chezmoi installed"
fi

# ============================================================================
# SET ZSH AS DEFAULT SHELL
# ============================================================================
echo ""
BREW_ZSH="/opt/homebrew/bin/zsh"
[[ ! -f "$BREW_ZSH" ]] && BREW_ZSH="/usr/local/bin/zsh"

if [[ "$SHELL" != "$BREW_ZSH" && -f "$BREW_ZSH" ]]; then
    echo "Setting Homebrew zsh as default shell..."
    if ! grep -q "$BREW_ZSH" /etc/shells; then
        echo "$BREW_ZSH" | sudo tee -a /etc/shells
    fi
    chsh -s "$BREW_ZSH"
    echo "  ✓ Default shell changed to $BREW_ZSH"
else
    echo "Default shell already set correctly"
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
