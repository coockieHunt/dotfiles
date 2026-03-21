#!/usr/bin/env bash
# Read CPU usage from /proc/stat using two samples for better accuracy.
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

# Read RAM usage from /proc/meminfo.
mem=$(awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf "%d", (t-a)/t*100}' /proc/meminfo)

echo "<span size='140%'></span> <span size='112%'>${cpu}%</span>  <span size='140%'></span> <span size='112%'>${mem}%</span>"
