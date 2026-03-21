#!/bin/bash

# 1. Lance le dashboard Eww
eww open dashboard

# 2. Écoute les événements de Hyprland via son socket
# 'socat' attend l'événement "openwindow"
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do
    if echo "$line" | grep -q "openwindow"; then
        # On vérifie si la fenêtre ouverte n'est pas le dashboard lui-même
        # (Sinon il se fermerait instantanément)
        eww close dashboard
        exit 0
    fi
done
