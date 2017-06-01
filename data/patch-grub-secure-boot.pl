#!/usr/bin/perl -w

# Debian's grub version has been patched (no-insmod-on-sb.patch) to
# disallow loading modules when Secure Boot is enabled. This is
# presumably used in scenarios where the whole chain from GRUB down to
# the kernel image is signed - as GRUB modules cannot be signed, the
# easiest way to disable this bypass is to disable GRUB module loading
# altogether and instead use a monolithic GRUB image. As we don't want
# to do this and are too lazy to compile our own GRUB, just patch the
# variable names that are used for the Secure Boot check.

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

seek(DEV, 0xa483, 0);
patch(1, "SecureBoot", "XecureBoot");
seek(DEV, 0xa48e, 0);
patch(2, "SetupMode", "XetupMode");
close(DEV);

print "GRUB patched for Secure Boot successfully.\n";
