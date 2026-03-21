#!/usr/bin/env bash

set -u

mode="${1:-}"

trim_text() {
  local max="$1"
  local text
  text=$(cat)
  if [ "${#text}" -gt "$max" ]; then
    printf "%s..." "${text:0:$((max - 3))}"
  else
    printf "%s" "$text"
  fi
}

cpu_usage() {
  local user nice system idle iowait irq softirq steal guest guest_nice
  local user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2 guest2 guest_nice2
  local idle_a total_a idle_b total_b diff_idle diff_total usage

  read -r _ user nice system idle iowait irq softirq steal guest guest_nice < /proc/stat
  idle_a=$((idle + iowait))
  total_a=$((user + nice + system + idle + iowait + irq + softirq + steal))

  sleep 0.35

  read -r _ user2 nice2 system2 idle2 iowait2 irq2 softirq2 steal2 guest2 guest_nice2 < /proc/stat
  idle_b=$((idle2 + iowait2))
  total_b=$((user2 + nice2 + system2 + idle2 + iowait2 + irq2 + softirq2 + steal2))

  diff_idle=$((idle_b - idle_a))
  diff_total=$((total_b - total_a))

  if [ "$diff_total" -le 0 ]; then
    echo "0%"
    return
  fi

  usage=$(( (100 * (diff_total - diff_idle)) / diff_total ))
  echo "${usage}%"
}

ram_usage() {
  free | awk '/Mem:/ { if ($2 > 0) printf "%.0f%%", ($3/$2)*100; else print "0%" }'
}

proc_count() {
  ps -e --no-headers 2>/dev/null | wc -l | tr -d ' '
}

temp_value() {
  if [ -r /sys/class/thermal/thermal_zone0/temp ]; then
    awk '{printf "%dC", $1/1000}' /sys/class/thermal/thermal_zone0/temp
    return
  fi

  if command -v sensors >/dev/null 2>&1; then
    sensors 2>/dev/null | awk 'match($0, /\+([0-9]+(\.[0-9]+)?)°C/, a) {printf "%dC", a[1]; found=1; exit} END {if (!found) print "N/A"}'
    return
  fi

  echo "N/A"
}

weather_from_ip() {
  curl -fsS --max-time 5 "https://wttr.in/?format=%c+%t" 2>/dev/null || echo "N/A"
}

os_name() {
  if [ -r /etc/os-release ]; then
    awk -F= '/^PRETTY_NAME=/ {gsub(/"/, "", $2); print $2; exit}' /etc/os-release | trim_text 24
    return
  fi
  uname -s | trim_text 24
}

kernel_name() {
  uname -r
}

uptime_short() {
  awk '{
    total = int($1)
    days = int(total / 86400)
    hours = int((total % 86400) / 3600)
    mins = int((total % 3600) / 60)
    if (days > 0) {
      printf "%dd %dh", days, hours
    } else {
      printf "%dh %dm", hours, mins
    }
  }' /proc/uptime
}

shell_name() {
  basename "${SHELL:-unknown}"
}

host_name() {
  hostnamectl --static 2>/dev/null || hostname
}

cpu_model() {
  awk -F: '/model name/ {gsub(/^ +/, "", $2); print $2; exit}' /proc/cpuinfo 2>/dev/null | trim_text 42
}

ram_total() {
  awk '/MemTotal/ {printf "%.1f GiB", $2/1024/1024}' /proc/meminfo 2>/dev/null
}

gpu_model() {
  if command -v lspci >/dev/null 2>&1; then
    lspci | awk -F': ' '/VGA compatible controller|3D controller|Display controller/ {print $2; exit}' | trim_text 42
    return
  fi
  echo "N/A"
}

disk_root() {
  df -h / 2>/dev/null | awk 'NR==2 {print $2 " total"}'
}

case "$mode" in
  cpu)
    cpu_usage
    ;;
  ram)
    ram_usage
    ;;
  proc)
    proc_count
    ;;
  temp)
    temp_value
    ;;
  weather)
    weather_from_ip
    ;;
  os)
    os_name
    ;;
  kernel)
    kernel_name
    ;;
  uptime)
    uptime_short
    ;;
  shell)
    shell_name
    ;;
  host)
    host_name
    ;;
  cpu_model)
    cpu_model
    ;;
  ram_total)
    ram_total
    ;;
  gpu)
    gpu_model
    ;;
  disk)
    disk_root
    ;;
  *)
    echo "N/A"
    ;;
esac
