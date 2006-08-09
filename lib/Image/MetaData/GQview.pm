package Image::MetaData::GQview;

use 5.008008;
use strict;
use warnings;

use Cwd qw(abs_path);

use vars qw($RCS_VERSION $VERSION);

$RCS_VERSION = '$Id: GQview.pm,v 1.2 2006/08/09 19:56:35 klaus Exp $';
($VERSION = '$Revision: 1.2 $') =~ s/^\D*([\d.]*)\D*$/$1/;

sub new
{
   my $param = shift;
   my $class = ref($param) || $param;
   my $file = shift;

   my $self = {};

   bless $self, $class;

   $self->{error} = undef;
   $self->load($file) if $file;

   return $self;
} # new

sub load
{
   my $self = shift;
   my $image = shift || $self->{imagefile};

   return $self->_error(undef, "No File given") unless $image;
   $image = abs_path($image);
   return $self->_error(undef, "No such file") unless -e $image;

   $self->{imagefile} = $image;

   (my $metadata1 = $image) =~ s#/([^/]*)$#/.metadata/$1.meta#;
   my $metadata2 = abs_path($ENV{HOME}) . ".gqview/metadata$image.meta";

   my $metadata;
   $metadata = $metadata1 if -r $metadata1;
   $metadata ||= $metadata2 if -r $metadata2;
   $self->{metafile} = $metadata;

   return $self->_error(undef, "No metadata found") unless $metadata;

   open my $in, "<:utf8", $metadata or return $self->_error(undef, "Unable to read metafile");
   local $/ = undef;
   $self->{metadata} = <$in>;
   close $in;

   # Aufbau:
   # #GQview comment (<version>)
   #
   # [keywords]
   # ...
   #
   # [comment]
   # ...
   #
   # #end
   if ($self->{metadata} =~ /^\[keywords]\n([^\[\]]*)\n\n/ms)
   {
      # Found Keywords
      @{$self->{keywords}} = split(/\n/, $1);
      @{$self->{keywords}} = grep {$_} @{$self->{keywords}};
   }
   if ($self->{metadata} =~ /^\[comment]\n(.*\n)\n#end/ms)
   {
      $self->{comment} = $1;
   }

   $self->{error} = undef;
   return 1;
} # load

sub comment
{
   my $self = shift;
   my $comment = shift;

   if ($comment)
   {
      $self->{comment} = $comment;
      $self->_sync;
   }

   $self->{error} = undef;
   return $self->{comment};
} # comment

sub keywords
{
   my $self = shift;

   if (@_)
   {
      $self->{keywords} = [@_];
      $self->_sync;
   }

   $self->{error} = undef;
   return @{$self->{keywords}};
} # keywords

sub raw
{
   my $self = shift;

   $self->{error} = undef;
   return $self->{metadata};
} # raw

sub save
{
   my $self = shift;
   my $image = shift;
   my $newimage = $image;
   $image ||= $self->{imagefile};
   my $metafile = shift;
   my $newmetafile = $metafile;
   $metafile ||= $self->{metafile};

   return $self->_error(undef, "No File given") unless $image;
   $image = abs_path($image);
   return $self->_error(undef, "No such file") unless -e $image;

   (my $metadata1 = $image) =~ s#/([^/]*)$#/.metadata/$1.meta#;
   my $metadata2 = abs_path($ENV{HOME}) . ".gqview/metadata$image.meta";

   my $metadata;
   # Read the gqviewrc
   if (open my $in, "<", $ENV{HOME} . "/.gqview/gqviewrc")
   {
      while (my $line = <$in>)
      {
	 chomp $line;
	 next if $line =~ /^#/;
	 if ($line =~ /^local_metadata: (true|false)$/)
	 {
	    $metadata = ($1 eq "true") ? $metadata1 : $metadata2;
	    last;
	 }
      }
      close $in;
   } # if (open my $in, "<", $ENV...
   if ($newimage and not $newmetafile)
   {
      $metafile = $metadata;
   }

   my $false;
   my @metadirs = split(/\//, $metafile);
   pop @metadirs;
   my $metadir = "";
   while (@metadirs)
   {
      $metadir .= shift(@metadirs) . "/";
      unless (-d $metadir or mkdir($metadir))
      {
	 $false = 1;
	 last;
      }
   }
   if ($false and not $newmetafile and $metafile ne $metadata2)
   {
      $false = 0;
      $metafile = $metadata2;
      @metadirs = split(/\//, $metadata2);
      pop @metadirs;
      $metadir = "";
      while (@metadirs)
      {
	 $metadir .= shift(@metadirs) . "/";
	 unless (-d $metadir or mkdir($metadir))
	 {
	    $false = 1;
	    last;
	 }
      }
   } # if ($false and not $newmetafil...
   if ($false)
   {
      return $self->_error(undef, "Cannot create directory structure for meta file");
   }
   open my $meta, ">:utf8", $metafile or return $self->_error(undef, $!);
   print $meta $self->raw or return $self->_error(undef, $!);
   close $meta or $self->_error(undef, $!);

   $self->{imagefile} = $image;
   $self->{metafile} = $metafile;
   $self->{error} = undef;
   return 1;
} # save

sub _sync
{
   my $self = shift;

   @{$self->{keywords}} = grep {$_} @{$self->{keywords}};
   $self->{metadata} = "GQview comment (2.1.1)\n\n[keywords]\n" . join("\n", @{$self->{keywords}}) . (@{$self->{keywords}} ? "\n" : "") . "\n[comment]\n" . $self->{comment} . ($self->{comment} =~ /\n$/ ? "" : "\n") . ($self->{comment} ? "\n" : "") . "#end\n";
} # _sync

sub _error
{
   my $self = shift;
   my $ret = shift;
   my $msg = shift;

   $self->{error} = $msg;

   return $ret;
} # _error

1;

__END__

=head1 NAME

Image::MetaData::GQview - Perl extension for GQview image metadata

=head1 SYNOPSIS

  use Image::MetaData::GQview;
  my $md = Image::MetaData::GQview->new("test.jpg");
  $md->load("test.jpg");
  my $comment = $md->comment;
  my @keywords = $md->keywords;
  my $raw = $md->raw;
  $md->comment("This is a comment");
  $md->keywords(@keywords);
  $md->save("test.jpg");

=head1 DESCRIPTION

This module is a abstraction to the image meta data of GQview.

=head2 METHODS

=over

=item new

This is a class method and the only one. It is used to get a object of Image::MetaData::GQview. It can be called without parameter or with the image as only option in witch case it try to load the meta data.

=item load

If you didn't load the data with new you can do that with this method. If the parameter is left out the one setted before is used.

=item comment

Get or set the comment.

=item keywords

Get or set the keywords.

=item raw

Get the raw data

=item save

Save the data to disk. This will read the location from the gqview configuration. If there is none, the info will be saved in local directory.

=back

=head1 SEE ALSO

Manpage of gqview

=head1 AUTHOR

S<Klaus Ethgen E<lt>Klaus@Ethgen.deE<gt>>

=head1 COPYRIGHT

Copyright (c) 2006 by Klaus Ethgen. All rights reserved.

=head1 LICENSE

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 2 of the License, or (at your option) any later
version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program; if not, write to the Free Software Foundation, Inc., 675 Mass
Ave, Cambridge, MA 02139, USA.

=cut
