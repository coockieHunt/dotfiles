#!/usr/bin/env bash

set -u


wallpaper_path="${1:-}"
log_file="/tmp/waypaper-post-command.log"
eww_config_dir="/home/jonathan/.config/eww"
eww_palette_file="$eww_config_dir/wal-colors.scss"
wal_palette_file="/home/jonathan/.cache/wal/colors.scss"

if [ -z "$wallpaper_path" ] || [ ! -f "$wallpaper_path" ]; then
  swww_path=$(swww query 2>/dev/null | head -n1 | sed -nE 's/.*image:[[:space:]]*(.*)$/\1/p')
  if [ -n "$swww_path" ] && [ -f "$swww_path" ]; then
    wallpaper_path="$swww_path"
  fi
fi

reload_components() {
  pkill -SIGUSR2 waybar 2>/dev/null || true

  if [ -f "$wal_palette_file" ]; then
    cp "$wal_palette_file" "$eww_palette_file"
  fi

  eww --config "$eww_config_dir" kill 2>/dev/null || true
  sleep 0.5
  eww --config "$eww_config_dir" --restart open-many dashboard dashboard_fastfetch 2>/dev/null \
    || { eww --config "$eww_config_dir" --restart open dashboard 2>/dev/null || true; eww --config "$eww_config_dir" open dashboard_fastfetch 2>/dev/null || true; }
}

{
  echo "[$(date '+%F %T')] post-wallpaper start"
  echo "wallpaper: ${wallpaper_path}"

  if [ -n "$wallpaper_path" ] && [ -f "$wallpaper_path" ]; then
    echo "[post-wallpaper] Using wallpaper: $wallpaper_path"
    wal -i "$wallpaper_path"
  else
    echo "[post-wallpaper] No valid wallpaper found, restoring wal cache."
    wal -R
  fi

  if [ -f "$wal_palette_file" ]; then
    cp "$wal_palette_file" "$eww_palette_file"
    echo "[post-wallpaper] Synced Eww palette: $eww_palette_file"
  else
    echo "[post-wallpaper] Missing wal palette file: $wal_palette_file"
  fi


  sleep 0.2
  reload_components
  eww --config "$eww_config_dir" reload 2>/dev/null || true
  bash ~/.config/waypaper/scripts/convert-theme.sh

  if pgrep -x kitty > /dev/null && [ -S /tmp/kitty ]; then
    kitty @ --to unix:/tmp/kitty set-colors --all ~/.cache/wal/colors-kitty.conf 2>/dev/null || true
  fi

  swaync-client --reload-css 2>/dev/null || true

  echo "[$(date '+%F %T')] post-wallpaper end"
} >> "$log_file" 2>&1
