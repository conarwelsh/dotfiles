#!/bin/zsh
THEME_DIR="$HOME/.dotfiles/themes"
DEST="$HOME/.config/starship.toml"
STATE="$HOME/.dotfiles/.theme_state"

[[ ! -f "$STATE" ]] && echo "one-dark" > "$STATE"
local CURRENT_THEME=$(<"$STATE")

if [[ "$CURRENT_THEME" == "one-dark" ]]; then
    # --- Switch to Glass Frosted ---
    ln -sf "$THEME_DIR/glass-frosted.toml" "$DEST"
    echo "glass-frosted" > "$STATE"
    
    # OSC 11: Set Background to deep midnight
    printf "\033]11;#0b0e14\007"
    # OSC 10: Set Foreground to cyan
    printf "\033]10;#c0caf5\007"
    
    echo "💎 Theme: Glass Frosted (Presentation Mode)"
else
    # --- Switch to One Dark Pro ---
    ln -sf "$THEME_DIR/one-dark.toml" "$DEST"
    echo "one-dark" > "$STATE"
    
    # OSC 11: Set Background to One Dark Grey
    printf "\033]11;#282c34\007"
    # OSC 10: Set Foreground to One Dark Silver
    printf "\033]10;#abb2bf\007"
    
    echo "🌑 Theme: One Dark Pro (Focus Mode)"
fi
