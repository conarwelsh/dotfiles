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
