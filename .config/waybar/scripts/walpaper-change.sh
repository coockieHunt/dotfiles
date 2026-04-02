#!/usr/bin/env bash

set -u

POST_SCRIPT="/home/jonathan/.config/waypaper/scripts/post-wallpaper.sh"
LOG_FILE="/tmp/waybar-wallpaper-change.log"
POLL_INTERVAL="0.5"
MAX_POLLS="240"

if pgrep -x waypaper > /dev/null; then
	pkill -x waypaper
	exit 0
fi

get_current_wallpaper() {
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
initial_wallpaper=$(get_current_wallpaper || true)

{
	echo "[$(date '+%F %T')] launcher start"
	echo "initial_wallpaper=${initial_wallpaper}"
} >> "$LOG_FILE"

waypaper "$@" >/dev/null 2>&1 &

poll_count=0
while [ "$poll_count" -lt "$MAX_POLLS" ]; do
	current_wallpaper=$(get_current_wallpaper || true)

	if [ -n "$current_wallpaper" ] && [ "$current_wallpaper" != "$initial_wallpaper" ]; then
		{
			echo "[$(date '+%F %T')] wallpaper changed"
			echo "current_wallpaper=${current_wallpaper}"
		} >> "$LOG_FILE"
		exit 0
	fi

	sleep "$POLL_INTERVAL"
	poll_count=$((poll_count + 1))
done

echo "[$(date '+%F %T')] launcher timeout without wallpaper change" >> "$LOG_FILE"
