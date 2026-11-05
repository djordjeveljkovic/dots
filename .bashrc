# shellcheck shell=bash
force_color_prompt=yes
# Interactive Bash setup is kept in fragments so local additions stay manageable.
[[ $- == *i* ]] || return

if [[ ! -v BASH_COMPLETION_VERSINFO && -r /usr/share/bash-completion/bash_completion ]]; then
  # shellcheck disable=SC1091
  source /usr/share/bash-completion/bash_completion
fi

for fragment in "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"/.bashrc.d/*.sh; do
  # shellcheck disable=SC1090
  [[ -r "$fragment" ]] && source "$fragment"
done
