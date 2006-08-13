#!perl -T
#
# $Id: Image-MetaData-GQview.t,v 1.3 2006/08/13 14:52:26 klaus Exp $
#

use Test::More tests => 10;

use Image::MetaData::GQview;

my $md = eval {Image::MetaData::GQview->new};
ok(!$@, "Instanting the class");
ok(defined $md, "new");
isa_ok($md,'Image::MetaData::GQview');
is($md->{error}, undef, "error with new");

# Now create a testfile and a dir...
-e 'test.jpg' and unlink 'test.jpg';
open my $file, ">", 'test.jpg';
print $file "\n";
close $file;

eval {$md->comment("This is a comment")};
ok(!$@, "Setting comment ($@)");
eval {$md->keywords(qw(foo bar))};
ok(!$@, "Setting Keywords ($@)");

ok(eval {$md->save('test.jpg', 'test.jpg.meta')}, 'save("test.jpg", ".metadata/test.jpg.meta")');
ok(!$@, "Save ($@)");

eval {$md->load('test.jpg', 'test.jpg.meta')};
ok(!$@, "Load a file ($@)");

# Clean up ...
-e 'test.jpg' and unlink 'test.jpg';
-e 'test.jpg.meta' and unlink 'test.jpg.meta';

eval {$md->load('test.jpg')};
ok($@, "Load a (not existing) file (should give an error ($@))");
