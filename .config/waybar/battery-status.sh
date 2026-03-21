#!/usr/bin/env bash

set -u

BAT=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1)
if [[ -z "${BAT:-}" ]]; then
  echo '{"text":"BAT N/A","class":"missing","tooltip":"Batterie introuvable"}'
  exit 0
fi

read_num() {
  local f="$1"
  [[ -r "$f" ]] && cat "$f" || echo ""
}

capacity=$(read_num "$BAT/capacity")
status=$(read_num "$BAT/status")
power_now=$(read_num "$BAT/power_now")
energy_now=$(read_num "$BAT/energy_now")
charge_now=$(read_num "$BAT/charge_now")
start_threshold=$(read_num "$BAT/charge_control_start_threshold")
end_threshold=$(read_num "$BAT/charge_control_end_threshold")

if [[ -z "$power_now" && -r "$BAT/current_now" && -r "$BAT/voltage_now" ]]; then
  current_now=$(read_num "$BAT/current_now")
  voltage_now=$(read_num "$BAT/voltage_now")
  if [[ -n "$current_now" && -n "$voltage_now" ]]; then
    power_now=$(( current_now * voltage_now / 1000000 ))
  fi
fi

watts=""
if [[ -n "$power_now" && "$power_now" -gt 0 ]]; then
  watts=$(awk "BEGIN { printf \"%.1f\", $power_now/1000000 }")
fi

icon=""
if [[ -n "$capacity" ]]; then
  if (( capacity <= 10 )); then icon="";
  elif (( capacity <= 25 )); then icon="";
  elif (( capacity <= 50 )); then icon="";
  elif (( capacity <= 75 )); then icon="";
  else icon=""; fi
fi

class="discharging"
label="Decharge"
case "$status" in
  Charging)
    class="charging"
    label="Charge"
    icon=""
    ;;
  Full)
    class="full"
    label="Pleine"
    icon=""
    ;;
  Not\ charging)
    class="plugged"
    label="Branchee"
    ;;
  Discharging|*)
    class="discharging"
    label="Decharge"
    ;;
esac

mode_label="NA"
mode_class="nomode"
mode_icon=""
if [[ -n "$start_threshold" && -n "$end_threshold" ]]; then
  if (( end_threshold >= 95 )); then
    mode_label="MOB"
    mode_class="mobile"
    mode_icon=""
  else
    mode_label="ECO"
    mode_class="eco"
    mode_icon=""
  fi
fi

if [[ "$class" == "discharging" && -n "$capacity" ]]; then
  if (( capacity <= 15 )); then
    class="critical"
  elif (( capacity <= 30 )); then
    class="warning"
  fi
fi

text="<span size='130%'>$mode_icon</span> ${capacity:-?}% $label"
if [[ -n "$watts" ]]; then
  text="$text ${watts}W"
fi

class_json=$(printf '["%s","%s","charge-%s"]' "$class" "$mode_class" "$mode_class")

tooltip="Etat: $label\nMode charge: $mode_label"
if [[ -n "$capacity" ]]; then
  tooltip="$tooltip\nNiveau: ${capacity}%"
fi
if [[ -n "$watts" ]]; then
  tooltip="$tooltip\nPuissance: ${watts} W"
fi
if [[ -n "$start_threshold" && -n "$end_threshold" ]]; then
  tooltip="$tooltip\nSeuils: ${start_threshold}-${end_threshold}%"
fi

# Escape potential quotes/newlines safely for JSON output.
text_escaped=${text//\"/\\\"}
tooltip_escaped=${tooltip//$'\n'/\\n}
tooltip_escaped=${tooltip_escaped//\"/\\\"}

printf '{"text":"%s","class":%s,"tooltip":"%s"}\n' "$text_escaped" "$class_json" "$tooltip_escaped"
