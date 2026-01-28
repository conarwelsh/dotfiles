#!/bin/bash

# This script generates the final, robust structure for conarwelsh/dotfiles.
# It handles the Ubuntu 'batcat' naming and prevents alias-looping in scripts.

echo "🛠️ Generating conarwelsh/dotfiles (v3 - Stable)..."

mkdir -p scripts themes

# 1. README.md
cat << 'EOF' > README.md
# 🚀 Terminal Velocity: Awesome Dotfiles
Optimized for **Turborepo, NestJS, Next.js, and Tauri**.

## 🛠️ Installation
```bash
bash -c "$(curl -fsSL [https://raw.githubusercontent.com/conarwelsh/dotfiles/main/install.sh](https://raw.githubusercontent.com/conarwelsh/dotfiles/main/install.sh))"
```
## ⌨️ Shortcuts
* `tt`: Toggle Theme
* `z`: Smart Jump (fzf)
EOF

# 2. install.sh (Handles eza and batcat quirks)
cat << 'EOF' > install.sh
#!/bin/bash
set -e
REPO_URL="https://github.com/conarwelsh/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

echo "📦 Installing dependencies..."
if command -v apt-get &> /dev/null; then
    sudo apt-get update
    sudo apt-get install -y zsh git curl fzf zoxide bat ripgrep fd-find gpg wget
    
    # Fix 'bat' vs 'batcat'
    mkdir -p "$HOME/.local/bin"
    [ ! -f "$HOME/.local/bin/bat" ] && ln -s /usr/bin/batcat "$HOME/.local/bin/bat"

    # Official eza installation
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

[ "$SHELL" != "$(which zsh)" ] && chsh -s "$(which zsh)"
echo "✅ Setup complete! Restart terminal."
EOF

# 3. setup_links.sh
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

# 4. .zshrc (Improved Aliases)
cat << 'EOF' > .zshrc
export DOTFILES="$HOME/.dotfiles"
export PATH="$HOME/.local/bin:$PATH"

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

alias tt='source $DOTFILES/scripts/theme-toggle.sh'

# Use 'bat' with fallback to 'cat'
if command -v bat > /dev/null; then
    alias cat='bat --style=plain --paging=never'
elif command -v batcat > /dev/null; then
    alias cat='batcat --style=plain --paging=never'
fi

# Use 'eza' with fallback to 'ls'
if command -v eza > /dev/null; then
    alias ls='eza --icons --git --group-directories-first'
    alias ll='ls -lh'
else
    alias ls='ls --color=auto'
    alias ll='ls -alF'
fi

alias t='turbo'
alias td='turbo run dev'

z() {
  if [[ "$#" -eq 0 ]]; then
    local dir=$(zoxide query -l | fzf --height 40% --reverse)
    [ -n "$dir" ] && cd "$dir"
  else
    zoxide "$@"
  fi
}
EOF

# 5. scripts/theme-toggle.sh (Robust against aliases)
cat << 'EOF' > scripts/theme-toggle.sh
#!/bin/bash
# Use command -v to find the real cat, ignoring shell aliases
REAL_CAT=$(command -v cat)
THEME_DIR="$HOME/.dotfiles/themes"
DEST="$HOME/.config/starship.toml"
STATE="$HOME/.dotfiles/.theme_state"

[ ! -f "$STATE" ] && echo "one-dark" > "$STATE"

CURRENT_THEME=$($REAL_CAT "$STATE")

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

# 6. themes/one-dark.toml
cat << 'EOF' > themes/one-dark.toml
add_newline = true
[character]
success_symbol = "[λ](bold purple)"
error_symbol = "[λ](bold red)"
[directory]
style = "bold blue"
[git_branch]
symbol = " "
EOF

# 7. themes/glass-frosted.toml
cat << 'EOF' > themes/glass-frosted.toml
add_newline = true
[character]
success_symbol = "[❯](bold #f72585)[❯](bold #4cc9f0)"
error_symbol = "[✖](bold red)"
[directory]
style = "bold #4cc9f0"
[git_status]
style = "bold #f72585"
ahead = "⇡"
behind = "⇣"
EOF

# 8. windows-terminal.json
cat << 'EOF' > windows-terminal.json
{
    "profiles": {
        "list": [
            { "name": "WSL: One Dark", "commandline": "wsl.exe -d Ubuntu", "useAcrylic": false },
            { "name": "WSL: Glass", "commandline": "wsl.exe -d Ubuntu", "useAcrylic": true, "acrylicOpacity": 0.6 }
        ]
    }
}
EOF

chmod +x install.sh setup_links.sh scripts/theme-toggle.sh
echo "✅ Version 3 generated. Run 'tt' to test."