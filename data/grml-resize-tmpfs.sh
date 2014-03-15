#!/bin/bash

set -e

if [ -z "$1" ]; then
	echo "Usage: grml-resize-tmpfs [size]"
	echo "Example: grml-resize-tmpfs 512M"
	exit 1
fi

while [ $(grep "^tmpfs /lib/live/mount/overlay" /proc/mounts | wc -l) -gt 1 ]; do
	umount /lib/live/mount/overlay
done

mount -o remount,size=$1 /lib/live/mount/overlay
mount -o size=$1 -t tmpfs tmpfs /lib/live/mount/overlay
