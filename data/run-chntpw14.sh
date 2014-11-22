#!/bin/bash

set -e

if [ "$1" == "chroot" ]; then
	mkdir -p /tmp/chntpw/{mnt,initrd}
	mount chntpw14.iso /tmp/chntpw/mnt -o ro,loop
	pushd /tmp/chntpw/initrd
	zcat ../mnt/initrd.cgz | cpio -i
	umount /tmp/chntpw/mnt
	mkdir tmp disk
	mount -t proc none proc
	mount -t sysfs none sys
	chroot . /bin/busybox --install -s
	chroot . /sbin/mdev -s
	cat scripts/banner1
	chroot . /bin/sh /scripts/main.sh
	umount sys
	umount proc
	popd
	rm -R /tmp/chntpw
elif [ "$1" == "nochroot" ]; then
	mkdir -p /tmp/chntpw/{mnt,initrd,bin}
	mount chntpw14.iso /tmp/chntpw/mnt -o ro,loop
	pushd /tmp/chntpw/initrd
	zcat ../mnt/initrd.cgz | cpio -i
	umount /tmp/chntpw/mnt
	mkdir /disk
	ln -s /bin/cp /tmp/chntpw/bin/cpnt
	ln -s /tmp/chntpw/initrd/scripts /scripts
	export PATH=$PATH:/tmp/chntpw/bin
	cat scripts/banner1
	bash scripts/main.sh
	popd
	rm /scripts
	rmdir /disk
	rm -R /tmp/chntpw
else
	echo "Usage: ./run-chntp14.sh [no]chroot."
fi
