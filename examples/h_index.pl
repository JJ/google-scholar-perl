#!/usr/bin/perl

use strict;
use warnings;

use lib qw( lib ../lib );

use My::Google::Scholar;
my $author = shift || die "Need an author: $0 <author_name>\n";

my $scholar = My::Google::Scholar->new( { num => 100,
					  as_subj => 'eng' });

my $h_index = $scholar->h_index( $author ); # Returns My::Google::Scholar::Paper

print "H-Index for $author is $h_index\n";

