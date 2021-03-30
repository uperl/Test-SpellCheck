package Test::SourceFile;

use strict;
use warnings;
use 5.026;
use experimental qw( signatures );
use Path::Tiny ();
use base qw( Exporter );

our @EXPORT = qw( file );

sub file ($name, $content)
{
  state $root;
  $root ||= Path::Tiny->tempdir;
  my $path = $root->child($name);
  $path->parent->mkpath;
  $path->spew_utf8($content);
  $path;
}

1;
