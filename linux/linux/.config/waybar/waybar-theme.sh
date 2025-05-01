#!/bin/bash

THEMES_DIR="$HOME/.config/waybar/themes"
ACTIVE="$THEMES_DIR/active.css"

if [ "$1" == "gruvbox" ]; then
  ln -sf "$THEMES_DIR/gruvbox.css" "$ACTIVE"
elif [ "$1" == "rosepine" ]; then
  ln -sf "$THEMES_DIR/rosepine.css" "$ACTIVE"
else
  echo "Usage: $0 {gruvbox|rosepine}"
  exit 1
fi

killall -q waybar
while pgrep -x waybar >/dev/null; do sleep 0.1; done
waybar &
# Reload Waybar
