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
