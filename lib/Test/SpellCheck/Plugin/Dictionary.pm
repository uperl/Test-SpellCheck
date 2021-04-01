package Test::SpellCheck::Plugin::Dictionary;

use strict;
use warnings;
use 5.026;
use experimental qw( signatures );
use Carp qw( croak );

# ABSTRACT: Test::SpellCheck for checking spelling in Perl comments
# VERSION

=head1 OPTIONS

=head2 dictionary

=head1 CONSTRUCTOR

=head2 new

=cut

sub new ($class, %args)
{
  croak "must specify dictionary" unless defined $args{dictionary};
  croak "dictionary $args{dictionary} not found" unless -f $args{dictionary};
  bless { dictionary => $args{dictionary} }, $class;
}

sub dictionary ($self)
{
  return $self->{dictionary};
}

1;
