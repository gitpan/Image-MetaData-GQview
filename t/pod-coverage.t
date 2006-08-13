#!perl -T
#
# $Id: pod-coverage.t,v 1.1 2006/08/12 18:58:27 klaus Exp $
#

use Test::More;
eval "use Test::Pod::Coverage 1.04";
plan skip_all => "Test::Pod::Coverage 1.04 required for testing POD coverage" if $@;
all_pod_coverage_ok({ trustme => [qr/^(open|close)$/] });
