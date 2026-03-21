#!/usr/bin/env bash

# Toggle CPU/power profile settings.
if hyprctl clients | grep -q 'class: org.kde.systemsettings\|class: systemsettings'; then
  hyprctl dispatch closewindow class:^(org.kde.systemsettings|systemsettings)$ >/dev/null 2>&1
  exit 0
fi

kcmshell6 kcm_powerdevilprofilesconfig >/dev/null 2>&1 &
pid=$!

# Keep the KCM in overlay mode when possible.
for _ in $(seq 1 30); do
  if hyprctl clients | grep -q "pid: $pid"; then
    break
  fi
  sleep 0.05
done

hyprctl --batch "dispatch focuswindow pid:$pid; dispatch setfloating active; dispatch pin active; dispatch resizeactive exact 85% 85%; dispatch centerwindow" >/dev/null 2>&1
