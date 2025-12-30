# ~/.config/shell/common.zsh
# ============================================================================
# SHARED SHELL CONFIGURATION - Same across all machines
# ============================================================================

# ============================================================================
# COMPLETIONS
# ============================================================================
fpath=(~/.config/zsh/completions $fpath)
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*:descriptions' format '%B%d%b'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format 'No matches for: %d'

# ============================================================================
# HISTORY
# ============================================================================
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# ============================================================================
# OPTIONS
# ============================================================================
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt CORRECT
setopt NO_BEEP

# ============================================================================
# EDITOR
# ============================================================================
export EDITOR="nvim"
export VISUAL="$EDITOR"

# ============================================================================
# NAVIGATION ALIASES
# ============================================================================
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ============================================================================
# LS ALIASES (using eza if available)
# ============================================================================
if command -v eza &> /dev/null; then
    alias l="eza -la --icons --group-directories-first"
    alias ll="eza -G"
    alias ls="eza --long"
    alias lsr="eza -labghHSi --header --icons --git --time-style=long-iso"
    alias lt="eza --tree --level=2 --icons"
else
    alias l="ls -la"
    alias ll="ls -G"
    alias ls="ls -l"
fi

# ============================================================================
# TOOL ALIASES
# ============================================================================
alias vi='nvim'
alias vim='nvim'
alias python='python3'
alias py='python3'
alias pip='pip3'
alias rp="realpath"
alias ts='date +%Y%m%d%H%M'

# ============================================================================
# GIT ALIASES
# ============================================================================
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias gl='git log --oneline -20'
alias gd='git diff'
alias gco='git checkout'

# ============================================================================
# TMUX FUNCTIONS (gum picker for session selection)
# ============================================================================
ta() {
    local sessions=$(tmux list-sessions 2>/dev/null)
    if [[ -z "$sessions" ]]; then
        echo "No tmux sessions running. Creating new session..."
        tmux new-session
    else
        local session=$(echo "$sessions" | gum choose | cut -d: -f1)
        [[ -n "$session" ]] && tmux attach-session -t "$session"
    fi
}

tks() {
    local sessions=$(tmux list-sessions 2>/dev/null)
    if [[ -z "$sessions" ]]; then
        echo "No tmux sessions to kill."
        return 1
    else
        local session=$(echo "$sessions" | gum choose | cut -d: -f1)
        [[ -n "$session" ]] && tmux kill-session -t "$session"
    fi
}

alias tl='tmux list-sessions'
alias tns='tmux new-session -s'

# ============================================================================
# ZOXIDE (smart cd)
# ============================================================================
if command -v zoxide &> /dev/null; then
    eval "$(zoxide init zsh)"
fi

# ============================================================================
# FZF
# ============================================================================
if command -v fzf &> /dev/null; then
    # Use fd if available for better performance
    if command -v fd &> /dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    fi

    export FZF_DEFAULT_OPTS="
        --height 40%
        --layout=reverse
        --border
        --info=inline
    "
fi

# ============================================================================
# BAT (cat replacement)
# ============================================================================
if command -v bat &> /dev/null; then
    alias cat='bat --paging=never'
    export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# ============================================================================
# ATUIN (shell history)
# ============================================================================
if command -v atuin &> /dev/null; then
    eval "$(atuin init zsh --disable-up-arrow)"
    export ATUIN_STYLE="compact"
    export ATUIN_INLINE_HEIGHT=12
fi

# ============================================================================
# FILE HANDLER FUNCTION
# ============================================================================
typeset -A file_handlers
file_handlers=(
    'csv'   'visidata'
    'tsv'   'visidata'
    'xlsx'  'visidata'
    'json'  'visidata'
    'toml'  'nvim'
    'yaml'  'nvim'
    'yml'   'nvim'
    'md'    'nvim'
    'txt'   'nvim'
    'xml'   'nvim'
    'log'   'nvim'
    'mp3'   'mpv --no-video'
    'mp4'   'mpv --no-video'
    'flac'  'mpv --no-video'
)

function o() {
    local file="$1"
    [[ ! -e "$file" ]] && { echo "File not found: $file"; return 1; }
    [[ -d "$file" ]] && { cd "$file"; return; }
    local ext="${file:e:l}"
    local handler="${file_handlers[$ext]:-nvim}"
    eval "$handler '$file'"
}

# ============================================================================
# SECRETS
# ============================================================================
# Load secrets (macOS Keychain or Linux env file)
[[ -f ~/.config/shell/secrets.zsh ]] && source ~/.config/shell/secrets.zsh

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Extract various archive formats
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.tar.xz)  tar xJf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.gz)      gunzip "$1" ;;
            *.tar)     tar xf "$1" ;;
            *.tbz2)    tar xjf "$1" ;;
            *.tgz)     tar xzf "$1" ;;
            *.zip)     unzip "$1" ;;
            *.7z)      7z x "$1" ;;
            *)         echo "Unknown format: $1" ;;
        esac
    else
        echo "File not found: $1"
    fi
}

# Quick note
note() {
    local note_dir="$HOME/Notes"
    [[ ! -d "$note_dir" ]] && mkdir -p "$note_dir"
    $EDITOR "$note_dir/$(date +%Y-%m-%d).md"
}
