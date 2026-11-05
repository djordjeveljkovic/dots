# shellcheck shell=bash
# Interactive defaults and current prompt.
HISTCONTROL=ignoreboth
HISTSIZE=32768
HISTFILESIZE=$HISTSIZE
shopt -s histappend

git_branch() {
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
  local branch staged changed behind=0
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null) || return 0
  staged=$(git diff --cached --name-only 2>/dev/null | wc -l)
  changed=$(git diff --name-only 2>/dev/null | wc -l)
  if git show-ref --verify --quiet "refs/remotes/origin/$branch"; then
    behind=$(git rev-list --count "HEAD..origin/$branch" 2>/dev/null || printf 0)
  fi
  printf ' %s' "$branch"
  ((staged > 0)) && printf ' +%s' "$staged"
  ((changed > 0)) && printf ' ~%s' "$changed"
  ((behind > 0)) && printf ' ↓%s' "$behind"
}
case $TERM in
alacritty* | xterm* | rxvt* | screen* | tmux*)
  title='\[\e]0;\u@\h: \w\a\]'
  ;;
*)
  title=''
  ;;
esac
if ((EUID == 0)); then
  prompt_user_color=$COLOR_RED
else
  prompt_user_color=$COLOR_WHITE
fi
PS1="${title}${prompt_user_color}\\u ${COLOR_LIGHT_BLUE}\\w ${COLOR_GRAY}\$(git_branch)\\n${COLOR_LIGHT_GREEN}→${COLOR_NC} "

for path_entry in "$HOME/.local/bin" "$HOME/go/bin" "$HOME/.cargo/bin"; do
  if [[ -d "$path_entry" && ":$PATH:" != *":$path_entry:"* ]]; then
    PATH="$path_entry:$PATH"
  fi
done
export PATH
export EDITOR=nvim SUDO_EDITOR=nvim

# These files are trusted shell code. Keep machine-specific values untracked.
env_dir="$HOME/.config/bash/env.d"
if [[ -d "$env_dir" ]]; then
  for env_file in "$env_dir"/*.sh; do
    # shellcheck disable=SC1090
    [[ -f "$env_file" && -r "$env_file" ]] && source "$env_file"
  done
fi

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash 2>/dev/null)"
fi
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init bash 2>/dev/null)"
fi
if command -v fzf >/dev/null 2>&1; then
  # shellcheck disable=SC1091
  [[ -r /usr/share/fzf/key-bindings.bash ]] && source /usr/share/fzf/key-bindings.bash
  # shellcheck disable=SC1091
  [[ -r /usr/share/bash-completion/completions/fzf ]] && source /usr/share/bash-completion/completions/fzf
fi
