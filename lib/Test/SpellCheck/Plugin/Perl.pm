package Test::SpellCheck::Plugin::Perl;

use strict;
use warnings;
use 5.026;
use Test::SpellCheck::Plugin::Lang::EN::US;
use Test::SpellCheck::Plugin::PerlComment;
use Test::SpellCheck::Plugin::PerlPOD;
use Test::SpellCheck::Plugin::PerlWords;
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
      Test::SpellCheck::Plugin::Lang::EN::US->new,
      Test::SpellCheck::Plugin::PerlWords->new,
      # we want to do the pod parse first, because
      # it might have some stop words that we
      # want to consider for comments.
      Test::SpellCheck::Plugin::PerlPOD->new,
      Test::SpellCheck::Plugin::PerlComment->new,
    ],
  }, $class;
}

sub primary_dictionary ($self)
{
  foreach my $plugin ($self->{plugins}->@*)
  {
    # TODO: make sure we don't have more than one.
    return $plugin->primary_dictionary if $plugin->can('primary_dictionary');
  }
}

sub dictionary ($self)
{
  my @dic;
  foreach my $plugin ($self->{plugins}->@*)
  {
    push @dic, $plugin->dictionary if $plugin->can('dictionary');
  }
  return @dic;
}

sub stream ($self, $filename, $callback)
{
  foreach my $plugin ($self->{plugins}->@*)
  {
    $plugin->stream($filename, $callback) if $plugin->can('stream');
  }
  return $self;
}

1;


