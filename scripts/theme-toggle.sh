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