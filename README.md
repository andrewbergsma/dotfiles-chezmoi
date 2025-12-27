# Cross-Platform Dotfiles

A unified dotfiles system for **5 machines** (1 Ubuntu, 2 Arch, 2 macOS) with visually distinct host identification.

Managed by [chezmoi](https://chezmoi.io/) — one branch, per-host theming via templates.

> **Note:** This is a private repository. SSH keys must be configured on each machine.

## Visual Host Identification

Each machine has a **distinct color theme** visible in:
- **Starship prompt** — host label in status bar
- **Tmux status line** — colored status with host label
- **Yazi file manager** — themed UI

| Host | OS | Theme | Primary Color |
|------|-----|-------|---------------|
| `studio` | macOS | Ocean | Blue (#61afef) |
| `mbp` | macOS | Forest | Green (#98c379) |
| `archdev` | Arch | Sunset | Orange/Red (#ff7b72) |
| `archdev101` | Arch | Arctic | Cyan (#88c0d0) |
| `ubuntu103` | Ubuntu | Volcanic | Purple (#c678dd) |

## Quick Start

### 0. Prerequisites (SSH Key)

Ensure SSH keys are set up for GitHub on the machine:
```bash
# Test SSH access
ssh -T git@github.com

# If not set up, generate a key and add to GitHub
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub  # Add this to GitHub → Settings → SSH Keys
```

### 1. Clone and Bootstrap

```bash
# Clone the repo
git clone git@github.com:andrewbergsma/dotfiles-chezmoi.git
cd dotfiles-chezmoi

# Run the appropriate install script
./scripts/install-macos.sh    # macOS
./scripts/install-arch.sh     # Arch Linux
./scripts/install-ubuntu.sh   # Ubuntu
```

### 2. Install chezmoi (if not installed by script)

```bash
# macOS (Homebrew)
brew install chezmoi

# Arch Linux
sudo pacman -S chezmoi

# Ubuntu / other Linux
sh -c "$(curl -fsLS get.chezmoi.io)"
```

### 3. Initialize Dotfiles

```bash
# Initialize and apply (SSH URL for private repo)
chezmoi init git@github.com:andrewbergsma/dotfiles-chezmoi.git --apply

# You'll be prompted for host label if not auto-detected:
# Host label (studio/mbp/archdev/archdev101/ubuntu103): studio
```

### 4. Preview and Apply

```bash
# Preview changes (diff)
chezmoi diff

# Apply all changes
chezmoi apply

# Or apply with verbose output
chezmoi apply -v
```

### 5. Reload Shell

```bash
exec zsh
```

### 6. Install Tmux Plugins

Inside tmux, press `prefix + I` (Ctrl-b then Shift-i) to install plugins.

## Updating

```bash
# Pull latest and apply
chezmoi update

# Or manually
chezmoi cd
git pull
exit
chezmoi apply
```

## Directory Structure

```
~/.local/share/chezmoi/           # chezmoi source directory
├── .chezmoi.toml.tmpl            # Host configuration (prompts for identity)
├── .chezmoidata.yaml             # Theme palettes and shared data
├── dot_zshrc.tmpl                # → ~/.zshrc
├── dot_tmux.conf.tmpl            # → ~/.tmux.conf
├── dot_config/
│   ├── starship.toml.tmpl        # → ~/.config/starship.toml
│   ├── shell/
│   │   ├── common.zsh            # Shared shell config
│   │   └── local.zsh.tmpl        # Host-specific shell config
│   ├── tmux/
│   │   ├── common.conf           # Shared tmux settings
│   │   ├── status.conf.tmpl      # Themed status bar
│   │   └── theme.conf.tmpl       # Host-specific colors
│   ├── yazi/
│   │   ├── yazi.toml             # Shared yazi config
│   │   ├── keymap.toml           # Shared keybindings
│   │   └── theme.toml.tmpl       # Host-specific theme
│   └── nvim/
│       ├── init.lua              # Shared neovim config
│       └── lua/local.lua.tmpl    # Host-specific settings
└── scripts/
    ├── install-macos.sh
    ├── install-arch.sh
    └── install-ubuntu.sh
```

## Setting/Overriding Host Identity

Host identity is determined in this order:

1. **Auto-detection**: If hostname matches `studio`, `mbp`, `archdev`, `archdev101`, or `ubuntu103`
2. **Manual prompt**: Asked during `chezmoi init`
3. **Manual override**: Edit `~/.config/chezmoi/chezmoi.toml`

To change host identity:

```bash
# Edit chezmoi config
chezmoi edit-config

# Set hostLabel in [data] section:
# [data]
#     hostLabel = "archdev"

# Re-apply
chezmoi apply
```

## Adding a New Host

1. Edit `.chezmoidata.yaml` and add a new host entry:

```yaml
hosts:
  newhost:
    label: "newhost"
    os: "ubuntu"  # or "macos" or "arch"
    theme: "neon"
    primary: "#ff00ff"
    secondary: "#00ffff"
    # ... other colors
```

2. Update `.chezmoi.toml.tmpl` to recognize the hostname:

```go-template
{{- $knownHosts := dict
    ...
    "newhost" "ubuntu"
}}
```

3. Commit and push, then `chezmoi update` on all machines.

## Customization

### Per-Host Custom Settings

Create `~/.config/shell/custom.zsh` for settings not managed by chezmoi:

```bash
# This file is not tracked by chezmoi
# Add machine-specific customizations here
export PATH="$PATH:/some/local/path"
alias myalias='some-command'
```

### Neovim Local Config

Edit `~/.config/nvim/lua/local.lua` after chezmoi applies it, or create a separate file that chezmoi ignores.

## Troubleshooting

### Starship not showing host label

1. Verify starship is in your PATH: `which starship`
2. Check config was applied: `cat ~/.config/starship.toml`
3. Reload shell: `exec zsh`

### Tmux colors look wrong

1. Ensure terminal supports true color: `echo $TERM`
2. Check tmux config: `tmux show -g default-terminal`
3. Should be `tmux-256color`, not `screen-256color`

### chezmoi not detecting host

```bash
# Check what chezmoi thinks
chezmoi data | grep hostLabel

# Force re-init
rm ~/.config/chezmoi/chezmoi.toml
chezmoi init git@github.com:andrewbergsma/dotfiles-chezmoi.git
```

### Permission denied on scripts

```bash
chmod +x ~/.config/tmux/scripts/*.sh
```

### Yazi theme not loading

1. Check theme file exists: `ls ~/.config/yazi/theme.toml`
2. Restart yazi (quit and reopen)

### SSH key not working

```bash
# Check SSH agent is running
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Verify GitHub access
ssh -T git@github.com
```

## Tools Included

| Tool | Purpose |
|------|---------|
| **zsh** | Shell |
| **starship** | Prompt |
| **tmux** | Terminal multiplexer |
| **neovim** | Editor |
| **yazi** | File manager |
| **ripgrep** | Fast grep |
| **fd** | Fast find |
| **fzf** | Fuzzy finder |
| **zoxide** | Smart cd |
| **bat** | Better cat |
| **eza** | Better ls |
| **atuin** | Shell history |

## License

MIT
