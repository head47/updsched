#!/bin/bash

username="$(id -nu 1000)"
if ! [[ -f "/usr/bin/pacman" ]]; then
	sudo -u "$username" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -u normal "Update scheduler" "Aborting: pacman not found"
	exit 5
fi

if ! ping -c1 1.1.1.1; then
	sudo -u "$username" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -u normal "Update scheduler" "Aborting: network problems detected"
	exit 69
fi

pacman -Sy
err="$?"
if [ "$err" != '0' ]; then
	sudo -u "$username" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -u critical "Update scheduler" "Aborting: unknown error"
        exit 1
fi

updatecount=$(pacman -Qu | wc -l)
if [ "$updatecount" = '0' ]; then
	sudo -u "$username" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -u low "Update scheduler" "Database updated; no updates available"
	exit 0
fi

if ! [[ -f "/usr/bin/xterm" ]]; then
	ACTION=$(sudo -u "$username" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus dunstify --action="default,Yes" --action="no,No" -u normal "Update scheduler" $"Database updated; $updatecount updates available.\n\nDo you want to update?")
else
	ACTION=$(sudo -u "$username" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus dunstify --action="default,Download only" --action="no,No" --action "install,Download and install" -u normal "Update scheduler" $"Database updated; $updatecount updates available.\n\nDo you want to update?")
fi

case "$ACTION" in
"default")
	sudo -u "$username" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -u low "Update scheduler" "Downloading updates..."
	pacman -Syuw --noconfirm
	err="$?"
	if [ "$err" != '0' ]; then
		sudo -u "$username" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -u critical "Update scheduler" "Aborting: unknown error"
		exit 1
	fi
	sudo -u "$username" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -u normal "Update scheduler" "$updatecount updates downloaded, awaiting manual installation"
	;;
"no")
	sudo -u "$username" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -u low "Update scheduler" "Aborting: user decision"
	exit 0
	;;
"install")
	DISPLAY=:0 XAUTHORITY="$(eval echo "~$username")/.Xauthority" xterm -e "pacman -Syu; read -rsp $'Press Enter to continue...\n'"
	;;
"2")
	sudo -u "$username" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -u low "Update scheduler" "Aborting: user decision"
	exit 0
	;;
esac
