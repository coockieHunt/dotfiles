#!/usr/bin/env bash

# Toggle Plasma System Monitor.
if pgrep -x plasma-systemmonitor >/dev/null; then
  pkill -x plasma-systemmonitor
  exit 0
fi

plasma-systemmonitor >/dev/null 2>&1 &

# Wait for window mapping.
for _ in $(seq 1 20); do
  if hyprctl clients | grep -q "class: org.kde.plasma-systemmonitor"; then
    break
  fi
  sleep 0.05
done

hyprctl --batch "dispatch focuswindow class:^org.kde.plasma-systemmonitor$; dispatch setfloating active; dispatch pin active; dispatch resizeactive exact 85% 85%; dispatch centerwindow" >/dev/null 2>&1
