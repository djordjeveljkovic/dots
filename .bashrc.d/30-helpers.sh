# shellcheck shell=bash
_require_command() {
    command -v "$1" >/dev/null 2>&1 || { printf '%s requires %s.\n' "${FUNCNAME[1]}" "$1" >&2; return 127; }
}
_require_file() { [[ -f "$1" && -r "$1" ]] || { printf 'Input file is not readable: %s\n' "$1" >&2; return 1; }; }
_output_available() { [[ ! -e "$1" && ! -L "$1" ]] || { printf 'Refusing to overwrite: %s\n' "$1" >&2; return 1; }; }

compress() {
    (($# == 1)) || { printf 'Usage: compress <directory-or-file>\n' >&2; return 2; }
    [[ -e "$1" ]] || { printf 'No such input: %s\n' "$1" >&2; return 1; }
    local input=${1%/} output
    output="$input.tar.gz"
    _output_available "$output" || return
    tar -czf "$output" -- "$input"
}
decompress() {
    (($# == 1)) || { printf 'Usage: decompress <archive.tar.gz>\n' >&2; return 2; }
    _require_file "$1" || return
    tar -xzf "$1"
}

transcode-video-1080p() {
    (($# == 1)) || { printf 'Usage: transcode-video-1080p <input>\n' >&2; return 2; }
    _require_file "$1" && _require_command ffmpeg || return
    local output="${1%.*}-1080p.mp4"; _output_available "$output" || return
    ffmpeg -i "$1" -vf 'scale=1920:1080:force_original_aspect_ratio=decrease' -c:v libx264 -preset fast -crf 23 -c:a copy "$output"
}
transcode-video-4K() {
    (($# == 1)) || { printf 'Usage: transcode-video-4K <input>\n' >&2; return 2; }
    _require_file "$1" && _require_command ffmpeg || return
    local output="${1%.*}-optimized.mp4"; _output_available "$output" || return
    ffmpeg -i "$1" -c:v libx265 -preset slow -crf 24 -c:a aac -b:a 192k "$output"
}
img2jpg() {
    (($# == 1)) || { printf 'Usage: img2jpg <input>\n' >&2; return 2; }
    _require_file "$1" && _require_command magick || return
    local output="${1%.*}.jpg"; _output_available "$output" || return
    magick "$1" -quality 95 -strip "$output"
}
img2jpg-small() {
    (($# == 1)) || { printf 'Usage: img2jpg-small <input>\n' >&2; return 2; }
    _require_file "$1" && _require_command magick || return
    local output="${1%.*}.jpg"; _output_available "$output" || return
    magick "$1" -resize '1080x>' -quality 95 -strip "$output"
}
img2png() {
    (($# == 1)) || { printf 'Usage: img2png <input>\n' >&2; return 2; }
    _require_file "$1" && _require_command magick || return
    local output="${1%.*}.png"; _output_available "$output" || return
    magick "$1" -strip -define png:compression-filter=5 -define png:compression-level=9 \
        -define png:compression-strategy=1 -define png:exclude-chunk=all "$output"
}

playlist-play() {
    (($# == 1)) || { printf 'Usage: playlist-play <URL>\n' >&2; return 2; }
    _require_command yt-dlp && _require_command mpv || return
    yt-dlp --format ba -o - -- "$1" | mpv --no-video --cache=yes -
}
song-play() {
    (($# == 1)) || { printf 'Usage: song-play <URL>\n' >&2; return 2; }
    _require_command yt-dlp && _require_command mpv || return
    mkdir -p -- "$HOME/Music"
    yt-dlp --no-overwrites --extract-audio --audio-format mp3 --format 'ba/b' --write-thumbnail \
        -o "$HOME/Music/%(artist|Unknown Artist)s/%(title)s.%(ext)s" -- "$1"
}
playlist-dl-play() {
    (($# == 2)) || { printf 'Usage: playlist-dl-play <playlist-name> <URL>\n' >&2; return 2; }
    _require_command yt-dlp && _require_command mpv || return
    local name=${1//[^[:alnum:]_.-]/_} dir="$HOME/Music/${1//[^[:alnum:]_.-]/_}"
    [[ -n "$name" ]] || { printf 'Playlist name must contain letters or digits.\n' >&2; return 2; }
    mkdir -p -- "$dir"
    yt-dlp --no-overwrites --extract-audio --audio-format mp3 --format 'ba/b' --ignore-errors \
        -o "$dir/%(title)s.%(ext)s" -- "$2" || return
    mpv --no-video --playlist="$(find "$dir" -type f -name '*.mp3' -print | sort)"
}

_disk_target_check() {
    local device=$1 type mounts root_source
    [[ "$device" == /dev/* && -b "$device" ]] || { printf 'Target must be an existing block device under /dev: %s\n' "$device" >&2; return 1; }
    type=$(lsblk -dnro TYPE -- "$device" 2>/dev/null) || return 1
    [[ "$type" == disk ]] || { printf 'Target must be a whole disk (detected: %s).\n' "$type" >&2; return 1; }
    mounts=$(lsblk -nrpo MOUNTPOINT -- "$device" | awk 'NF {print}')
    [[ -z "$mounts" ]] || { printf 'Target or one of its partitions is mounted:\n%s\n' "$mounts" >&2; return 1; }
    root_source=$(findmnt -nro SOURCE / 2>/dev/null || true)
    if [[ -n "$root_source" ]] && lsblk -sno PATH -- "$root_source" 2>/dev/null | grep -Fxq -- "$device"; then
        printf 'Refusing system disk: %s backs /.\n' "$device" >&2; return 1
    fi
}
_confirm_disk() {
    local device=$1 answer
    _disk_target_check "$device" || return
    printf 'Target disk details:\n'
    lsblk -o NAME,PATH,SIZE,TYPE,FSTYPE,MOUNTPOINTS -- "$device" || return
    printf 'This operation will erase data on %s.\nType the full device path to continue: ' "$device" >&2
    IFS= read -r answer
    [[ "$answer" == "$device" ]] || { printf 'Confirmation did not match; cancelled.\n' >&2; return 1; }
}
iso2sd() {
    (($# == 2)) || { printf 'Usage: iso2sd <input.iso> <whole-disk>\n' >&2; return 2; }
    _require_file "$1" && _require_command lsblk || return
    _confirm_disk "$2" || return
    sudo dd bs=4M status=progress oflag=sync "if=$1" "of=$2" || return
    command -v eject >/dev/null 2>&1 && sudo eject "$2"
}
format-drive() {
    (($# == 2)) || { printf 'Usage: format-drive <whole-disk> <label>\n' >&2; return 2; }
    _require_command lsblk && _require_command parted && _require_command mkfs.ext4 || return
    [[ "$2" =~ ^[[:alnum:]_.-]{1,16}$ ]] || { printf 'Label must be 1-16 letters, digits, dots, underscores, or hyphens.\n' >&2; return 2; }
    _confirm_disk "$1" || return
    sudo parted -s -- "$1" mklabel gpt || return
    sudo parted -s -- "$1" mkpart primary ext4 1MiB 100% || return
    local partition="${1}1"
    [[ "$1" =~ (nvme|mmcblk|^/dev/loop) ]] && partition="${1}p1"
    sudo mkfs.ext4 -L "$2" "$partition"
}
