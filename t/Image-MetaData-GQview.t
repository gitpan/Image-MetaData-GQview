#! /usr/bin/perl -T
#
# $Id: Image-MetaData-GQview.t,v 1.1 2006/08/08 22:55:30 klaus Exp $
#

use Test::More 'no_plan';
BEGIN { use_ok('Image::MetaData::GQview') };

#########################

my $md = Image::MetaData::GQview->new;
ok(defined $md, "new");
isa_ok($md,'Image::MetaData::GQview');
is($md->{error}, undef, "error with new");

[ -e "test.jpg" ] && unlink "test.jpg";
$md->load("test.jpg");
isnt($md->{error}, undef, "error with load");

# Now create a testfile and a dir...
open my $file, ">", "test.jpg";
print $file "\n";
close $file;

$md->comment("This is a comment");
is($md->{error}, undef);
$md->keywords(qw(foo bar));
is($md->{error}, undef);

my $res = $md->save("test.jpg", ".metadata/test.jpg.meta");
ok($res, 'save("test.jpg", ".metadata/test.jpg.meta")');
is($md->{error}, undef, "error with save");
