# shellcheck shell=bash
# Login shell setup. Start Sway only from the first virtual terminal and only
# when no graphical session is already active. uwsm runs Sway as a systemd
# unit so apps get their own scopes; plain Sway is the fallback.
[[ -r "$HOME/.bashrc" ]] && source "$HOME/.bashrc"
if [[ -z "${DISPLAY:-}" && -z "${WAYLAND_DISPLAY:-}" && "$(tty 2>/dev/null)" == /dev/tty1 ]] && command -v sway >/dev/null 2>&1; then
    if command -v uwsm >/dev/null 2>&1 && uwsm check may-start; then
        exec uwsm start sway.desktop
    fi
    exec sway
fi
