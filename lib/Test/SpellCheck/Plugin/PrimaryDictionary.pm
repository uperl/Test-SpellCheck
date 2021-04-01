package Test::SpellCheck::Plugin::PrimaryDictionary;

use strict;
use warnings;
use 5.026;
use experimental qw( signatures );
use Carp qw( croak );

# ABSTRACT: Test::SpellCheck plugin override for the primary dictionary
# VERSION

=head1 OPTIONS

=head2 affix

=head2 dictionary

=head1 CONSTRUCTOR

=head2 new

=cut

sub new ($class, %args)
{
  croak "must specify affix file" unless defined $args{affix};
  croak "must specify dictionary file" unless defined $args{dictionary};
  croak "affix file $args{affix} not found" unless -f $args{affix};
  croak "dictionary $args{dictionary} not found" unless -f $args{dictionary};
  bless { affix => $args{affix}, dictionary => $args{dictionary} }, $class;
}

sub primary_dictionary ($self)
{
  return ($self->{affix}, $self->{dictionary});
}

1;
