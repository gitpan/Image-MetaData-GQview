#!perl -T
#
# $Id: 00-load.t,v 1.1 2006/08/12 18:58:27 klaus Exp $
#

use Test::More tests => 1;

BEGIN {
	use_ok( 'Image::MetaData::GQview' );
}

diag( "Testing Image::MetaData::GQview $Image::MetaData::GQview::VERSION, Perl $], $^X" );
