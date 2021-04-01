package Test::SpellCheck::Plugin::PerlWords;

use strict;
use warnings;
use 5.026;
use experimental qw( signatures );
use File::ShareDir::Dist qw( dist_share );
use Path::Tiny qw( path );

# ABSTRACT: Test::SpellCheck plugin that adds Perl jargon words
# VERSION

=head1 OPTIONS

None.

=head1 CONSTRUCTOR

=head2 new

=cut

sub new ($class)
{
  bless {
    root => path(dist_share('Test-SpellCheck'))
  }, $class;
}

sub dictionary ($self)
{
  return (
    map { $_->stringify } $self->{root}->child('perl.dic'),
  );
}

1;
