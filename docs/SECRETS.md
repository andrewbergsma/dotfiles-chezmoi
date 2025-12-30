# Secret Management Guide

## Overview

This dotfiles setup uses different secret management strategies per OS:
- **macOS**: Fetches secrets from macOS Keychain automatically
- **Linux**: Sources from manually maintained `~/.config/shell/secrets.env` file

---

## macOS - Keychain Setup

### Adding Secrets to Keychain

```bash
# Generic pattern
security add-generic-password -a "account-name" -s "service-name" -w "your-secret-value"

# Examples:
security add-generic-password -a "github" -s "personal-token" -w "ghp_xxxxxxxxxxxx"
security add-generic-password -a "openai" -s "api-key" -w "sk-xxxxxxxxxxxx"
security add-generic-password -a "anthropic" -s "api-key" -w "sk-ant-xxxxxxxxxxxx"
```

**For secrets with special characters:** Use `-p` for interactive password entry:
```bash
security add-generic-password -a "github" -s "personal-token" -p
# (will prompt for password securely)
```

### Updating Existing Secrets

```bash
# Add -U flag to update
security add-generic-password -a "github" -s "personal-token" -w "new-token-value" -U
```

### Listing Keychain Items

```bash
# List all generic passwords
security dump-keychain | grep "0x00000007"

# Find specific item
security find-generic-password -a "github" -s "personal-token"

# Get just the password value
security find-generic-password -a "github" -s "personal-token" -w
```

### Deleting Secrets

```bash
security delete-generic-password -a "github" -s "personal-token"
```

### Adding New Secrets to Template

Edit `dot_config/shell/private_secrets.zsh.tmpl` and add:

```bash
# My New Secret
_my_secret=$(_fetch_keychain "account-name" "service-name")
[[ -n "$_my_secret" ]] && export MY_SECRET_VAR="$_my_secret"
```

Then add to cleanup section:
```bash
unset _my_secret
```

---

## Linux - Manual Environment File

### Initial Setup

On first shell load, the template creates `~/.config/shell/secrets.env` automatically.

### Adding Secrets

Edit `~/.config/shell/secrets.env`:

```bash
# GitHub Personal Access Token
GITHUB_TOKEN=ghp_xxxxxxxxxxxx

# OpenAI API Key
OPENAI_API_KEY=sk-xxxxxxxxxxxx

# Anthropic API Key
ANTHROPIC_API_KEY=sk-ant-xxxxxxxxxxxx

# Custom secrets
MY_SECRET=value_here
```

**Format:**
- One `KEY=value` per line
- Lines starting with `#` are comments (ignored)
- Empty lines are ignored
- No quotes needed around values (unless they contain spaces)

### Security Notes

**Linux hosts** (`archdev`, `archdev101`, `ubuntu103`):
- Keep `secrets.env` file secure: `chmod 600 ~/.config/shell/secrets.env`
- This file is NOT managed by chezmoi (in `.chezmoiignore`)
- Back up manually or use a password manager
- Consider using `pass`, `gopass`, or similar for better security

---

## Testing Your Setup

### Verify Template Rendering

```bash
# Preview what secrets.zsh will look like
chezmoi execute-template < ~/.local/share/chezmoi/dot_config/shell/private_secrets.zsh.tmpl
```

### Test Secret Loading

```bash
# Apply changes
chezmoi apply

# Reload shell
exec zsh

# Check if secrets are loaded
echo $GITHUB_TOKEN
echo $OPENAI_API_KEY
```

---

## Security Best Practices

1. **Never commit secrets to git**
   - `.chezmoiignore` prevents `secrets.env` from being managed
   - Keychain secrets never touch files in the repo

2. **Use specific account/service names**
   - `github/personal-token` is better than `token/github`
   - Makes searching and managing easier

3. **Rotate secrets periodically**
   - Update with `-U` flag on macOS
   - Edit `secrets.env` on Linux

4. **Keep Linux env files locked down**
   ```bash
   chmod 600 ~/.config/shell/secrets.env
   ```

5. **Use different tokens per machine** (when possible)
   - Easier to revoke if one machine is compromised
   - Better audit trails

---

## Troubleshooting

### macOS: "security: command not found"
- This shouldn't happen on macOS, it's a built-in command
- Check your PATH

### macOS: "The specified item could not be found in the keychain"
- Secret hasn't been added yet
- Double-check account and service names (case-sensitive)

### Linux: Secrets not loading
```bash
# Check if file exists
ls -la ~/.config/shell/secrets.env

# Check file permissions
chmod 600 ~/.config/shell/secrets.env

# Verify it's being sourced
source ~/.config/shell/secrets.zsh
echo $GITHUB_TOKEN
```

### Template rendering errors
```bash
# Test template syntax
chezmoi execute-template < ~/.local/share/chezmoi/dot_config/shell/private_secrets.zsh.tmpl

# Check chezmoi status
chezmoi doctor
```

---

## Current Configured Secrets

### macOS Keychain (studio, mbp)
- `github/personal-token` → `$GITHUB_TOKEN`
- `openai/api-key` → `$OPENAI_API_KEY`
- `anthropic/api-key` → `$ANTHROPIC_API_KEY`

### Linux Manual (archdev, archdev101, ubuntu103)
- Edit `~/.config/shell/secrets.env` to add the same variables

---

## Quick Reference

```bash
# macOS: Add secret
security add-generic-password -a "service" -s "key" -w "value"

# macOS: Update secret
security add-generic-password -a "service" -s "key" -w "new-value" -U

# macOS: Read secret
security find-generic-password -a "service" -s "key" -w

# Linux: Edit secrets
nvim ~/.config/shell/secrets.env

# Apply changes
chezmoi apply

# Reload shell
exec zsh
```
