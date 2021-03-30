package Test::SpellCheck::Plugin::Perl;

use strict;
use warnings;
use 5.026;
use Test::SpellCheck::Plugin::PerlComment;
use Test::SpellCheck::Plugin::PerlPOD;
use experimental qw( signatures );

# ABSTRACT: Test::SpellCheck plugin for checking spelling in Perl source
# VERSION

=head1 CONSTRUCTOR

=head2 new

=cut

sub new ($class)
{
  bless {
    plugins => [
      # we want to do the pod parse first, because
      # it might have some stop words that we
      # want to consider for comments.
      Test::SpellCheck::Plugin::PerlPOD->new,
      Test::SpellCheck::Plugin::PerlComment->new,
    ],
  }, $class;
}

=head1 METHODS

=head2 stream

=cut

sub stream ($self, $filename, $callback)
{
  foreach my $plugin ($self->{plugins}->@*)
  {
    $plugin->stream($filename, $callback);
  }
}

1;


