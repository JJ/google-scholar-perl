use Test::More tests => 2; # -*- mode: perl -*- 

BEGIN {
use_ok( 'My::Google::Scholar' );
use_ok( 'My::Google::Scholar::Paper' );
}

diag( "Testing My::Google::Scholar $My::Google::Scholar::VERSION" );
