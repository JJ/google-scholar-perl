#!/usr/bin/perl

use strict;
use warnings;

use lib qw( lib ../lib );

use My::Google::Scholar;

my $scholar = My::Google::Scholar->new( { num => 100 });

my $papers = $scholar->search_title( 'Evolving multilayer perceptrons' ); # Returns My::Google::Scholar::Paper

for my $p (@$papers ) {
  print "Title \"", $p->title(), "\", cited by ", $p->cited_by(), " \n";
}
