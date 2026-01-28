export DOTFILES="$HOME/.dotfiles"
export PATH="$HOME/.local/bin:$PATH"

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

alias tt='source $DOTFILES/scripts/theme-toggle.sh'
alias ls='eza --icons --git --group-directories-first'
alias ll='ls -lh'
alias cat='bat --style=plain --paging=never'
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
