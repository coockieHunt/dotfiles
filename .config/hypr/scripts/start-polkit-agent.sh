#!/bin/sh

# Start one graphical polkit agent for the user session if none is running.
if pgrep -fa 'lxqt-policykit-agent|polkit-kde-authentication-agent-1|polkit-gnome-authentication-agent-1|polkit-mate-authentication-agent-1|mate-polkit' >/dev/null; then
    exit 0
fi

if command -v lxqt-policykit-agent >/dev/null 2>&1; then
    nohup lxqt-policykit-agent >/tmp/polkit-agent.log 2>&1 &
    exit 0
fi

if [ -x /usr/lib/polkit-kde-authentication-agent-1 ]; then
    nohup /usr/lib/polkit-kde-authentication-agent-1 >/tmp/polkit-agent.log 2>&1 &
    exit 0
fi

if [ -x /usr/libexec/polkit-kde-authentication-agent-1 ]; then
    nohup /usr/libexec/polkit-kde-authentication-agent-1 >/tmp/polkit-agent.log 2>&1 &
    exit 0
fi

if [ -x /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ]; then
    nohup /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 >/tmp/polkit-agent.log 2>&1 &
    exit 0
fi

if [ -x /usr/lib/mate-polkit/polkit-mate-authentication-agent-1 ]; then
    nohup /usr/lib/mate-polkit/polkit-mate-authentication-agent-1 >/tmp/polkit-agent.log 2>&1 &
    exit 0
fi

if command -v mate-polkit >/dev/null 2>&1; then
    nohup mate-polkit >/tmp/polkit-agent.log 2>&1 &
    exit 0
fi

exit 1
