# Chezmoi Cross-Platform Dotfiles Agent

## Overview

This is a chezmoi-managed dotfiles system for **5 machines** across 3 operating systems:

| Host | OS | Theme | Primary Color | Icon |
|------|-----|-------|---------------|------|
| `studio` | macOS | Ocean (blue) | #61afef |  |
| `mbp` | macOS | Forest (green) | #98c379 |  |
| `archdev` | Arch | Crimson (red) | #e06c75 |  |
| `archdev101` | Arch | Mauve (purple) | #c678dd |  |
| `ubuntu103` | Ubuntu | Ember (orange) | #d19a66 |  |

**GitHub Repo:** `git@github.com:andrewbergsma/dotfiles-chezmoi.git` (private, SSH only)

---

## Key Files

### Configuration Data
- **`.chezmoidata.yaml`** - Central source of truth for host themes, colors, and package lists
- **`.chezmoi.toml.tmpl`** - Host detection and identity configuration

### Templated Configs (`.tmpl` files use Go templating)
- `dot_config/starship.toml.tmpl` - Prompt with host-specific colors
- `dot_config/tmux/status.conf.tmpl` - Tmux status bar theming
- `dot_config/tmux/theme.conf.tmpl` - Tmux color scheme
- `dot_config/yazi/theme.toml.tmpl` - Yazi file manager theme
- `dot_config/shell/local.zsh.tmpl` - Host-specific shell settings

### Shared Configs (no templating)
- `dot_config/shell/common.zsh` - Shared aliases, functions, settings
- `dot_config/tmux/common.conf` - Shared tmux keybindings
- `dot_config/kitty/kitty.conf` - Kitty terminal config

### Ignored (preserved on target)
- `.config/nvim/**` - User's existing LazyVim config is preserved

---

## Common Tasks

### Edit a Configuration
```bash
# Method 1: Edit source, then apply
chezmoi edit ~/.config/starship.toml
chezmoi apply

# Method 2: Direct edit in source directory
cd ~/.local/share/chezmoi
nvim dot_config/starship.toml.tmpl
chezmoi apply
```

### Preview Changes
```bash
chezmoi diff                    # Show what would change
chezmoi apply -n                # Dry run
chezmoi apply -v                # Verbose apply
```

### Update from GitHub
```bash
chezmoi update                  # Pull and apply
# OR manually:
chezmoi cd && git pull && exit && chezmoi apply
```

### Push Changes to GitHub
```bash
chezmoi cd
git add -A
git commit -m "Description of changes"
git push
```

### Check Current Host Identity
```bash
chezmoi data | grep hostLabel   # See detected host
chezmoi data                    # See all template data
```

---

## Template System

### Accessing Host Data
In `.tmpl` files, access host colors via:
```go-template
{{- $hostLabel := .hostLabel | default "unknown" -}}
{{- $host := index .hosts $hostLabel | default .default -}}

# Use colors:
{{ $host.primary }}      # e.g., #61afef
{{ $host.secondary }}    # e.g., #4d8fcc
{{ $host.icon }}         # e.g.,
{{ $host.label }}        # e.g., studio
```

### Color Palette Structure
Each host has these colors (monochromatic scheme):
- `primary` - Main accent color
- `secondary` - Slightly darker shade
- `accent` - Even darker shade
- `warning` - Yellow (#e5c07b)
- `error` - Red (#e06c75)
- `muted` - Gray (#5c6370)
- `bg` - Background (#282c34)
- `bg_dark` - Darker background (#21252b)
- `fg` - Foreground (#abb2bf)
- `fg_bright` - Bright text (#ffffff)

---

## Adding a New Host

1. **Edit `.chezmoidata.yaml`:**
```yaml
hosts:
  newhostname:
    label: "newhostname"
    os: "ubuntu"  # or "macos" or "arch"
    icon: ""      # or  or
    theme: "custom"
    primary: "#ff00ff"
    secondary: "#cc00cc"
    accent: "#990099"
    warning: "#e5c07b"
    error: "#e06c75"
    muted: "#5c6370"
    bg: "#282c34"
    bg_dark: "#21252b"
    fg: "#abb2bf"
    fg_bright: "#ffffff"
```

2. **Update `.chezmoi.toml.tmpl`** to recognize the hostname in auto-detection

3. **Commit and push**, then `chezmoi update` on all machines

---

## Changing Colors

To change a host's color palette:

1. Edit `.chezmoidata.yaml` and update the host's color values
2. Run `chezmoi apply` to regenerate all templated configs
3. Restart affected apps (starship auto-updates, tmux needs `tmux source ~/.tmux.conf`)

For monochromatic palettes, use shades of the same hue:
- Primary: Base color
- Secondary: ~15% darker
- Accent: ~30% darker

---

## Troubleshooting

### Icons not rendering
- Ensure Nerd Font is configured in terminal (kitty uses `MesloLGLDZ Nerd Font`)
- Test with: `echo "    "`

### Host not detected correctly
```bash
chezmoi data | grep hostLabel
# If wrong, edit ~/.config/chezmoi/chezmoi.toml:
# [data]
#     hostLabel = "correct-hostname"
```

### Template syntax errors
```bash
chezmoi execute-template < some-file.tmpl  # Test template rendering
chezmoi doctor                              # Check chezmoi health
```

### Conflicts during apply
```bash
chezmoi apply --force   # Override conflicts (use carefully)
chezmoi merge <file>    # Manually merge conflicts
```

---

## File Naming Conventions

| Source Name | Target Path |
|-------------|-------------|
| `dot_zshrc` | `~/.zshrc` |
| `dot_config/` | `~/.config/` |
| `*.tmpl` | Processed through Go templates |
| `private_*` | Applied with 0600 permissions |
| `executable_*` | Applied with executable bit |

---

## Managed Applications

- **starship** - Prompt (host colors, OS icon)
- **tmux** - Terminal multiplexer (status bar theming)
- **yazi** - File manager (color theme)
- **zsh** - Shell (aliases, functions, completions)
- **kitty** - Terminal emulator (font, colors)
- **nvim** - Editor (ignored, user manages separately)
- **claude-code-log** - Claude Code transcript viewer (converts JSONL to HTML)

---

## Quick Reference

```bash
chezmoi apply           # Apply all changes
chezmoi diff            # Preview changes
chezmoi update          # Pull from git and apply
chezmoi cd              # Enter source directory
chezmoi data            # Show template data
chezmoi edit <file>     # Edit a managed file
chezmoi add <file>      # Add a new file to chezmoi
chezmoi forget <file>   # Stop managing a file
```

---

## Claude Code Log

The `claude-code-log` tool is installed via the bootstrap scripts and provides a way to view and analyze Claude Code conversation transcripts.

### Quick Start

```bash
# Launch interactive TUI to browse all projects
ccl-tui

# View today's conversations in browser
ccl-today

# View this week's conversations
ccl-week

# Open current project in TUI
ccl-here

# View custom date range
ccl-range yesterday
ccl-range "3 days ago" today
```

### Available Aliases

All aliases are defined in `.config/shell/common.zsh`:

- **ccl** - Shorthand for `claude-code-log`
- **ccl-tui** - Launch TUI for all projects
- **ccl-today** - View today's transcripts in browser
- **ccl-week** - View last week's transcripts in browser
- **ccl-here** - Open TUI for current working directory
- **ccl-range** - View custom date range (function)

### Common Usage

```bash
# Process all Claude Code projects (creates index.html)
ccl --open-browser

# Launch TUI to browse sessions interactively
ccl --tui

# View specific project
ccl /path/to/project --tui

# Filter by date range
ccl --from-date "yesterday" --to-date "today"

# Generate HTML without individual session files
ccl --no-individual-sessions
```

### Output Location

By default, claude-code-log generates files in:
- `~/.claude/projects/index.html` - Master index
- `~/.claude/projects/project-name/combined_transcripts.html` - Combined project transcripts
- `~/.claude/projects/project-name/session-{id}.html` - Individual sessions

### Development

The source code is located at `~/GitHub/claude-code-log` and uses:
- Python 3.10+ with uv package management
- Textual for the TUI
- Click for CLI interface

To update the tool:
```bash
cd ~/GitHub/claude-code-log
uv tool install --force .
```
