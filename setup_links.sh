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
