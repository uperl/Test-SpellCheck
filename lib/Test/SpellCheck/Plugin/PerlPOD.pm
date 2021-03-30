package Test::SpellCheck::Plugin::PerlPOD;

use strict;
use warnings;
use 5.026;
use Pod::Simple::Words;
use experimental qw( signatures );

# ABSTRACT: Test::SpellCheck plugin for checking spelling in POD
# VERSION

=head1 CONSTRUCTOR

=head2 new

=cut

sub new ($class)
{
  bless {}, $class;
}

=head1 METHODS

=head2 stream

=cut

sub stream ($self, $filename, $callback)
{
  my $parser = Pod::Simple::Words->new;
  $parser->callback($callback);
  $parser->parse_file($filename);
  return $self;
}

1;


