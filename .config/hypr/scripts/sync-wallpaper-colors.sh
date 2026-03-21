#!/usr/bin/env bash

set -u

HYPRPAPER_CONF="/home/jonathan/.config/hypr/hyprpaper.conf"
WAYBAR_PALETTE="/home/jonathan/.config/waybar/palette.css"
SWAYNC_PALETTE="/home/jonathan/.config/swaync/palette.css"
EWW_PALETTE="/home/jonathan/.config/eww/palette.scss"

fallback_primary="#7EA2FF"
fallback_secondary="#78E6FF"
fallback_success="#9DF3B0"
fallback_warning="#FFD166"
fallback_danger="#FF7F7F"

get_wallpaper_path() {
  local line

  line=$(grep -E '^wallpaper\s*=\s*' "$HYPRPAPER_CONF" | head -n 1)
  if [ -n "$line" ]; then
    echo "$line" | sed -E 's/^wallpaper\s*=\s*[^,]+,//'
    return
  fi

  line=$(grep -E '^preload\s*=\s*' "$HYPRPAPER_CONF" | head -n 1)
  if [ -n "$line" ]; then
    echo "$line" | sed -E 's/^preload\s*=\s*//'
    return
  fi

  echo ""
}

extract_colors() {
  local wallpaper="$1"
  magick "$wallpaper" \
    -resize 180x180^ \
    -gravity center \
    -extent 180x180 \
    -colors 10 \
    -format '%c\n' histogram:info:- 2>/dev/null \
  | awk 'match($0, /([0-9]+):.*(#[0-9A-Fa-f]{6})/, a) {print a[1] " " toupper(a[2])}' \
  | sort -nr \
  | awk '!seen[$2]++ {print $2}'
}

hex_luma() {
  local hex="$1"
  local r g b
  r=$((16#${hex:1:2}))
  g=$((16#${hex:3:2}))
  b=$((16#${hex:5:2}))
  echo $(((299 * r + 587 * g + 114 * b) / 1000))
}

brighten_if_dark() {
  local hex="$1"
  local min_luma="$2"
  local r g b luma

  r=$((16#${hex:1:2}))
  g=$((16#${hex:3:2}))
  b=$((16#${hex:5:2}))
  luma=$(hex_luma "$hex")

  while [ "$luma" -lt "$min_luma" ]; do
    r=$((r + 18))
    g=$((g + 18))
    b=$((b + 18))
    if [ "$r" -gt 255 ]; then r=255; fi
    if [ "$g" -gt 255 ]; then g=255; fi
    if [ "$b" -gt 255 ]; then b=255; fi
    hex=$(printf '#%02X%02X%02X' "$r" "$g" "$b")
    luma=$(hex_luma "$hex")
    if [ "$r" -eq 255 ] && [ "$g" -eq 255 ] && [ "$b" -eq 255 ]; then
      break
    fi
  done

  echo "$hex"
}

wallpaper=$(get_wallpaper_path)

if [ -z "$wallpaper" ] || [ ! -f "$wallpaper" ]; then
  echo "Wallpaper not found in hyprpaper config, using fallback palette."
  primary="$fallback_primary"
  secondary="$fallback_secondary"
  success="$fallback_success"
  warning="$fallback_warning"
  danger="$fallback_danger"
else
  mapfile -t colors < <(extract_colors "$wallpaper")
  primary="${colors[0]:-$fallback_primary}"
  secondary="${colors[1]:-$fallback_secondary}"
  success="${colors[2]:-$fallback_success}"
  warning="${colors[3]:-$fallback_warning}"
  danger="${colors[4]:-$fallback_danger}"
fi

primary=$(brighten_if_dark "$primary" 125)
secondary=$(brighten_if_dark "$secondary" 130)
success=$(brighten_if_dark "$success" 120)
warning=$(brighten_if_dark "$warning" 140)
danger=$(brighten_if_dark "$danger" 135)

cat > "$WAYBAR_PALETTE" <<EOF
@define-color wb-fg #E8EDF2;
@define-color wb-muted #94A1B3;
@define-color wb-accent $primary;
@define-color wb-accent-2 $secondary;
@define-color wb-success $success;
@define-color wb-warning $warning;
@define-color wb-danger $danger;
EOF

cat > "$SWAYNC_PALETTE" <<EOF
:root {
  --pal-fg: #E8EDF2;
  --pal-muted: #94A1B3;
  --pal-accent: $primary;
  --pal-accent-2: $secondary;
  --pal-success: $success;
  --pal-warning: $warning;
  --pal-danger: $danger;
}
EOF

cat > "$EWW_PALETTE" <<EOF
\$pal-fg: #E8EDF2;
\$pal-muted: #94A1B3;
\$pal-accent: $primary;
\$pal-accent-2: $secondary;
\$pal-success: $success;
\$pal-warning: $warning;
\$pal-danger: $danger;
EOF

if [ "${1:-}" = "--reload" ]; then
  pkill -SIGUSR2 waybar 2>/dev/null || true
  swaync-client --reload-config 2>/dev/null || true
  eww reload 2>/dev/null || true
fi

echo "Wallpaper palette synced: $primary $secondary $success"
