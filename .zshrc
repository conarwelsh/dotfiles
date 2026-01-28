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
