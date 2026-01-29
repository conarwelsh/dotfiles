#!/bin/bash

# Version 8.1: Workspace Optimized (FIXED Zellij Layout Paths)
# Added Zellij (Multiplexer), Lazygit (TUI), and Turborepo Workspace Layouts.
# Includes NVM, PNPM, Node LTS, and dynamic OSC color swapping.
# Optimized for WSL + Ubuntu + Zsh.

echo "🚀 Generating conarwelsh/dotfiles (v8.1 - Layout Path Fix)..."

# Create directory structure
mkdir -p scripts themes layouts

# 1. README.md
cat << 'EOF' > README.md
# 🚀 Terminal Velocity: Awesome Dotfiles

A high-performance terminal environment optimized for Web Developers. Specifically tailored for **Turborepo, NestJS, Next.js, and Tauri** workflows.

## 🎨 Dual-Core Themes
Switch between **One Dark Pro** (Focus) and **Glass Frosted** (Aesthetic) instantly.

**Switch Command:** `tt`

## 🛠️ Installation
Run this one-liner on any fresh Linux/WSL instance:
\`\`\`bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/conarwelsh/dotfiles/main/install.sh)"
\`\`\`

## ⌨️ Shortcuts
* `tt`: Toggle Theme (Changes prompt and terminal background)
* `dev`: Launch Turborepo Workspace (Editor + API Logs + Web Logs in Zellij)
* `zj`: Launch Zellij Multiplexer
* `lg`: Launch Lazygit TUI
* `z`: Smart Directory Jump (fzf)
* `ll`: Modern LS with Icons
EOF

# 2. install.sh
cat << 'EOF' > install.sh
#!/bin/bash
set -e
REPO_URL="https://github.com/conarwelsh/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

echo "📦 Installing System Dependencies..."
if command -v apt-get &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y zsh git curl fzf zoxide bat ripgrep fd-find gpg wget tar
    
    # Lazygit Installation
    if ! command -v lazygit &> /dev/null; then
        LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
        curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
        tar xf lazygit.tar.gz lazygit
        sudo install lazygit /usr/local/bin
        rm lazygit.tar.gz lazygit
    fi

    # Zellij Installation
    if ! command -v zellij &> /dev/null; then
        curl -L https://github.com/zellij-org/zellij/releases/latest/download/zellij-x86_64-unknown-linux-musl.tar.gz -o zellij.tar.gz
        tar -xvf zellij.tar.gz
        sudo install zellij /usr/local/bin
        rm zellij.tar.gz zellij
    fi

    mkdir -p "$HOME/.local/bin"
    [ ! -f "$HOME/.local/bin/bat" ] && ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"
    
    # Official eza installation
    if ! command -v eza &> /dev/null; then
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update && sudo apt install -y eza
    fi
fi

# Clone Dotfiles if not present
[ ! -d "$DOTFILES_DIR" ] && git clone "$REPO_URL" "$DOTFILES_DIR"

# Install Starship
command -v starship &> /dev/null || curl -sS https://starship.rs/install.sh | sh -s -- -y

# --- NVM Installation ---
export NVM_DIR="$HOME/.nvm"
if [ ! -d "$NVM_DIR" ]; then
    echo "🟢 Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
else
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
fi

# --- PNPM Installation ---
if ! command -v pnpm &> /dev/null; then
    echo "🟢 Installing PNPM..."
    curl -fsSL https://get.pnpm.io/install.sh | sh -
fi

# Run Linker
chmod +x "$DOTFILES_DIR/setup_links.sh"
"$DOTFILES_DIR/setup_links.sh"

# Set Zsh as default
[ "$SHELL" != "$(which zsh)" ] && chsh -s "$(which zsh)"

echo "✅ Full Stack Setup Complete! Run: source ~/.zshrc"
EOF

# 3. setup_links.sh (FIXED LAYOUT PATH)
cat << 'EOF' > setup_links.sh
#!/bin/bash
DOTFILES_DIR="$HOME/.dotfiles"
CONFIG_DIR="$HOME/.config"

# Create necessary directories
mkdir -p "$CONFIG_DIR/zellij/layouts" 
mkdir -p "$HOME/.local/bin"

# Core Configs
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
chmod +x "$DOTFILES_DIR/scripts/theme-toggle.sh"
ln -sf "$DOTFILES_DIR/scripts/theme-toggle.sh" "$HOME/.local/bin/tt"
ln -sf "$DOTFILES_DIR/themes/one-dark.toml" "$CONFIG_DIR/starship.toml"

# Zellij Layouts (Linked to the 'layouts' subfolder where Zellij looks)
ln -sf "$DOTFILES_DIR/layouts/turbo.kdl" "$CONFIG_DIR/zellij/layouts/turbo.kdl"

echo "✨ Links synchronized."
EOF

# 4. .zshrc
cat << 'EOF' > .zshrc
# --- ZSH Performance ---
zstyle ':completion:*:*:docker:*' cache-policy dummy
autoload -Uz compinit && compinit -i -u

# --- PATHS ---
export DOTFILES="$HOME/.dotfiles"
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"

# --- NVM (Node Version Manager) ---
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# --- PNPM ---
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# --- Prompt & Utils ---
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# --- CORE ALIASES ---
alias tt='source $DOTFILES/scripts/theme-toggle.sh'
alias reload='source ~/.zshrc'
alias c='clear'

# --- WORKSPACE & MULTIPLEXING ---
alias zj='zellij'
alias lg='lazygit'
alias dev='zellij --layout turbo'

# --- DEVELOPMENT ALIASES ---
alias sous='pnpm exec sous'
alias t='turbo'
alias td='turbo run dev'
alias tb='turbo run build'
alias tauri='cargo tauri'

# --- GIT ALIASES ---
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'

# --- BETTER DEFAULTS (EZA) ---
if command -v eza > /dev/null; then
    alias ls='eza -lah --icons --git --group-directories-first'
    alias ll='eza -l --icons --git --group-directories-first'
    alias lt='eza --tree --icons'
else
    alias ls='ls -lah --color=auto'
    alias ll='ls -alF'
fi

if command -v bat > /dev/null; then
    alias cat='bat --style=plain --paging=never'
elif command -v batcat > /dev/null; then
    alias cat='batcat --style=plain --paging=never'
fi

# --- Smart Jumper ---
z() {
  if [[ "$#" -eq 0 ]]; then
    local dir=$(zoxide query -l | fzf --height 40% --reverse)
    [[ -n "$dir" ]] && cd "$dir"
  else
    zoxide "$@"
  fi
}
EOF

# 5. scripts/theme-toggle.sh
cat << 'EOF' > scripts/theme-toggle.sh
#!/bin/zsh
THEME_DIR="$HOME/.dotfiles/themes"
DEST="$HOME/.config/starship.toml"
STATE="$HOME/.dotfiles/.theme_state"

[[ ! -f "$STATE" ]] && echo "one-dark" > "$STATE"
local CURRENT_THEME=$(<"$STATE")

if [[ "$CURRENT_THEME" == "one-dark" ]]; then
    ln -sf "$THEME_DIR/glass-frosted.toml" "$DEST"
    echo "glass-frosted" > "$STATE"
    printf "\033]11;#0b0e14\007" 
    printf "\033]10;#c0caf5\007" 
    echo "💎 Theme: Glass Frosted"
else
    ln -sf "$THEME_DIR/one-dark.toml" "$DEST"
    echo "one-dark" > "$STATE"
    printf "\033]11;#282c34\007" 
    printf "\033]10;#abb2bf\007" 
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
truncation_length = 3
[nodejs]
symbol = " "
style = "bold green"
disabled = false
EOF

# 7. themes/glass-frosted.toml
cat << 'EOF' > themes/glass-frosted.toml
add_newline = true
[character]
success_symbol = "[❯](bold #f72585)[❯](bold #4cc9f0)"
error_symbol = "[✖](bold red)"
[directory]
style = "bold #4cc9f0"
format = "in [$path]($style) "
[nodejs]
symbol = "󰎙 "
style = "bold #4361ee"
disabled = false
EOF

# 8. layouts/turbo.kdl
cat << 'EOF' > layouts/turbo.kdl
layout {
    pane size=1 borderless=true {
        plugin location="zellij:tab-bar"
    }
    pane split_direction="vertical" {
        pane size="60%" name="EDITOR" focus=true
        pane split_direction="horizontal" {
            pane name="API LOGS (NestJS)" command="pnpm" {
                args "run" "dev" "--filter" "api"
            }
            pane name="WEB LOGS (Next.js)" command="pnpm" {
                args "run" "dev" "--filter" "web"
            }
        }
    }
    pane size=2 borderless=true {
        plugin location="zellij:status-bar"
    }
}
EOF

# 9. windows-terminal.json
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
echo "✅ Master Repository Files Generated Successfully (v8.1)!"
echo "Next Steps:"
echo "1. Run: ./setup_links.sh"
echo "2. Run: dev"
