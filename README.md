# NO LONGER MAINTAINED

This repo is no longer maintained. Users are advised to switch to [usb-modboot](https://github.com/schierlm/usb-modboot/) instead.
It provides all the features in grml-plus, and more.

To make the migration easier, a
[special module](https://github.com/schierlm/usb-modboot/releases/download/v0.9/module.grml-plus-legacy.zip) is provided which can be used
to integrate existing grml-plus menus into the usb-modboot menu, as well as boot usb-modboot via grml-plus' USB-Loader media.

grml-plus
=========

Script to add grml (from grml.org) and more stuff to a USB key


Design principles
-----------------

- The USB key uses a PC (MBR) partition table and a single FAT32 formatted partition, 
  to make it usable by as many devices as possible. It is also possible to move all 
  files to a different disk and back later, and the USB device can still be booted (GRUB2
  is installed to the MBR to make this possible, and the boot block is slightly patched
  to avoid it being detected as unpartitioned FAT device by some Windows CE systems).
  
- All files are stored inside `grml-plus` directory, as far as possible 
  (GRUB2 is installed on MBR and efi boot loader has to be in /efi, for example). The installation
  script does not touch any other places; your previous data on the USB key remains there.

- Modular design; only add to the USB key what you want and do not bloat it with things you do
  not need (adding one GRML iso and less than 10MB of GRUB and scripts is mandatory, though).

- ISO files (GRML and other distributions) are stored as is on the USB key, to make it easy
  to use them on (virtual) machines that do not support USB booting. GRUB2's loopback feature is
  used to mount and boot them.

- Everything that can be downloaded for free can be added - it does not have to be open source or
  even freely redistributable. That's why tools like Kon-Boot and PLOP are available here, which
  cannot be redistributed with grml itself due to licensing issues.

Installation
------------

grml-plus is designed to be run from within `grml 2017.05`. I use VirtualBox with USB support, but
other virtualization software (or even running it on bare metal) should work as well. Theoretically,
it should also be possible to run it on any other Linux distribution, but that use case is not
supported by me. You should run is as `root` though, as it does quite some mounting and unmounting of
downloaded ISO files.

First, make sure that your USB key is indeed formatted as FAT32. The filesystem type of the primary
partition should be 0x0B for maximum compatibility, and the partition should be marked bootable
(While GRUB2 happily boots even if the partition is not bootable, some - especially newer - BIOSes
hide the USB key in the boot device menu if it is formatted with a PC (MBR) partition table but there
are no bootable partitions on it).

Create a directory called `grml-plus` on it and drop any grml 2017.05 ISO file in it (I use grml96-full,
but any other one should work too). In case you like to add some Ubuntu live ISOs, drop them into that
directory as well.

Find the partition name of your USB device (`cat /proc/partitions` may help), and run the following
(assuming /dev/sda1)

    root@grml ~ # git clone git://github.com/schierlm/grml-plus
    root@grml ~ # cd grml-plus
    root@grml ~/grml-plus (git)-[master] # ./make-grml-plus /dev/sda1
    root@grml ~/grml-plus (git)-[master] # ./add-ubuntu
    root@grml ~/grml-plus (git)-[master] # ./add-chntpw

The last two commands are optional, if you want to add ubuntu and/or chntpw ISO (the latter is downloaded
automatically) to the menu.

Expect more `add-` commands to appear over time, or if you are missing any (and the ISO in question can
indeed be loopback booted), feel free to add them and create a pull request.


Enjoy!
