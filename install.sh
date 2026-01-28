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
