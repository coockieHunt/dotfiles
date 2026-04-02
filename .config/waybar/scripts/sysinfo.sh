#!/usr/bin/env bash
cpu_line1=($(awk '/^cpu /{print $2,$3,$4,$5,$6,$7,$8}' /proc/stat))
sleep 0.2
cpu_line2=($(awk '/^cpu /{print $2,$3,$4,$5,$6,$7,$8}' /proc/stat))

total1=0; total2=0
for v in "${cpu_line1[@]}"; do ((total1+=v)); done
for v in "${cpu_line2[@]}"; do ((total2+=v)); done

idle1=${cpu_line1[3]}
idle2=${cpu_line2[3]}
delta_total=$((total2 - total1))
delta_idle=$((idle2 - idle1))

if ((delta_total > 0)); then
    cpu=$(( 100 * (delta_total - delta_idle) / delta_total ))
else
    cpu=0
fi

mem=$(awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf "%d", (t-a)/t*100}' /proc/meminfo)

FREQ_TOTAL=0
CPU_COUNT=$(nproc)
FREQ_FILES=(/sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq)
if [ -e "${FREQ_FILES[0]}" ]; then
    for f in "${FREQ_FILES[@]}"; do
        FREQ_TOTAL=$((FREQ_TOTAL + $(cat "$f")))
    done
    FREQ_GHZ=$(echo "scale=1; $FREQ_TOTAL/1000/1000/$CPU_COUNT" | bc)
    FREQ_DISPLAY="${FREQ_GHZ}GHz"
else
    FREQ_DISPLAY="N/A"
fi

TEMP_CPU=$(sensors 2>/dev/null | grep -E "Tdie|Tctl" | awk 'NR==1{print $2}' | tr -d '+')
[ -z "$TEMP_CPU" ] && TEMP_CPU="N/A"

PROFILE=$(tlp-stat -s 2>/dev/null | awk -F'= ' '/Power profile/{print $2; exit}' | cut -d'/' -f1 | tr -d '[:space:]')
[ -z "$PROFILE" ] && PROFILE="unknown"

case "$PROFILE" in
    performance) MODE_ICON="󰘇"; MODE_COLOR="#ff9f7f" ;;
    balanced)    MODE_ICON="󰾅"; MODE_COLOR="#7fffd4" ;;
    *)           MODE_ICON="󰘈"; MODE_COLOR="#94A1B3" ;;
esac

bar_icon() {
  local p=$1
  if   (( p >= 88 )); then printf '█'
  elif (( p >= 75 )); then printf '▇'
  elif (( p >= 62 )); then printf '▆'
  elif (( p >= 50 )); then printf '▅'
  elif (( p >= 37 )); then printf '▄'
  elif (( p >= 25 )); then printf '▃'
  elif (( p >= 12 )); then printf '▂'
  else printf '▁'; fi
}
bar_color() {
  local p=$1
  if [[ "$PROFILE" == "performance" ]]; then
    if   (( p >= 70 )); then echo "#ff8f8f"
    elif (( p >= 40 )); then echo "#ffb347"
    else echo "#ffd479"; fi
  else
    if   (( p >= 70 )); then echo "#ff8f8f"
    elif (( p >= 40 )); then echo "#ffd479"
    else echo "#7fffd4"; fi
  fi
}

cpu_bar=$(bar_icon $cpu); cpu_col=$(bar_color $cpu)
mem_bar=$(bar_icon $mem); mem_col=$(bar_color $mem)

text="<span foreground='#ffb3a7'>󰘰</span> <span foreground='${cpu_col}'>${cpu_bar}${cpu_bar}</span>  <span foreground='#88c4ff'>󰍛</span> <span foreground='${mem_col}'>${mem_bar}${mem_bar}</span>"
tooltip="Profil: ${PROFILE}\nCPU: ${cpu}%  ${FREQ_DISPLAY}  ${TEMP_CPU}\nRAM: ${mem}%"
printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text" "$tooltip" "$PROFILE"
