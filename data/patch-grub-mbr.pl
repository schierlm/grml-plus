#!/usr/bin/perl -w

# GRUB 1.99 by default starts its MBR with EB 63 90, which is used by
# some crappy embedded devices to mis-detect it as a FAT32 boot record,
# thereby assuming that the device is not partitioned, but a FAT32
# filesystem is stored directly on the device. This assumption makes 
# it impossible to use this USB drive with these devices. Therefore, we
# patch the MBR to start with the (as far as x86 instructions are
# concerned) equivalent code 90 EB 62.
#
# While we are at it, we will also patch the loading message to read
# GRUB USB MBR
# to make it easier to distinguish it from another GRUB installed on the
# machine we want to use our device on.

open DEV, "+<", $ARGV[0] or die $!;
binmode DEV;

sub patch {
	my ($index, $before, $after) = @_;
	my $actual;
	read(DEV, $actual, length $before);
	if ($before eq $actual) {
		print "Applying patch $index...\n";
		seek(DEV, - length $before, 1);
		print DEV $after;
	} elsif ($after eq $actual) {
		print "Patch $index already applied.\n";
	} else {
		die("Patch $index failed, unexpected bytes detected.");
	}
}

patch(1, "\xEB\x63\x90", "\x90\xEB\x62");
seek(DEV, 816, 1);
patch(2, "loading", "USB MBR");
close(DEV);

print "MBR patched successfully\n";
