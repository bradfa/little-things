#!/bin/bash
# A one step process to turn a dts file into a dtb from within linux's dtb dir

set -e
if [ $1 ]; then
	OUTPUT=$(echo ${1} | sed -e "s/dts/dtb/")
	cpp -nostdinc -I . -I include -undef -D__DTS__ -x assembler-with-cpp $1 | dtc -I dts -i . -O dtb -o ${OUTPUT}
else
	echo "Creates a .dtb from a .dts using the cpp prior to dtc tool"
	echo "Usage: ${0} dtsfile.dts"
fi
