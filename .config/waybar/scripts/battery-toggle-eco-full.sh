#!/usr/bin/env bash

BAT=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1)
if [[ -z "$BAT" ]]; then
  notify-send "Batterie non trouvée" "Impossible de changer le mode de charge."
  exit 1
fi

ECO_START=40
ECO_END=80
FULL_START=95
FULL_END=100

end_threshold=$(cat "$BAT/charge_control_end_threshold" 2>/dev/null)

if [[ "$end_threshold" -ge 95 ]]; then
  sudo tlp setcharge $ECO_START $ECO_END
  notify-send "Mode batterie" "Mode ECO activé ($ECO_START-$ECO_END%)"
else
  sudo tlp setcharge $FULL_START $FULL_END
  notify-send "Mode batterie" "Mode FULL CHARGE activé ($FULL_START-$FULL_END%)"
fi
