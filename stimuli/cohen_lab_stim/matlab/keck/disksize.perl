#!/usr/local/bin/perl

sub getfssize {
	my $line = `df -k $_[0] | grep $_[0]`;
	
	my $size = (split(/\s+/,$line))[3];
	return $size;
}

	foreach $i (@ARGV) {
		print getfssize($i) , "\n";
	}

