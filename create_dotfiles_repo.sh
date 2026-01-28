#!/bin/bash

# Version 7: Fixed NVM/PNPM path persistence and installation sourcing.
# Updated with advanced dev aliases and Starship module optimizations.
# Optimized for WSL + Ubuntu + Zsh.

echo "🚀 Generating conarwelsh/dotfiles (v7 - Environment Persistence)..."

mkdir -p scripts themes

# 1. install.sh (Robust Path Handling)
cat << 'EOF' > install.sh
#!/bin/bash
set -e
REPO_URL="https://github.com/conarwelsh/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

echo "📦 Installing System Dependencies..."
if command -v apt-get &> /dev/null; then
    sudo apt-get update && sudo apt-get install -y zsh git curl fzf zoxide bat ripgrep fd-find gpg wget
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
    # Load NVM into the script session to install node
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts
else
    echo "✔️ NVM already installed."
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

echo "✅ Environment Ready!"
echo "👉 CRITICAL: Run 'source ~/.zshrc' to enable node, nvm, and pnpm."
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

# 3. .zshrc (The Engine)
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

# --- DEVELOPMENT ALIASES ---
alias sous='pnpm exec sous'
alias t='turbo'
alias td='turbo run dev'
alias tb='turbo run build'

# --- GIT ALIASES ---
alias g='git'
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gc='git commit -m'
alias gp='git push'
alias gl='git log --oneline --graph --decorate'
alias gco='git checkout'

# --- BETTER DEFAULTS (EZA) ---
if command -v eza > /dev/null; then
    # Your requested lah alias using eza
    alias ls='eza -lah --icons --git --group-directories-first'
    alias ll='eza -l --icons --git --group-directories-first'
    alias lt='eza --tree --icons'
else
    alias ls='ls -lah --color=auto'
    alias ll='ls -alF'
fi

# --- BAT (CAT REPLACEMENT) ---
if command -v bat > /dev/null; then
    alias cat='bat --style=plain --paging=never'
elif command -v batcat > /dev/null; then
    alias cat='batcat --style=plain --paging=never'
fi

# --- DOCKER ALIASES ---
alias dps='docker ps'
alias dimg='docker images'
alias ddown='docker-compose down'
alias dup='docker-compose up -d'

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

# 4. scripts/theme-toggle.sh
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

# 5. themes/one-dark.toml
cat << 'EOF' > themes/one-dark.toml
add_newline = true
[character]
success_symbol = "[λ](bold purple)"
error_symbol = "[λ](bold red)"

[directory]
style = "bold blue"
truncation_length = 3
truncation_symbol = "…/"

[nodejs]
symbol = " "
style = "bold green"
format = "via [$symbol($version )]($style)"
disabled = false # Set to true if WSL terminal lag occurs

[git_status]
style = "bold red"
EOF

# 6. themes/glass-frosted.toml
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
format = "using [$symbol($version)]($style) "
disabled = false
EOF

# 7. windows-terminal.json
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
echo "✅ Version 7 generated. Run 'bash create_dotfiles_repo.sh' then 'source ~/.zshrc'"
