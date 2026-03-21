#!/usr/bin/env bash

confirm() {
  local label="$1"
  local answer
  answer=$(printf "No\nYes" | wofi --dmenu --prompt "Confirm $label" --style /home/jonathan/.config/wofi/style.css --width 320 --height 190)
  [[ "$answer" == "Yes" ]]
}

can_use_gcc() {
  [[ "${XDG_CURRENT_DESKTOP:-}" == *GNOME* || "${XDG_CURRENT_DESKTOP:-}" == *Unity* ]]
}

can_use_kde() {
  command -v kcmshell6 >/dev/null 2>&1
}

case "$1" in
  audio)
    if command -v gnome-control-center >/dev/null 2>&1 && can_use_gcc; then
      gnome-control-center sound &
    elif command -v pavucontrol-qt >/dev/null 2>&1; then
      pavucontrol-qt &
    elif command -v pavucontrol >/dev/null 2>&1; then
      pavucontrol &
    fi
    ;;
  wifi)
    if can_use_kde; then
      kcmshell6 kcm_networkmanagement &
    elif command -v gnome-control-center >/dev/null 2>&1 && can_use_gcc; then
      gnome-control-center network &
    elif command -v nm-connection-editor >/dev/null 2>&1; then
      nm-connection-editor &
    elif command -v nm-applet >/dev/null 2>&1; then
      nm-applet &
    fi
    ;;
  wifi-toggle)
    if [[ "$(nmcli radio wifi)" == "enabled" ]]; then
      nmcli radio wifi off
    else
      nmcli radio wifi on
    fi
    ;;
  mute)
    pactl set-sink-mute @DEFAULT_SINK@ toggle
    ;;
  bluetooth)
    if can_use_kde; then
      kcmshell6 kcm_bluetooth &
    elif command -v gnome-control-center >/dev/null 2>&1 && can_use_gcc; then
      gnome-control-center bluetooth &
    elif command -v blueman-manager >/dev/null 2>&1; then
      blueman-manager &
    fi
    ;;
  lock)
    if command -v hyprlock >/dev/null 2>&1; then
      hyprlock
    else
      loginctl lock-session
    fi
    ;;
  logout)
    hyprctl dispatch exit
    ;;
  reboot)
    if confirm "Reboot"; then
      systemctl reboot
    fi
    ;;
  shutdown)
    if confirm "Shutdown"; then
      systemctl poweroff
    fi
    ;;
  *)
    exit 1
    ;;
esac
