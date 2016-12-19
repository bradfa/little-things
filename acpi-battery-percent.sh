#!/bin/bash

# Report total battery percent remaining, even when more than one battery is
# present so that tools like xbattbar can present the total system battery level
# more easily.

set -e
#set -x

BATTERIES=`acpi -b`
BATTERY_LEVELS=`echo ${BATTERIES} | sed -e "s/\s/\n/g" | \
		grep "\%" | sed -e "s/,//g" -e "s/\%//g"`
NUM_BATTERIES=`echo ${BATTERY_LEVELS} | wc -w`
TOTAL=0
for BATTERY in ${BATTERY_LEVELS}; do
	TOTAL=`echo "${TOTAL} + ${BATTERY}" | bc`
done

TOTAL=`echo ${TOTAL} / ${NUM_BATTERIES} | bc`
echo "battery=${TOTAL}"

ADAPTER=`acpi -a | sed -e "s/.*: \(on\|off\)-line/\1/"`
echo "ac_line=${ADAPTER}"
