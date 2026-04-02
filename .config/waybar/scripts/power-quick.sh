#!/usr/bin/env bash

set -u

action="${1:-logout}"

confirm_action() {
  local label="$1"
  local answer
  answer=$(printf "No\nYes" | wofi --dmenu --prompt "Confirm ${label}" --style ~/.config/wofi/style.css --width 320 --height 190)
  [ "$answer" = "Yes" ]
}

case "$action" in
  logout)
    if confirm_action "Logout"; then
      hyprctl dispatch exit
    fi
    ;;
  shutdown)
    if confirm_action "Shutdown"; then
      systemctl poweroff
    fi
    ;;
  reboot)
    if confirm_action "Reboot"; then
      systemctl reboot
    fi
    ;;
  *)
    exit 1
    ;;
esac
