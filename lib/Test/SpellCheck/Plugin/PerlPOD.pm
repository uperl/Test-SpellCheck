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

sub stream ($self, $filename, $callback)
{
  my $parser = Pod::Simple::Words->new;
  $parser->callback($callback);
  # TODO: make this configurable
  $parser->skip_sections('contributors', 'author', 'copyright and license');
  $parser->parse_file($filename);
  return $self;
}

1;


