#!/bin/bash

# Increase or decrease the brightness by 10%.
# Meant to be called via ACPI events on a ThinkPad.

MAX_BRIGHTNESS=$(cat /sys/class/backlight/intel_backlight/max_brightness)
CURRENT_BRIGHTNESS=$(cat /sys/class/backlight/intel_backlight/brightness)
INC=$((${MAX_BRIGHTNESS}/10))

function print_help() {
	echo "${0} <up|down>"
	echo "Increase or decrease backlight brightness"
	exit 1
}

case "${1}" in
	"up")
		NEW_BRIGHTNESS=$((${CURRENT_BRIGHTNESS}+${INC}))
		if [ ${NEW_BRIGHTNESS} -gt ${MAX_BRIGHTNESS} ]; then
			NEW_BRIGHTNESS=${MAX_BRIGHTNESS}
		fi
		;;
	"down")
		NEW_BRIGHTNESS=$((${CURRENT_BRIGHTNESS}-${INC}))
		if [ ${NEW_BRIGHTNESS} -lt 0 ]; then
			NEW_BRIGHTNESS=0
		fi
		;;
	*)
		print_help
		;;
esac

echo ${NEW_BRIGHTNESS} > /sys/class/backlight/intel_backlight/brightness
CURRENT_BRIGHTNESS=$(cat /sys/class/backlight/intel_backlight/brightness)
logger -s "LCD backlight brightness is now ${CURRENT_BRIGHTNESS}"
