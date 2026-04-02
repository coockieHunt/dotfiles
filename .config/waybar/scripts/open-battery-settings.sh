#!/usr/bin/env bash

# Open battery/power settings with desktop-aware fallbacks.
if command -v kcmshell6 >/dev/null 2>&1; then
  exec kcmshell6 kcm_powerdevilprofilesconfig
fi

if command -v systemsettings6 >/dev/null 2>&1; then
  exec systemsettings6 kcm_powerdevilprofilesconfig
fi

if command -v systemsettings5 >/dev/null 2>&1; then
  exec systemsettings5 kcm_powerdevilprofilesconfig
fi

if command -v gnome-control-center >/dev/null 2>&1; then
  exec gnome-control-center power
fi

if command -v xfce4-power-manager-settings >/dev/null 2>&1; then
  exec xfce4-power-manager-settings
fi

if command -v notify-send >/dev/null 2>&1; then
  notify-send "Battery settings" "No supported power settings app found."
fi

exit 1
