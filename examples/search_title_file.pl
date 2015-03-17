#!/usr/bin/perl

use strict;
use warnings;

use lib qw( lib ../lib );

use My::Google::Scholar;

my @all_papers;
my $scholar = My::Google::Scholar->new( { num => 100 });
while (<>) {
    my $papers = $scholar->search_title( $_ ); # Returns My::Google::Scholar::Paper
    push @all_papers, @$papers;
}

for my $p (@all_papers ) {
  print "Title \"", $p->title(), "\", cited by ", $p->cited_by(), " \n";
}
