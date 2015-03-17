use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
	      NAME                => 'My::Google::Scholar',
	      AUTHOR              => 'JJ Merelo <jj@merelo.net>',
	      VERSION_FROM        => 'lib/My/Google/Scholar.pm',
	      ABSTRACT_FROM       => 'lib/My/Google/Scholar.pm',
	      PL_FILES            => {},
	      PREREQ_PM => {
			    'Test::More' => 0,
			    'version'    => 0,
			    'HTML::TreeBuilder::XPath' => 0,
			    'LWP::UserAgent' => 0,
			    'URI::Escape' => 0
			   },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'My-Google-Scholar-*' },
);
