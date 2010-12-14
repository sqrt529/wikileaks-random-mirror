#!/usr/bin/perl
# wikileaks-mirror - gives you randomized a working wikileaks mirror or a complete mirrorlist
# Copyright (C) 2010 Joachim "Joe" Stiegler <blablabla@trullowitsch.de>
# 
# This program is free software; you can redistribute it and/or modify it under the terms
# of the GNU General Public License as published by the Free Software Foundation; either
# version 3 of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with this program;
# if not, see <http://www.gnu.org/licenses/>.
#
# --
# 
# Version: 1.0.1 - 2010-12-13

use warnings;
use strict;
use WWW::Mechanize;
use HTML::Parser;
use Getopt::Std;

our ($opt_l, $opt_r, $opt_h, $opt_o, $opt_i);

sub usage {
	die "usage: $0 < -l | -r > | [ -o <outfile> ] | [ -i <infile> ] | [ -h ]\n";
}

if ( (!getopts("lrho:i:")) or (defined($opt_h)) ) {
	usage();
}

my $start = 0;
my @urls;
my @mirror_urls;
my @mirror_hosts; # Obsolete / Unused for now

my $wikileaks_mirror_url = "http://213.251.145.96/mirrors.html";

my $browser = WWW::Mechanize->new(timeout=>10, onerror => \&fakedie);

if (defined($opt_i)) {
	open(INFILE, '<', $opt_i) or die "Can't open $opt_i: $!\n";
	
	while (<INFILE>) {
		chomp;
		push @urls, [$_];
	}

	close(INFILE);
}
else {
	$browser->get($wikileaks_mirror_url);

	if ($browser->success()) {
		my $parser = HTML::Parser->new();

		$parser->handler(start => \&parse_mirror_url, 'tagname, attr, self');

		$parser->parse($browser->content());
	}
	else {
		die "Sorry, can't connect to $wikileaks_mirror_url\n".$browser->response->status_line()."\n";
	}
}

die "No urls found. Possibly they changed their layout.\n" if (scalar(@urls) < 1);

foreach my $mirror_host (@urls) {
	if ($mirror_host->[0] =~ /^http/) {		
		my $tmp = $mirror_host->[0];

		push @mirror_urls, $tmp;

		$tmp =~ s/^http:\/\/|\/$//g; # obsolete

		push @mirror_hosts, $tmp; # obsolete
	}
}

my $mirror_available = 0;

if (defined($opt_o)) {
	open(MIRRORFILE, '>', $opt_o) or die "Can't open $opt_o: $!\n";
}

if (defined($opt_r)) {
	while ($mirror_available == 0) {
		my $rand = int(rand(scalar(@mirror_urls) - 1));

		$browser->get($mirror_urls[$rand]);

		if ( ($browser->success()) and ($browser->status() eq "200") ) {
			print $mirror_urls[$rand], "\n";
			$mirror_available = 1;
		}
	}
}
elsif (defined($opt_l)) {
	for (my $i=0; $i<=scalar(@mirror_urls) - 1; $i++) {
		$browser->get($mirror_urls[$i]);

		if ( ($browser->success()) and ($browser->status() eq "200") ) {
			if (defined($opt_o)) {
				print MIRRORFILE $mirror_urls[$i], "\n";
			}
			else {
				print $mirror_urls[$i], "\n";
			}
		}
	}
}
else {
	usage();
}

if (defined($opt_o)) {
	close(MIRRORFILE);
}

sub parse_mirror_url {
	my $tag = shift;

	if ($tag eq 'table') {
		$start = 1;
	}

	if ( ($tag eq 'a') and ($start == 1) ) {
		my ($class) = shift->{href};
		my $self = shift;
	
		$self->handler(end => sub { push(@urls, [$class]) if (shift eq 'a') }, "tagname");
	}
}

# This is to prevent $browser->get() to die if a mirror is unreachable.
# I know, it's not a good solution, but it works ;-)
sub fakedie {
	return;
}
