#!/bin/bash

# Step brightness while snapping to 10% boundaries.
# Usage: brightness-step.sh up|down

dir="$1"
max=$(brightnessctl m)
pct=$(brightnessctl -m | awk -F, '{gsub(/%/, "", $4); print $4}')

if [ -z "$pct" ] || [ -z "$max" ] || [ "$max" -le 0 ]; then
  exit 1
fi

case "$dir" in
  up)
    if [ $((pct % 10)) -eq 0 ]; then
      target=$((pct + 10))
    else
      target=$((((pct + 9) / 10) * 10))
    fi
    ;;
  down)
    if [ $((pct % 10)) -eq 0 ]; then
      target=$((pct - 10))
    else
      target=$(((pct / 10) * 10))
    fi
    ;;
  *)
    exit 1
    ;;
esac

if [ "$target" -lt 0 ]; then
  target=0
fi
if [ "$target" -gt 100 ]; then
  target=100
fi

target_raw=$(((target * max + 50) / 100))
brightnessctl set "$target_raw" >/dev/null
