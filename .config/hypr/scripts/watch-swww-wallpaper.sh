#!/usr/bin/env bash

set -u

SYNC_SCRIPT="/home/jonathan/.config/waypaper/scripts/post-wallpaper.sh"
INTERVAL_SECONDS="${INTERVAL_SECONDS:-2}"
last_wallpaper=""

get_current_swww_wallpaper() {
  local line path

  line=$(swww query 2>/dev/null | head -n 1 || true)
  [ -n "$line" ] || return 1

  path=$(printf '%s\n' "$line" | sed -nE 's/.*image:[[:space:]]*(.*)$/\1/p')
  if [ -z "$path" ]; then
    path=$(printf '%s\n' "$line" | sed -nE 's/.*currently displaying:[[:space:]]*(.*)$/\1/p')
  fi

  path=${path#\"}
  path=${path%\"}

  [ -n "$path" ] && [ -f "$path" ] || return 1
  printf '%s\n' "$path"
}

while true; do
  current_wallpaper=$(get_current_swww_wallpaper || true)

  if [ -n "$current_wallpaper" ] && [ "$current_wallpaper" != "$last_wallpaper" ]; then
    "$SYNC_SCRIPT" "$current_wallpaper" >/dev/null 2>&1 || true
    last_wallpaper="$current_wallpaper"
  fi

  sleep "$INTERVAL_SECONDS"
done
