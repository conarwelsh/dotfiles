#!/bin/bash

# This script generates the entire structure for the conarwelsh/dotfiles repository.
# Run this command: bash create_dotfiles_repo.sh

echo "🛠️ Generating conarwelsh/dotfiles repository structure..."

# Create directories
mkdir -p scripts themes

# 1. README.md
cat << 'EOF' > README.md
# 🚀 Terminal Velocity: Awesome Dotfiles

A high-performance terminal environment optimized for **Turborepo, NestJS, Next.js, and Tauri**.

## 🎨 Dual-Core Themes
Switch between **One Dark Pro** (Focus) and **Glass Frosted** (Aesthetic) instantly.

**Switch Command:** `tt`

## 🛠️ Installation
Run this one-liner on any fresh Linux/WSL instance:
\`\`\`bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/conarwelsh/dotfiles/main/install.sh)"
\`\`\`

## ⌨️ Shortcuts
* `tt`: Toggle Theme
* `z`: Smart Jump (fzf)
* `td`: Turbo Dev
* `ll`: Modern LS
EOF

# 2. install.sh
cat << 'EOF' > install.sh
#!/bin/bash
set -e
REPO_URL="https://github.com/conarwelsh/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

echo "📦 Installing dependencies..."
if command -v apt-get &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y zsh git curl fzf zoxide bat ripgrep fd-find
elif command -v pacman &> /dev/null; then
    sudo pacman -Syu --noconfirm zsh git curl fzf zoxide bat ripgrep fd-find eza
elif command -v brew &> /dev/null; then
    brew install zsh git curl fzf zoxide bat ripgrep fd eza
fi

if [ ! -d "$DOTFILES_DIR" ]; then
    git clone "$REPO_URL" "$DOTFILES_DIR"
else
    cd "$DOTFILES_DIR" && git pull
fi

if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

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
echo "✨ Links synced."
EOF

# 4. .zshrc
cat << 'EOF' > .zshrc
export DOTFILES="$HOME/.dotfiles"
export PATH="$HOME/.local/bin:$PATH"

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

alias tt='source $DOTFILES/scripts/theme-toggle.sh'
alias ls='eza --icons --git --group-directories-first'
alias ll='ls -lh'
alias cat='bat --style=plain --paging=never'
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

# 5. scripts/theme-toggle.sh
cat << 'EOF' > scripts/theme-toggle.sh
#!/bin/bash
THEME_DIR="$HOME/.dotfiles/themes"
DEST="$HOME/.config/starship.toml"
STATE="$HOME/.dotfiles/.theme_state"
[ ! -f "$STATE" ] && echo "one-dark" > "$STATE"
if [ "$(cat $STATE)" == "one-dark" ]; then
    ln -sf "$THEME_DIR/glass-frosted.toml" "$DEST"
    echo "glass-frosted" > "$STATE"
    echo "💎 Glass Frosted Active"
else
    ln -sf "$THEME_DIR/one-dark.toml" "$DEST"
    echo "one-dark" > "$STATE"
    echo "🌑 One Dark Active"
fi
EOF

# 6. themes/one-dark.toml
cat << 'EOF' > themes/one-dark.toml
add_newline = true
[character]
success_symbol = "[λ](bold purple)"
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
[directory]
style = "bold #4cc9f0"
[git_status]
style = "bold #f72585"
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
echo "✅ All files generated. You can now: git init && git add . && git commit"