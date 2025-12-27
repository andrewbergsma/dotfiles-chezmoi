#!/usr/bin/env bash
# ============================================================================
# Ubuntu Bootstrap Script
# Installs CLI tools and dependencies for dotfiles
# ============================================================================

set -euo pipefail

echo "=== Ubuntu Dotfiles Bootstrap ==="
echo ""

# Check Ubuntu version
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    echo "Detected: $PRETTY_NAME"
fi

# ============================================================================
# SYSTEM UPDATE
# ============================================================================
echo ""
echo "Updating system..."
sudo apt update
sudo apt upgrade -y

# ============================================================================
# CORE CLI TOOLS (from apt)
# ============================================================================
echo ""
echo "Installing core CLI tools..."

CORE_PACKAGES=(
    # Shell
    zsh

    # Editor
    neovim

    # Version control
    git
    gh

    # Search & navigation
    ripgrep
    fd-find
    fzf

    # File viewing
    bat

    # Utilities
    curl
    jq
    tree
    unzip
    wget

    # Build tools (for some installations)
    build-essential

    # Yazi dependencies
    chafa
    ffmpeg
    poppler-utils
    imagemagick

    # Clipboard
    xclip
    wl-clipboard

    # Python
    python3
    python3-pip
    python3-venv
)

echo "Installing from apt..."
sudo apt install -y "${CORE_PACKAGES[@]}"

# ============================================================================
# TOOLS NOT IN APT (install manually)
# ============================================================================
echo ""
echo "Installing additional tools..."

# --- STARSHIP ---
if command -v starship &> /dev/null; then
    echo "  ✓ starship (already installed)"
else
    echo "  Installing starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# --- EZA (modern ls replacement) ---
if command -v eza &> /dev/null; then
    echo "  ✓ eza (already installed)"
else
    echo "  Installing eza..."
    # Install from GitHub releases
    EZA_VERSION=$(curl -s https://api.github.com/repos/eza-community/eza/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    curl -Lo /tmp/eza.tar.gz "https://github.com/eza-community/eza/releases/download/${EZA_VERSION}/eza_x86_64-unknown-linux-gnu.tar.gz"
    sudo tar -xzf /tmp/eza.tar.gz -C /usr/local/bin
    rm /tmp/eza.tar.gz
    echo "  ✓ eza installed"
fi

# --- ZOXIDE ---
if command -v zoxide &> /dev/null; then
    echo "  ✓ zoxide (already installed)"
else
    echo "  Installing zoxide..."
    curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
fi

# --- YAZI ---
if command -v yazi &> /dev/null; then
    echo "  ✓ yazi (already installed)"
else
    echo "  Installing yazi..."
    # Install from GitHub releases
    YAZI_VERSION=$(curl -s https://api.github.com/repos/sxyazi/yazi/releases/latest | grep '"tag_name"' | cut -d'"' -f4)
    curl -Lo /tmp/yazi.zip "https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/yazi-x86_64-unknown-linux-gnu.zip"
    unzip -o /tmp/yazi.zip -d /tmp/yazi
    sudo mv /tmp/yazi/yazi-x86_64-unknown-linux-gnu/yazi /usr/local/bin/
    sudo mv /tmp/yazi/yazi-x86_64-unknown-linux-gnu/ya /usr/local/bin/
    rm -rf /tmp/yazi /tmp/yazi.zip
    echo "  ✓ yazi installed"
fi

# --- ATUIN ---
if command -v atuin &> /dev/null; then
    echo "  ✓ atuin (already installed)"
else
    echo "  Installing atuin..."
    curl --proto '=https' --tlsv1.2 -LsSf https://setup.atuin.sh | sh
fi

# --- FD (fix Ubuntu naming) ---
if [[ -f /usr/bin/fdfind ]] && [[ ! -f /usr/local/bin/fd ]]; then
    echo "  Creating fd symlink..."
    sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd
fi

# --- BAT (fix Ubuntu naming) ---
if [[ -f /usr/bin/batcat ]] && [[ ! -f /usr/local/bin/bat ]]; then
    echo "  Creating bat symlink..."
    sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
fi

# ============================================================================
# FONTS (Nerd Fonts)
# ============================================================================
echo ""
echo "Installing Nerd Fonts..."

FONT_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR"

install_nerd_font() {
    local font_name="$1"
    if ls "$FONT_DIR"/*"$font_name"* &> /dev/null; then
        echo "  ✓ $font_name (already installed)"
    else
        echo "  Installing $font_name..."
        curl -Lo "/tmp/$font_name.zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font_name.zip"
        unzip -o "/tmp/$font_name.zip" -d "$FONT_DIR" -x "*.txt" -x "*.md"
        rm "/tmp/$font_name.zip"
    fi
}

install_nerd_font "JetBrainsMono"
install_nerd_font "FiraCode"

# Update font cache
fc-cache -fv

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
    sh -c "$(curl -fsLS get.chezmoi.io)"
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
