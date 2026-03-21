#!/usr/bin/env bash

# Toggle power profile settings.
if hyprctl clients | grep -q 'class: org.kde.systemsettings\|class: systemsettings'; then
  hyprctl dispatch closewindow class:^(org.kde.systemsettings|systemsettings)$ >/dev/null 2>&1
  exit 0
fi

# Open power profile settings when available; otherwise fall back to energy info.
module="kcm_energyinfo"
if systemctl is-active --quiet power-profiles-daemon.service; then
  module="kcm_powerdevilprofilesconfig"
fi

kcmshell6 "$module" >/dev/null 2>&1 &
pid=$!

# Wait for the KCM window then force overlay geometry in Hyprland.
for _ in $(seq 1 30); do
  if hyprctl clients | grep -q "pid: $pid"; then
    break
  fi
  sleep 0.05
done

hyprctl --batch "dispatch focuswindow pid:$pid; dispatch setfloating active; dispatch pin active; dispatch resizeactive exact 85% 85%; dispatch centerwindow" >/dev/null 2>&1

# Fallback for setups where the visible KCM window is owned by systemsettings.
hyprctl --batch "dispatch focuswindow class:^(org.kde.systemsettings|systemsettings)$; dispatch setfloating active; dispatch pin active; dispatch resizeactive exact 85% 85%; dispatch centerwindow" >/dev/null 2>&1
