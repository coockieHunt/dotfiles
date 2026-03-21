#!/bin/bash

pct=$(brightnessctl -m | awk -F, '{gsub(/%/, "", $4); print $4}')

if [ -n "$pct" ]; then
  printf "<span size='140%%'>󰃟</span> %d%%\n" "$pct"
else
  printf "<span size='140%%'>󰃟</span> --\n"
fi
