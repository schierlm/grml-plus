#!/bin/bash
set -e
if [ ! -f /tmp/grml-plus/devicename ]; then
	echo "run make-grml-plus first!" >&2
	exit 1
fi
. /tmp/grml-plus/devicename
echo "Mounting $DEVICE to /tmp/grml-plus/mnt."
mkdir -p /tmp/grml-plus/mnt 
umount /tmp/grml-plus/mnt 2>/dev/null || true
mount $DEVICE /tmp/grml-plus/mnt
cd `dirname $0`/data
DATADIR=`pwd`
cd /tmp/grml-plus/mnt

extra_cleanup() {
	echo "Cleaning up."
	cd $DATADIR/..
	umount /tmp/grml-plus/mnt
	echo "Done. Enjoy your new grml-plus USB drive or add more extras!"
}
