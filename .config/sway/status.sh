#!/bin/bash

format_memory() {
  awk '/^MemTotal:/ { total = $2 } /^MemAvailable:/ { available = $2 } END { used = total - available; printf "%.1f/%.1fG", used / 1048576, total / 1048576 }' /proc/meminfo
}

get_interface() {
  local_if=$(ip route | grep '^default' | awk '{print $5}' | head -n1)
  [ -z "$local_if" ] && local_if=$(ip link show | grep UP | awk -F: '{print $2}' | tr -d ' ' | grep -v 'lo' | head -n1)
  echo "$local_if"
}

read_bytes() {
  if [ -n "$1" ] && [ -f "/sys/class/net/$1/statistics/rx_bytes" ]; then
    rx=$(cat /sys/class/net/$1/statistics/rx_bytes)
    tx=$(cat /sys/class/net/$1/statistics/tx_bytes)
    echo "$rx $tx"
  else
    echo "0 0"
  fi
}

format_speed() {
  bytes=$1
  if [ "$bytes" -gt 1073741824 ]; then
    awk "BEGIN {printf \"%.1f GB/s\", $bytes / 1073741824}"
  elif [ "$bytes" -gt 1048576 ]; then
    awk "BEGIN {printf \"%.1f MB/s\", $bytes / 1048576}"
  elif [ "$bytes" -gt 1024 ]; then
    awk "BEGIN {printf \"%.1f KB/s\", $bytes / 1024}"
  else
    printf "%d B/s" "$bytes"
  fi
}

get_battery() {
  if [ -d /sys/class/power_supply/BAT0 ]; then
    cap=$(cat /sys/class/power_supply/BAT0/capacity 2>/dev/null)
    echo "🔋 ${cap}%"
  else
    echo ""
  fi
}

# i3bar protocol header
printf '{"version":1}\n[\n'

while true; do
  cpu=$(format_cpu)
  memory=$(format_memory)
  INTERFACE=$(get_interface)
  if [ -n "$INTERFACE" ] && [ -d "/sys/class/net/$INTERFACE" ]; then
    read rx1 tx1 < <(read_bytes "$INTERFACE")
    sleep 1
    read rx2 tx2 < <(read_bytes "$INTERFACE")
    rx_rate=$((rx2 - rx1))
    tx_rate=$((tx2 - tx1))
    net_text="↓ $(format_speed $rx_rate) ↑ $(format_speed $tx_rate) [$INTERFACE]"
  else
    net_text="⚠ No connection"
    sleep 1
  fi

  bat=$(get_battery)
  datetime=$(date +'%H:%M:%S %d/%m/%Y')
  cpu_memory="| RAM $memory |"

  if [ -n "$bat" ]; then
    printf '[{"full_text": "%s", "color": "#9ccfd8", "separator":false}, {"full_text": "%s", "color": "#e0def4"}, {"full_text": "%s", "color": "#ebbcba"}, {"full_text": "%s", "color": "#e0def4"}],\n' "$net_text" "$cpu_memory" "$bat" "$datetime"
  else
    printf '[{"full_text": "%s", "color": "#9ccfd8", "separator":false}, {"full_text": "%s", "color": "#e0def4", "separator":false}, {"full_text": "%s", "color": "#e0def4"}],\n' "$net_text" "$cpu_memory" "$datetime"
  fi
done
