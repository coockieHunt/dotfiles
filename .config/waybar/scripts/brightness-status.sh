#!/bin/bash

pct=$(brightnessctl -m | awk -F, '{gsub(/%/, "", $4); print $4}')

if [ -n "$pct" ]; then
  if   (( pct >= 75 )); then icon_color="#ffe680"; icon="󰃠"
  elif (( pct >= 40 )); then icon_color="#ffd479"; icon="󰃟"
  else                       icon_color="#94A1B3"; icon="󰃞"
  fi
  tooltip="Luminosité: ${pct}%"
else
  icon_color="#94A1B3"; icon="󰃞"
  tooltip="Luminosité: N/A"
fi

text="<span size='140%' foreground='${icon_color}'>${icon}</span>"
printf '{"text":"%s","tooltip":"%s"}\n' "$text" "$tooltip"
