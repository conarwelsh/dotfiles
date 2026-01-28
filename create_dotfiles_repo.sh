#!/bin/bash

# Final Version (v4): Optimized for WSL performance and Zsh-specific syntax.

echo "🛠️ Generating conarwelsh/dotfiles (v4 - WSL Optimized)..."

mkdir -p scripts themes

# 1. install.sh (Dependency & Path Fixes)
cat << 'EOF' > install.sh
#!/bin/bash
set -e
REPO_URL="https://github.com/conarwelsh/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

echo "📦 Installing dependencies..."
if command -v apt-get &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y zsh git curl fzf zoxide bat ripgrep fd-find gpg wget
    
    # Symlink batcat to bat
    mkdir -p "$HOME/.local/bin"
    [ ! -f "$HOME/.local/bin/bat" ] && ln -s /usr/bin/batcat "$HOME/.local/bin/bat"

    # Install eza
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt update && sudo apt install -y eza
fi

[ ! -d "$DOTFILES_DIR" ] && git clone "$REPO_URL" "$DOTFILES_DIR"
command -v starship &> /dev/null || curl -sS https://starship.rs/install.sh | sh -s -- -y

chmod +x "$DOTFILES_DIR/setup_links.sh"
"$DOTFILES_DIR/setup_links.sh"

echo "✅ Done! Run: source ~/.zshrc"
EOF

# 2. setup_links.sh
cat << 'EOF' > setup_links.sh
#!/bin/bash
DOTFILES_DIR="$HOME/.dotfiles"
CONFIG_DIR="$HOME/.config"
mkdir -p "$CONFIG_DIR" "$HOME/.local/bin"

ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
chmod +x "$DOTFILES_DIR/scripts/theme-toggle.sh"
ln -sf "$DOTFILES_DIR/scripts/theme-toggle.sh" "$HOME/.local/bin/tt"
ln -sf "$DOTFILES_DIR/themes/one-dark.toml" "$CONFIG_DIR/starship.toml"
EOF

# 3. .zshrc (Performance & Completion Fixes)
cat << 'EOF' > .zshrc
# Fix for the 'docker' completion error on Ubuntu
zstyle ':completion:*:*:docker:*' cache-policy dummy
autoload -Uz compinit
compinit -i -u # -u ignores insecure files to prevent error 503

export DOTFILES="$HOME/.dotfiles"
export PATH="$HOME/.local/bin:$PATH"

# Starship WSL Performance Tweak
export STARSHIP_CONFIG="$HOME/.config/starship.toml"

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# Toggle Alias
alias tt='source $DOTFILES/scripts/theme-toggle.sh'

# Fast Aliases
if command -v eza > /dev/null; then
    alias ls='eza --icons --git --group-directories-first'
    alias ll='ls -lh'
else
    alias ls='ls --color=auto'
    alias ll='ls -al'
fi

# Map batcat to cat safely
if command -v bat > /dev/null; then
    alias cat='bat --style=plain --paging=never'
elif command -v batcat > /dev/null; then
    alias cat='batcat --style=plain --paging=never'
fi

alias t='turbo'
alias td='turbo run dev'

z() {
  if [[ "$#" -eq 0 ]]; then
    local dir=$(zoxide query -l | fzf --height 40% --reverse)
    [[ -n "$dir" ]] && cd "$dir"
  else
    zoxide "$@"
  fi
}
EOF

# 4. scripts/theme-toggle.sh (Zsh-Native Reading)
cat << 'EOF' > scripts/theme-toggle.sh
#!/bin/zsh
# Using native Zsh features to avoid calling 'cat' or shell aliases
THEME_DIR="$HOME/.dotfiles/themes"
DEST="$HOME/.config/starship.toml"
STATE="$HOME/.dotfiles/.theme_state"

[[ ! -f "$STATE" ]] && echo "one-dark" > "$STATE"

# The $(<file) syntax reads a file directly in Zsh
local CURRENT_THEME=$(<"$STATE")

if [[ "$CURRENT_THEME" == "one-dark" ]]; then
    ln -sf "$THEME_DIR/glass-frosted.toml" "$DEST"
    echo "glass-frosted" > "$STATE"
    echo "💎 Theme: Glass Frosted"
else
    ln -sf "$THEME_DIR/one-dark.toml" "$DEST"
    echo "one-dark" > "$STATE"
    echo "🌑 Theme: One Dark Pro"
fi
EOF

# 5. themes/one-dark.toml (Latency Optimized)
cat << 'EOF' > themes/one-dark.toml
add_newline = true
scan_timeout = 10
[character]
success_symbol = "[λ](bold purple)"
error_symbol = "[λ](bold red)"
[nodejs]
disabled = true # Major source of lag in monorepos
[package]
disabled = true # Major source of lag in monorepos
EOF

# 6. themes/glass-frosted.toml (Latency Optimized)
cat << 'EOF' > themes/glass-frosted.toml
add_newline = true
scan_timeout = 10
[character]
success_symbol = "[❯](bold #f72585)[❯](bold #4cc9f0)"
error_symbol = "[✖](bold red)"
[nodejs]
disabled = true
[git_status]
disabled = false
EOF

chmod +x install.sh setup_links.sh scripts/theme-toggle.sh
echo "✅ Version 4 Ready. Run 'source ~/.zshrc' then 'tt'."