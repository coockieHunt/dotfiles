#!/usr/bin/env bash

PROFILE=$(tlp-stat -s 2>/dev/null | awk -F'= ' '/Power profile/{print $2; exit}' | cut -d'/' -f1 | tr -d '[:space:]')
[ -z "$PROFILE" ] && PROFILE="unknown"

run_privileged() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    elif command -v pkexec >/dev/null 2>&1; then
        if command -v timeout >/dev/null 2>&1; then
            timeout 12 pkexec --disable-internal-agent "$@"
        else
            pkexec --disable-internal-agent "$@"
        fi
    elif sudo -n true 2>/dev/null; then
        sudo -n "$@"
    else
        return 1
    fi
}

if [ "$1" == "click-left" ] || [ "$1" == "click-cpu" ]; then
    if [[ "$PROFILE" == "performance" ]]; then
        TARGET="balanced"
    else
        TARGET="performance"
    fi

    if run_privileged /usr/bin/tlp "$TARGET" ac; then
        pkill -SIGUSR2 waybar 2>/dev/null || pkill -RTMIN+8 waybar 2>/dev/null || true
        exit 0
    elif command -v powerprofilesctl >/dev/null 2>&1 && powerprofilesctl set "$TARGET" >/dev/null 2>&1; then
        command -v notify-send >/dev/null 2>&1 && notify-send "CPU Mode" "Switched via powerprofilesctl: $TARGET"
        pkill -SIGUSR2 waybar 2>/dev/null || pkill -RTMIN+8 waybar 2>/dev/null || true
        exit 0
    else
        command -v notify-send >/dev/null 2>&1 && notify-send "CPU Mode" "Authentication denied: root privileges required."
        exit 1
    fi
fi

if [ "$1" == "click-right" ] || [ "$1" == "click-charge" ]; then
    START_FILE="/sys/class/power_supply/BAT0/charge_control_start_threshold"
    END_FILE="/sys/class/power_supply/BAT0/charge_control_end_threshold"

    if [ ! -r "$START_FILE" ] || [ ! -r "$END_FILE" ]; then
        command -v notify-send >/dev/null 2>&1 && notify-send "Battery" "Thresholds not found (BAT0)."
        exit 1
    fi

    CURRENT_START=$(cat "$START_FILE")
    CURRENT_END=$(cat "$END_FILE")

    if [ "$CURRENT_START" -eq 20 ] && [ "$CURRENT_END" -eq 80 ]; then
        NEW_START=0
        NEW_END=100
        LABEL="Mobile 0-100"
    else
        NEW_START=20
        NEW_END=80
        LABEL="Health 20-80"
    fi

    if run_privileged tlp setcharge "$NEW_START" "$NEW_END" BAT0; then
        command -v notify-send >/dev/null 2>&1 && notify-send "Battery" "Mode: $LABEL"
        pkill -SIGUSR2 waybar 2>/dev/null || pkill -RTMIN+8 waybar 2>/dev/null || true
        exit 0
    else
        command -v notify-send >/dev/null 2>&1 && notify-send "Battery" "Authentication denied: root privileges required."
        exit 1
    fi
fi

FREQ_TOTAL=0
CPU_COUNT=$(nproc)
FREQ_FILES=(/sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq)
if [ -e "${FREQ_FILES[0]}" ]; then
    for cpu in "${FREQ_FILES[@]}"; do
        FREQ_TOTAL=$((FREQ_TOTAL + $(cat "$cpu")))
    done
    FREQ_GHZ=$(echo "scale=1; $FREQ_TOTAL/1000/1000/$CPU_COUNT" | bc)
else
    FREQ_GHZ="N/A"
fi

TEMP_CPU=$(sensors 2>/dev/null | grep -E "Tdie|Tctl" | awk 'NR==1{print $2}' | tr -d '+')
[ -z "$TEMP_CPU" ] && TEMP_CPU="N/A"

if [ "$FREQ_GHZ" = "N/A" ]; then
    FREQ_DISPLAY="N/A"
else
    FREQ_DISPLAY="${FREQ_GHZ}GHz"
fi

case "$PROFILE" in
    performance)
        MODE_ICON=""
        CLASS="performance"
        ;;
    balanced)
        MODE_ICON=""
        CLASS="balanced"
        ;;
    *)
        MODE_ICON=""
        CLASS="unknown"
        ;;
esac

TEXT="<span size='140%'>${MODE_ICON}</span> ${FREQ_DISPLAY} ${TEMP_CPU}"
printf '{"text":"%s","class":"%s"}\n' "$TEXT" "$CLASS"