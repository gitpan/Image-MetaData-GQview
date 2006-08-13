use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
   NAME          => 'Image::MetaData::GQview',
   AUTHOR        => 'Klaus Ethgen <Klaus@Ethgen.de>',
   VERSION_FROM  => 'lib/Image/MetaData/GQview.pm',
   ABSTRACT_FROM => 'lib/Image/MetaData/GQview.pm',
   PL_FILES      => {},
   PREREQ_PM     => {'Test::More' => 0,},
   dist          => {COMPRESS => 'gzip -9f', SUFFIX => 'gz',},
   clean         => {FILES => 'Image-MetaData-GQview-*'},
);
