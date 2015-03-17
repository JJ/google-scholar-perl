#!/usr/bin/perl

use Test::Simple tests => 4;
use strict;
use warnings;

use lib qw( lib ../lib );

use My::Google::Scholar;

my $scholar = My::Google::Scholar->new( { num => 100,
					  as_subj => 'eng' });

my $papers = $scholar->search_author( 'Koza, John' ); # Returns My::Google::Scholar::Paper

ok( @$papers >= 50, "Koza's number of papers is correct" );

my $h_index = $scholar->h_index( $papers );
ok( $h_index >= 33, "Koza's h_index is OK" );

my $cites = $scholar->references( $papers );
ok( $cites >= 2000, "Koza's number of references is OK" );

my $g_index = $scholar->g_index('Schoenauer, Marc');
ok( $g_index >= 20, "Schoenauer's g_index is OK" );


