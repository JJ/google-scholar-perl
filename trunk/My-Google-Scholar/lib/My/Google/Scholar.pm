package My::Google::Scholar;

use warnings;
use strict;
use Carp;

use lib qw( lib ../lib );

#Specific classes
use LWP::UserAgent;
use URI::Escape;
use HTML::TreeBuilder::XPath;
use My::Google::Scholar::Paper;
use HTTP::Cookies;

use version; our $VERSION = qv('0.0.4');

# Other recommended modules (uncomment to use):
#  use IO::Prompt;
#  use Perl6::Export;
#  use Perl6::Slurp;
#  use Perl6::Say;


# Module implementation here
sub new {
  my $class = shift;
  my $options = shift;
  bless $options, $class;
  my $ua = LWP::UserAgent->new( agent => 'SchoSpider v0.1' );
  $ua->cookie_jar(HTTP::Cookies->new(file => "$ENV{HOME}/.lwpcookies.txt",
				     autosave => 1));
  $options->{'_ua'} = $ua;
  my $tree= HTML::TreeBuilder::XPath->new;
  $options->{'_xpath'}=$tree;
  return $options;
}

sub _search {
  my $self = shift;
  my $query = shift || carp "No query!\n";
  my $url = "http://scholar.google.com/scholar?$query";
  my $resp = $self->{'_ua'}->get($url);
  if ( $resp->is_success ) {
    return  $resp->content;
  } else {
    carp "Problems searching : "+$resp->status_line ;
  }
}

sub search_author {
  my $self = shift;
  my $author = shift;
  my $uri_author = uri_escape("\"$author\"");
  my $query = "num=".$self->{'num'}."&btnG=Buscar+en+Google+Acad%C3%A9mico&as_sauthors=$uri_author&as_subj=".$self->{'as_subj'};
  my $result = $self->_search($query);
  $self->{'_xpath'}->parse( $result );
  my $nb=$self->{'_xpath'}->findnodes( '/html/body//p[@class="g"]');
  my @papers;
  for my $n (@$nb ) {
    push @papers, My::Google::Scholar::Paper->new( $n->as_HTML() );
  }
  return \@papers;
}

sub h_index {
  my $self = shift;
  my $arg = shift;
  my $papers;
  if ( !ref $arg ) {
    $papers =  $self->search_author( $arg );
  } else {
    $papers = $arg;
  }
  my @sorted_papers = sort { $b->cited_by() <=> $a->cited_by() } @$papers;
  my $h_index = 0;
  while ( ( $sorted_papers[$h_index]->cited_by() >= $h_index )  
	  && ($h_index < $#sorted_papers ) ) {
      $h_index++;
  } 
  return $h_index;

}

sub g_index {
  my $self = shift;
  my $arg = shift;
  my $papers;
  if ( !ref $arg ) {
    $papers =  $self->search_author( $arg );
  } else {
    $papers = $arg;
  }
  my @sorted_papers = sort { $b->cited_by() <=> $a->cited_by() } @$papers;
  my $g_index = 0;
  my $citations = 0;
  do  {
    $citations += $sorted_papers[$g_index]->cited_by();
    $g_index++;
  } until ( ( $citations < $g_index*$g_index )  
	  && ($g_index < $#sorted_papers ) );
  return $g_index;

}

sub references {
  my $self = shift;
  my $arg = shift;
  my $papers;
  if ( !ref $arg ) {
    $papers =  $self->search_author( $arg );
  } else {
    $papers = $arg;
  }
  my $references;
  for my $p ( @$papers ) {
    $references += $p->cited_by();
  }
  return $references;
}

1; # Magic true value required at end of module
__END__

=head1 NAME

My::Google::Scholar - Download and parse Google Scholar files


=head1 VERSION

This document describes My::Google::Scholar version 0.0.1


=head1 SYNOPSIS

  use My::Google::Scholar;

my $scholar = My::Google::Scholar->new( { num => 100,
					  as_subj => 'eng' });

my $papers = $scholar->search_author( 'Koza, John' ); # Returns My::Google::Scholar::Paper

for my $p (@$papers ) {
  print "Title ", $p->title(), "\n";
}

my $h = $scholar->h_index( 'Holland, John' ); # or
my $h = $scholar->h_index( $papers );

my $cites = $scholar->references( 'Goldberg, David' ); # or
my $cites = $scholar->references( $papers );
  
  
=head1 DESCRIPTION

Module for scraping and obtaining results from Google Scholar (L<
http://scholar.google.com >), mainly geared for obtaining the Hirsch h
index, but also (hopefully) useful for other stuff.


=head1 INTERFACE 

=head2 new


my $scholar = My::Google::Scholar->new( { num => 100,
					  as_subj => 'eng' });

C<num> is the number of results returned. num > 100 will yield impredictable results. C<as_subj> is the (possibly undocumented) option to restric the subjects that are going to be searched. 'eng' is for engineering, you're on your own for other subjects. If this option is not set, it will search all subjects. 

=head2 search_author( $author_name )

my $papers = $scholar->search_author( 'Koza, John' ); 

Returns an arrayref of L<My::Google::Scholar::Paper>'s

=head2 h_index( $author_name )

my $h_index = $scholar->search_author( 'Koza, John' );

Return Hirsch's H Index according to Google Scholar.

my $h_index = $scholar->search_author( $papers_ref );

Can use as second argument a reference to an array of papers as
returned by C<search_author>

=head2 g_index( $author_name )

my $g_index = $scholar->search_author( 'Schoenauer, Marc' );

Return g-index according to Google Scholar.

my $g_index = $scholar->search_author( $papers_ref );

Can use as second argument a reference to an array of papers as
returned by C<search_author>

=head2 references( $author_name )

Returns the total number of references found in the pages
searched. Can also take as second argument a reference to an array of
papers.

Can be called also as references( $papers )

=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.
  
My::Google::Scholar requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-my-google-scholar@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

JJ Merelo  C<< <jj@merelo.net> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2007, JJ Merelo C<< <jj@merelo.net> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
