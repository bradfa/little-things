#!/bin/bash -e

# Do a restic backup to the directory/device specified.

if [ $# -ne 1 ]; then
	echo
	echo "Usage: ${0} <destination>"
	echo
	exit 1
fi

if [ ! -d ${1} ]; then
	echo
	echo "Usage: ${0} <destination>"
	echo "<destination> must be a directory"
	echo
	exit 1
fi

restic backup --repo=${1}/restic-repo/ \
	--exclude-caches --one-file-system --password-file=/home/andrew/.restic.passwd \
	--exclude-file=/home/andrew/.restic.excludes --verbose \
	/etc/ /home/ /opt/ /srv/ /var/log/ /var/www/ /mnt/mx500/
