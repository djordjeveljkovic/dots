#!/usr/bin/env bash
set -uo pipefail

dot_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
home=${HOME:?HOME must be set}
config_home=${XDG_CONFIG_HOME:-"$home/.config"}
mode=${1:-check}

usage() { printf 'Usage: %s [setup|check]\n' "${0##*/}"; }
if (( $# > 1 )); then usage >&2; exit 2; fi
case "$mode" in
    setup|check) ;;
    -h|--help|help) usage; exit 0 ;;
    *) usage >&2; exit 2 ;;
esac

issues=0
report_error() { printf 'ERROR: %s\n' "$*"; issues=$((issues + 1)); }

printf 'Official Arch packages (%s):\n' "$dot_dir/packages.txt"
if ! command -v pacman >/dev/null 2>&1; then
    report_error 'pacman is unavailable; package state cannot be checked.'
else
    missing=()
    while IFS= read -r pkg || [[ -n "$pkg" ]]; do
        [[ -z "$pkg" || "$pkg" == \#* ]] && continue
        if ! pacman -Q "$pkg" >/dev/null 2>&1; then missing+=("$pkg"); fi
    done < "$dot_dir/packages.txt"
    if ((${#missing[@]})); then
        printf 'Missing official packages: %s\n' "${missing[*]}"
        if [[ "$mode" == setup ]]; then
            if ! sudo pacman -S --needed "${missing[@]}"; then report_error 'pacman installation failed.'; fi
        fi
    else
        printf 'All declared official packages are installed.\n'
    fi
fi

printf '\nAUR packages (manual review only):\n'
while IFS= read -r pkg || [[ -n "$pkg" ]]; do
    [[ -z "$pkg" || "$pkg" == \#* ]] && continue
    printf '  %s: review source at https://aur.archlinux.org/packages/%s\n' "$pkg" "$pkg"
done < "$dot_dir/aur-packages.txt"

printf '\nmise tools:\n'
if command -v mise >/dev/null 2>&1; then
    if [[ "$mode" == setup ]]; then
        (cd -- "$dot_dir" && mise install) || report_error 'mise install failed.'
    else
        (cd -- "$dot_dir" && mise ls --current) || report_error 'Unable to inspect mise tools.'
        printf 'Declared selectors:\n'
        sed -n '/^\[tools\]/,/^\[/p' "$dot_dir/.config/mise/config.toml" | sed '1d'
    fi
else
    report_error 'mise is unavailable; tool state cannot be checked.'
fi

printf '\nConfiguration links:\n'
apps=(alacritty fuzzel htop mako mise nvim sway swayimg tmux yazi)
for app in "${apps[@]}"; do
    source_dir="$dot_dir/.config/$app"
    target="$config_home/$app"
    if [[ -L "$target" && "$(readlink -f -- "$target" 2>/dev/null || true)" == "$source_dir" ]]; then
        printf '  linked: %s\n' "$target"
    elif [[ "$mode" == setup ]]; then
        :
    else
        printf '  needs link or review: %s\n' "$target"
        issues=$((issues + 1))
    fi
done
home_files=(.bashrc .bashrc.d .inputrc .bash_profile)
for item in "${home_files[@]}"; do
    source_path="$dot_dir/$item"
    target="$home/$item"
    if [[ -L "$target" && "$(readlink -f -- "$target" 2>/dev/null || true)" == "$(readlink -f -- "$source_path" 2>/dev/null || true)" ]]; then
        printf '  linked: %s\n' "$target"
    elif [[ "$mode" == check ]]; then
        printf '  needs link or review: %s\n' "$target"
        issues=$((issues + 1))
    fi
done
if [[ "$mode" == setup ]]; then
    "$dot_dir/install.sh" || report_error 'Config linking failed.'
fi

printf '\nClipboard picker:\n'
target="$home/Scripts/bin/clipboard-history"
if [[ -L "$target" && -x "$target" && "$(readlink -f -- "$target" 2>/dev/null || true)" == "$dot_dir/bin/clipboard-history" ]]; then
    printf '  linked: %s\n' "$target"
else
    report_error "Clipboard picker needs an executable link: $target"
fi
for dependency in alacritty fzf ueberzugpp cliphist wl-copy wl-paste jq file flock; do
    command -v "$dependency" >/dev/null 2>&1 || report_error "Clipboard picker dependency missing: $dependency"
done
bash -n "$dot_dir/bin/clipboard-history" || report_error 'Clipboard picker Bash syntax check failed.'
if command -v shellcheck >/dev/null 2>&1; then
    shellcheck "$dot_dir/bin/clipboard-history" || report_error 'Clipboard picker ShellCheck failed.'
fi

printf '\nHome folders and bookmarks:\n'
if [[ "$mode" == setup ]]; then
    "$dot_dir/bin/organize-home" --setup || report_error 'Home organization setup failed.'
else
    folders=(Projects/repos/work Projects/repos/lab Projects/repos/hardware
        Projects/local/work Projects/local/lab Projects/local/hardware
        System/arch/packages System/arch/archive System/arch/local
        Scripts/bin Scripts/share/emoji-picker Documents/work Documents/lab
        Downloads/archives Downloads/documents Downloads/images Downloads/installers
        Downloads/other Downloads/spreadsheets Downloads/web Pictures/Photos
        Pictures/Screenshots Pictures/Wallpapers Music Archive/projects)
    for folder in "${folders[@]}"; do
        if [[ -d "$home/$folder" ]]; then printf '  present: %s\n' "$home/$folder"
        else printf '  missing: %s\n' "$home/$folder"; issues=$((issues + 1)); fi
    done
    bookmark_file="$config_home/gtk-3.0/bookmarks"
    for name in Documents Downloads Music Pictures Projects Scripts System; do
        path="$home/$name"
        uri_path=${path//%/%25}; uri_path=${uri_path// /%20}
        uri_path=${uri_path//#/%23}; uri_path=${uri_path//\?/%3F}
        uri="file://$uri_path"
        if [[ -f "$bookmark_file" ]] && awk -v uri="$uri" '$1 == uri { found=1 } END { exit !found }' "$bookmark_file"; then
            printf '  bookmark present: %s\n' "$name"
        else printf '  bookmark missing: %s\n' "$name"; issues=$((issues + 1)); fi
    done
    "$dot_dir/bin/organize-home" --check || report_error 'Home organization check failed.'
fi

printf '\nFailed system units:\n'
if command -v systemctl >/dev/null 2>&1; then
    failed=$(systemctl --failed --no-legend --plain 2>&1)
    status=$?
    if (( status != 0 )); then report_error "systemctl --failed could not be read: $failed"
    elif [[ -n "$failed" ]]; then printf '%s\n' "$failed"; issues=$((issues + 1))
    else printf 'None reported.\n'; fi
else
    report_error 'systemctl is unavailable.'
fi

printf '\nCurrent-boot warnings and errors:\n'
if command -v journalctl >/dev/null 2>&1; then
    journal=$(journalctl -b -p warning..alert --no-pager -o short-iso -n 40 2>&1)
    status=$?
    if (( status != 0 )); then report_error "journal access failed: $journal"
    elif [[ -n "$journal" ]]; then
        # Journal stack traces span multiple lines; retain entry headers so the
        # health report stays readable while preserving each warning summary.
        printf '%s\n' "$journal" | awk '/^[0-9]{4}-[0-9]{2}-[0-9]{2}T/ { print }'
    else printf 'None reported.\n'; fi
else
    report_error 'journalctl is unavailable.'
fi

if (( issues )); then
    printf '\nCompleted with %d item(s) requiring attention.\n' "$issues"
    exit 1
fi
printf '\n%s completed without reported issues.\n' "$mode"
