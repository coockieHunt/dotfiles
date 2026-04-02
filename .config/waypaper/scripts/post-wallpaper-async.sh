#!/usr/bin/env bash
setsid /home/jonathan/.config/waypaper/scripts/post-wallpaper.sh "$1" </dev/null >/dev/null 2>&1 &
