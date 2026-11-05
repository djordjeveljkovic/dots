#!/usr/bin/env bash
set -euo pipefail

dot_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
config_home=${XDG_CONFIG_HOME:-"$HOME/.config"}
state_home=${XDG_STATE_HOME:-"$HOME/.local/state"}
apps=(alacritty fuzzel htop mako mise nvim sway swayimg tmux yazi)
home_files=(.bashrc .bashrc.d .inputrc .bash_profile)
backup_root=''

mkdir -p -- "$config_home"

for app in "${apps[@]}"; do
    source_dir="$dot_dir/.config/$app"
    target="$config_home/$app"

    if [[ ! -d "$source_dir" ]]; then
        printf 'Missing config source: %s\n' "$source_dir" >&2
        exit 1
    fi

    if [[ -L "$target" ]] && [[ "$(readlink -f -- "$target" 2>/dev/null || true)" == "$source_dir" ]]; then
        continue
    fi

    if [[ -e "$target" || -L "$target" ]]; then
        if [[ -z "$backup_root" ]]; then
            mkdir -p -- "$state_home"
            backup_root=$(mktemp -d "$state_home/dot-backups.XXXXXX")
        fi
        mv -- "$target" "$backup_root/$app"
        printf 'Backed up %s to %s\n' "$target" "$backup_root/$app"
    fi

    ln -s -- "$source_dir" "$target"
    printf 'Linked %s -> %s\n' "$target" "$source_dir"
done

for item in "${home_files[@]}"; do
    source_path="$dot_dir/$item"
    target="$HOME/$item"
    if [[ ! -e "$source_path" && ! -L "$source_path" ]]; then
        printf 'Missing home config source: %s\n' "$source_path" >&2
        exit 1
    fi
    if [[ -L "$target" && "$(readlink -f -- "$target" 2>/dev/null || true)" == "$(readlink -f -- "$source_path")" ]]; then
        continue
    fi
    if [[ -e "$target" || -L "$target" ]]; then
        if [[ -z "$backup_root" ]]; then
            mkdir -p -- "$state_home"
            backup_root=$(mktemp -d "$state_home/dot-backups.XXXXXX")
        fi
        mv -- "$target" "$backup_root/$item"
        printf 'Backed up %s to %s\n' "$target" "$backup_root/$item"
    fi
    ln -s -- "$source_path" "$target"
    printf 'Linked %s -> %s\n' "$target" "$source_path"
done

scripts=(clipboard-history)
mkdir -p -- "$HOME/Scripts/bin"
for script in "${scripts[@]}"; do
    source_path="$dot_dir/bin/$script"
    target="$HOME/Scripts/bin/$script"
    [[ -x "$source_path" ]] || { printf 'Missing executable: %s\n' "$source_path" >&2; exit 1; }
    if [[ -L "$target" && "$(readlink -f -- "$target" 2>/dev/null || true)" == "$source_path" ]]; then
        continue
    fi
    if [[ -e "$target" || -L "$target" ]]; then
        if [[ -z "$backup_root" ]]; then
            mkdir -p -- "$state_home"
            backup_root=$(mktemp -d "$state_home/dot-backups.XXXXXX")
        fi
        mv -- "$target" "$backup_root/Scripts-bin-$script"
        printf 'Backed up %s to %s\n' "$target" "$backup_root/Scripts-bin-$script"
    fi
    ln -s -- "$source_path" "$target"
    printf 'Linked %s -> %s\n' "$target" "$source_path"
done

# tmux plugins are pinned clones, not tracked in this repository.
tmux_plugins=(
    "tmux-resurrect https://github.com/tmux-plugins/tmux-resurrect cff343cf9e81983d3da0c8562b01616f12e8d548"
    "tmux-continuum https://github.com/tmux-plugins/tmux-continuum 0698e8f4b17d6454c71bf5212895ec055c578da0"
)
for entry in "${tmux_plugins[@]}"; do
    read -r name url rev <<< "$entry"
    target="$dot_dir/.config/tmux/plugins/$name"
    [[ -d "$target/.git" ]] && continue
    git clone --quiet -- "$url" "$target"
    git -C "$target" checkout --quiet "$rev"
    printf 'Cloned tmux plugin %s at %s\n' "$name" "${rev:0:7}"
done

if [[ -n "$backup_root" ]]; then
    printf 'Config backups: %s\n' "$backup_root"
fi
