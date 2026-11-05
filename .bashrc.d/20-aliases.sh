# shellcheck shell=bash
alias ls='eza -lh --group-directories-first --icons=auto --git'
alias lsa='eza -lha --group-directories-first --icons=auto --git'
alias lt='eza --tree --level=2 --long --icons=auto --git'
alias lta='eza --tree --level=2 --long --icons=auto --git -a'
alias so='source ~/.bashrc'
alias nso='nvim ~/.bashrc'
alias n=nvim
alias npm=bun
alias g=git

alias claude-mare="CLAUDE_CONFIG_DIR=~/.claude-mare /home/usr/.local/share/mise/installs/claude-code/latest/claude"
# Directories change normally; non-directory arguments are passed to zoxide.
cd() {
  if (($# == 0)); then
    builtin cd "$HOME" || return
  elif [[ -d "$1" ]]; then
    builtin cd -- "$@" || return
  elif command -v zoxide >/dev/null 2>&1; then
    z "$@"
  else
    builtin cd -- "$@" || return
  fi
}

ff() {
  command -v fzf >/dev/null 2>&1 || {
    printf 'ff requires fzf.\n' >&2
    return 127
  }
  command -v fd >/dev/null 2>&1 || {
    printf 'ff requires fd.\n' >&2
    return 127
  }
  if command -v bat >/dev/null 2>&1; then
    fd --type f --hidden --exclude .git | fzf --preview 'bat --style=numbers --color=always -- {}'
  else
    fd --type f --hidden --exclude .git | fzf
  fi
}
