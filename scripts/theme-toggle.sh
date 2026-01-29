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
