#!/usr/bin/perl

use Test::Simple tests => 1;
use strict;
use warnings;

use lib qw( lib ../lib );

use My::Google::Scholar;

my $scholar = My::Google::Scholar->new( { num => 100,
					  as_subj => 'eng' });

my $h_index = $scholar->h_index( 'Koza, John' ); # Returns My::Google::Scholar::Paper

ok( $h_index >= 33, "Koza's h_index is correct" );

