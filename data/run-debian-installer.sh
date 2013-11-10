#!/bin/bash

set -e

if [ ! -f "$1" ]; then
	echo "Usage: ./run-debian-installer debian-isofile.iso"
	exit -1
fi

mkdir -p /tmp/debinst/cdrom
mount "$1" /tmp/debinst/cdrom -o ro,loop
pushd /tmp/debinst
if [ -f cdrom/initrd.gz ]; then
	# mini iso, does not need cdrom
	zcat cdrom/initrd.gz | cpio -i
	umount cdrom
	rmdir cdrom
else
	zcat cdrom/install.*/initrd.gz | cpio -i
fi
chroot . /bin/sh -c "export LIVE_INSTALLER_MODE=1; /init; /sbin/debian-installer-startup; /sbin/debian-installer"
umount cdrom || true
popd
rm -R --one-file-system /tmp/debinst

