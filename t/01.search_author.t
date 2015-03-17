#!/usr/bin/perl

use Test::Simple tests => 2;
use strict;
use warnings;

use lib qw( lib ../lib );

use My::Google::Scholar;

my $num_papers = 100;
my $scholar = My::Google::Scholar->new( { num => $num_papers,
					  as_subj => 'eng' });
ok ( defined ($scholar ) , 'new() works' );
my $papers = $scholar->search_author( 'Koza, John' ); # Returns My::Google::Scholar::Paper
ok( @$papers == 100, 'search_author works');
