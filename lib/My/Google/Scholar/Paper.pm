package My::Google::Scholar::Paper;

use warnings;
use strict;
use Carp;

#Specific classes
use HTML::TreeBuilder::XPath;
use utf8;
use Encode;

use version; our $VERSION = qv('0.0.5');

# Other recommended modules (uncomment to use):
#  use IO::Prompt;
#  use Perl6::Export;
#  use Perl6::Slurp;
#  use Perl6::Say;


# Module implementation here
sub new {
  my $class = shift;
  my $options = shift;

  my $paper;
  if ( !ref $options ) { # Escalar 
    my $tree = HTML::TreeBuilder::XPath->new;
    $tree->parse($options);
    my $titulo_entry = $tree->findvalue( '//h3');
    my ($tipo, $titulo) = ( $titulo_entry =~ m{(\[\w+\])? ?(.+)}gs );

    #REMOVE spaces in TITULO
    ($titulo) = $titulo=~ /^\s*(\S.*)\s*$/g;
    $titulo=~ s/\x{2026}/.../g;
    chop($titulo);

    #if ( !$titulo ) { #Alternative representation
    #  ($tipo, $titulo) = ( $options =~ m{(\[\w+\])? .+</font>\&nbsp;([^-<]+)(-|<)}gs );
    #}

    ### changed: <span> class doesn't work. Replaced with <div>
    #my $autores_pub =  $tree->findvalue( '//span[@class="gs_a"]');
    my $autores_pub =  $tree->findvalue( '//div[@class="gs_a"]');
    
    my ($autores, $pub ) = ( $autores_pub =~ /([^-]+)\s*-?\s*(.*)/gs );

    ($autores) = $autores=~ /^\s*(\S.*)\s*$/g;
    $autores=~ s/\s*\x{2026}\s*//g;
    chop($autores);
    
    my ($cited_by) = ($options =~ /Cited by (\d*)/gs);
    $paper = { _title => $titulo,
	       _pub => $pub,
	       _cited_by => $cited_by || 0 };

    if ( $autores =~ /,/ ) {
      my @autores = split(/,\s*/, $autores );
      $paper->{_authors} = \@autores;
    } else {
      $paper->{_authors} = [$autores];
    }

    #Added way for adding PDF
    if ($options=~/class\=\"gs_ggs gs_fl\"/) {
    	my $pdf_exists =  $tree->findnodes( '//span[@class="gs_ggs gs_fl"]/b/a');
    	if ($pdf_exists) {
		my @list = $pdf_exists->get_nodelist();
		foreach my $pdftext (@list) {
			for (@{ $pdftext->extract_links() }) {
				$paper->{_doc} = @{$_}[0];
  			}
		}
		my $type_doc =  $tree->findvalue( '//span[@class="gs_ggs gs_fl"]/b/span[@class="gs_ctg"]');
		$type_doc =~ s/\[//g;
		$type_doc =~ s/\]//g;
		$paper->{_typedoc} = $type_doc;	
    	}
    }

    #Added way for links
    my $link_exists =  $tree->findnodes( '//h3/a');
    	if ($link_exists) {
		my @list = $link_exists->get_nodelist();
		foreach my $linktext (@list) {
			for (@{ $linktext->extract_links() }) {
				$paper->{_url} = @{$_}[0];
  			}
		}
    	}

    #Added way for type of ref
    my $type =  $tree->findvalue( '//h3/span[@class="gs_ctc"]');
    	if ($type) {
		$type =~  s/\[//g;
		$type =~ s/\]//g;
		$paper->{_type} = $type;		
    	}
	else {
		$type =  $tree->findvalue( '//h3/span[@class="gs_ctu"]');
		if ($type) {
			$type =~  s/\[//g;
			$type =~ s/\]//g;
			$paper->{_type} = $type;		
    		}
		else {$paper->{_type} = "ARTICLE";}

	}
   }
  
  bless $paper, $class;
  return $paper;
}

sub title {
  my $self = shift;
  return $self->{'_title' };
}

sub type {
  my $self = shift;
  return $self->{'_type' };
}


sub cited_by {
  my $self = shift;
  return $self->{'_cited_by'};
}

sub authors {
  my $self = shift;
  return $self->{'_authors'};
}

sub doc {
  my $self = shift;
  return $self->{'_doc'};
}

sub typedoc {
  my $self = shift;
  return $self->{'_typedoc'};
}

sub url {
  my $self = shift;
  return $self->{'_url'};
}


"h=100!"; # Magic true value required at end of module
__END__

=head1 NAME

My::Google::Scholar::Paper - Structure to hold papers


=head1 VERSION

This document describes My::Google::Scholar version 0.0.3


=head1 SYNOPSIS

use My::Google::Scholar::Paper

my $paper = My::Google::Scholar::Paper->new( $html_chunk); # or
my $paper = My::Google::Scholar::Paper->new( _title => $titulo );

print paper->title();
print paper->cited_by();
  
  
=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE 

=head2 new 

my $paper = My::Google::Scholar::Paper->new( $html_chunk); # or
my $paper = My::Google::Scholar::Paper->new( _title => $titulo );

Creates a new paper data structure

=head2 title

Returns the paper title

=head2 cited_by

Returns the number of citations


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
