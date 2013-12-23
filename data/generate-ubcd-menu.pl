#!/usr/bin/perl -w

$isodir=$ARGV[0];
$confdir=$ARGV[1];
($grubconfdir=$confdir) =~ s#.*grml-plus/#\$images/#;

open MAIN, "<", "$isodir/ubcd/menus/syslinux/main.cfg" or die $!;
open MENU, ">", "$confdir/ubcd.cfg" or die $!;
open DESC, ">", "$confdir/main.txt" or die $!;

print MENU <<HEADER;
menuentry "[description]" {
	set pager=1
	cat $grubconfdir/main.txt
	set tmp=\$color_normal
	set color_normal=\$color_highlight
	echo -n --END--
	set color_normal=\$tmp
	read tmp
	unset tmp
	unset pager
}

HEADER

while(<MAIN>) {
	last if /^LABEL -\r?\n$/;
}

while(<MAIN>) {
	s/ *\r?\n$//;
	if (/^LABEL -$/ or /^$/) {
		# ignore
	} elsif (/^MENU LABEL (.*)$/) {
		$label=$1;
	} elsif (/^TEXT HELP$/) {
		print DESC "$label:\n\n";
		while(<MAIN>) {
			s/\r?\n$//;
			last if /^ENDTEXT$/;
			print DESC $_.$/;
		}
		print DESC $/.$/;
	} elsif (/^CONFIG \/ubcd\/custom\/custom.cfg$/) {
		last;
	} elsif (/^CONFIG (\/pmagic\/[^ ]+)( [^ ]+)?$/) {
		print MENU "submenu \"$label\" {\n";
		print MENU <<ENTRIES;
	menuentry "Run from RAM" {
		linux (ubcd)/pmagic/bzImage edd=on vga=normal vmalloc=385MiB iso_filename=\$iso_path
		initrd (ubcd)/pmagic/initrd.img
	}

	menuentry "Run from Media" {
		linux (ubcd)/pmagic/bzImage edd=on vga=normal boot=live eject=no vmalloc=384MiB iso_filename=\$iso_path
		initrd (ubcd)/pmagic/initrd.img
	}
ENTRIES
		print MENU "}\n";
	} elsif (/^CONFIG \/([^ ]+)$/) {
		$cfgfile=$1;
		($base=$cfgfile) =~ s#.*/(.*)\.cfg#$1#;

		open SUB, "<", "$isodir/$cfgfile" or die $!;
		open SUBDESC, ">", "$confdir/$base.txt" or die $!;

		print MENU <<HEADER;
submenu "$label" {
	menuentry "[description]" {
       		set pager=1
       		cat $grubconfdir/$base.txt
        	set tmp=\$color_normal
        	set color_normal=\$color_highlight
        	echo -n --END--
        	set color_normal=\$tmp
        	read tmp
        	unset tmp
        	unset pager
	}
HEADER
		while(<SUB>) {
        		last if /^CONFIG \/ubcd\/menus\/syslinux\/main.cfg\r?\n$/;
		}

		while(<SUB>) {
        		s/ *\r?\n$//;
        		if (/^LABEL -$/ or /^$/) {
                		# ignore
        		} elsif (/^MENU LABEL (.*)$/) {
                		$label=$1;
        		} elsif (/^TEXT HELP$/) {
                		print SUBDESC "$label:\n\n";
                		while(<SUB>) {
                        		s/\r?\n$//;
                        		last if /^ENDTEXT$/;
                        		print SUBDESC $_.$/;
                		}
                		print SUBDESC $/.$/;
			} elsif (/^COM32 linux.c32 memdisk$/) {
                		$_=<SUB>;
                		s/\r?\n$//;
                		die unless /^INITRD ([^ ]+)$/;
                		$initrd=$1;
                		$_=<SUB>;
				$_="" unless defined $_;
                		s/\r?\n$//;
				if (/^$/) {
					$cmd="";
				} elsif (/^APPEND (.*)$/) {
					$cmd=" $1";
				} else {
					die "Unexpected option for $label in $base.cfg: '$_'\n";
				}
                		print MENU "menuentry \"$label\" {\n";
                		print MENU "    linux16 (grml)/boot/addons/memdisk$cmd\n";
                		print MENU "    initrd16 (ubcd)$initrd\n";
                		print MENU "}\n";
			} elsif (/^COM32 linux.c32 \/([^ ]+)$/) {
				$kernel=$1;
				$_=<SUB>;
				if (defined $_) {
					s/\r?\n$//;
					die unless /^INITRD ([^ ]+)$/;
					$initrd=$1;
					$_=<SUB>;
					s/\r?\n$//;
					if (/^$/) {
						$cmd="";
					} elsif (/^APPEND (.*)$/) {
						$cmd=" $1";
					} else {
						die "Unexpected option for $label in $base.cfg: '$_'\n";
					}
				} else {
					$initrd="";
					$cmd="";
				}
                		print MENU "menuentry \"$label\" {\n";
                		print MENU "    linux16 (ubcd)/$kernel$cmd\n";
                		print MENU "    initrd16 (ubcd)$initrd\n" unless $initrd eq "";
                		print MENU "}\n";
			} elsif (/^CONFIG \/pmagic\/.*$/) {
				print MENU "menuentry \"$label (via Parted Magic)\" {\n";
				print MENU "   echo \"Run Parted Magic!\"\n";
				print MENU "   read tmp\n";
				print MENU "   unset tmp\n";
				print MENU "}\n";
			} elsif (/^LINUX \/(.*)$/) {
				$kernel=$1;
                		print MENU "menuentry \"$label\" {\n";
                		print MENU "    linux16 (ubcd)/$kernel\n";
                		print MENU "}\n";
			} elsif (/^CONFIG \/ubcd\/boot\/memtest.*$/) {
				print MENU "menuentry \"$label\" {\n";
				print MENU "    linux16 (ubcd)/ubcd/boot/memtest86/memtest\n";
				print MENU "}\n";
			} elsif (/^CONFIG \/(ubcd\/menus\/syslinux\/hdd\/.*)$/) {
				$scfgfile=$1;
				($sbase=$scfgfile) =~ s#.*/(.*)\.cfg#$1#;

				open SSUB, "<", "$isodir/$scfgfile" or die $!;
				open SSUBDESC, ">", "$confdir/$sbase.txt" or die $!;

				print MENU <<HEADER;
submenu "$label" {
	menuentry "[description]" {
			set pager=1
			cat $grubconfdir/$sbase.txt
			set tmp=\$color_normal
			set color_normal=\$color_highlight
			echo -n --END--
			set color_normal=\$tmp
			read tmp
			unset tmp
			unset pager
	}
HEADER

				while(<SSUB>) {
						last if /^CONFIG \/ubcd\/menus\/syslinux\/hdd.cfg\r?\n$/;
				}

				while(<SSUB>) {
					s/ *\r?\n$//;
					if (/^LABEL -$/ or /^$/) {
							# ignore
					} elsif (/^MENU LABEL (.*)$/) {
							$label=$1;
					} elsif (/^TEXT HELP$/) {
							print SSUBDESC "$label:\n\n";
							while(<SSUB>) {
									s/\r?\n$//;
									last if /^ENDTEXT$/;
									print SSUBDESC $_.$/;
							}
							print SSUBDESC $/.$/;
					} elsif (/^COM32 linux.c32 memdisk$/) {
								$_=<SSUB>;
								s/\r?\n$//;
								die unless /^INITRD ([^ ]+)$/;
								$initrd=$1;
								$_=<SSUB>;
						$_="" unless defined $_;
								s/\r?\n$//;
						if (/^$/) {
							$cmd="";
						} elsif (/^APPEND (.*)$/) {
							$cmd=" $1";
						} else {
							die "Unexpected option for $label in $sbase.cfg: '$_'\n";
						}
								print MENU "menuentry \"$label\" {\n";
								print MENU "    linux16 (grml)/boot/addons/memdisk$cmd\n";
								print MENU "    initrd16 (ubcd)$initrd\n";
								print MENU "}\n";
					} elsif (/^COM32 linux.c32 \/([^ ]+)$/) {
						$kernel=$1;
						$_=<SSUB>;
						if (defined $_) {
							s/\r?\n$//;
							die unless /^INITRD ([^ ]+)$/;
							$initrd=$1;
							$_=<SSUB>;
							s/\r?\n$//;
							if (/^$/) {
								$cmd="";
							} elsif (/^APPEND (.*)$/) {
								$cmd=" $1";
							} else {
								die "Unexpected option for $label in $base.cfg: '$_'\n";
							}
						} else {
							$initrd="";
							$cmd="";
						}
						print MENU "menuentry \"$label\" {\n";
						print MENU "    linux16 (ubcd)/$kernel$cmd\n";
						print MENU "    initrd16 (ubcd)$initrd\n" unless $initrd eq "";
						print MENU "}\n";
					} elsif (/^CONFIG \/pmagic\/.*$/) {
						print MENU "menuentry \"$label (via Parted Magic)\" {\n";
						print MENU "   echo \"Run Parted Magic!\"\n";
						print MENU "   read tmp\n";
						print MENU "   unset tmp\n";
						print MENU "}\n";
					} elsif (/^LINUX \/(.*)$/) {
						$kernel=$1;
						print MENU "menuentry \"$label\" {\n";
						print MENU "    linux16 (ubcd)/$kernel\n";
						print MENU "}\n";
					} else {
							die "Unexpected line in $sbase.cfg: '$_'\n";
					}
				}
				close(SSUB);
				close(SSUBDESC);
				print MENU "}\n";
			} elsif (/^COM32 hdt.c32$/) {
				$_=<SUB>;
				die unless /^APPEND pciids=.*$/;
				# COMBOOT not supported by GRUB2!
        		} else {
                		die "Unexpected line in $base.cfg: '$_'\n";
        		}
		}
		close(SUB);
		close(SUBDESC);
		print MENU "}\n";
	} elsif (/^COM32 linux.c32 memdisk$/) {
		$_=<MAIN>;
		s/\r?\n$//;
		die unless /^INITRD ([^ ]+)$/;
		$initrd=$1;
		$_=<MAIN>;
		s/\r?\n$//;
		die unless /^APPEND floppy raw c=32 h=16 s=63$/;
		print MENU "menuentry \"$label\" {\n";
		print MENU "	linux16 (grml)/boot/addons/memdisk\n";
		print MENU "	initrd16 (ubcd)$initrd\n";
		print MENU "}\n";
	} else {
		die "Unexpected line: '$_'\n";
	}
}

close(MAIN);
close(MENU);
close(DESC);

print "UBCD menu created.\n";
