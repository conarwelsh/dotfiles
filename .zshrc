export DOTFILES="$HOME/.dotfiles"
export PATH="$HOME/.local/bin:$PATH"

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

alias tt='source $DOTFILES/scripts/theme-toggle.sh'

# Use 'bat' with fallback to 'cat'
if command -v bat > /dev/null; then
    alias cat='bat --style=plain --paging=never'
elif command -v batcat > /dev/null; then
    alias cat='batcat --style=plain --paging=never'
fi

# Use 'eza' with fallback to 'ls'
if command -v eza > /dev/null; then
    alias ls='eza --icons --git --group-directories-first'
    alias ll='ls -lh'
else
    alias ls='ls --color=auto'
    alias ll='ls -alF'
fi

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
