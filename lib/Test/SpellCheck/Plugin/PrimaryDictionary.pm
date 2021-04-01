package Test::SpellCheck::Plugin::PrimaryDictionary;

use strict;
use warnings;
use 5.026;
use experimental qw( signatures );
use Carp qw( croak );

# ABSTRACT: Test::SpellCheck plugin override for the primary dictionary
# VERSION

=head1 SYNOPSIS

 spell_check ['PrimaryDictionary', affix => '/foo/bar/baz.aff', dictionary => '/foo/bar/baz.dic'];

Or from C<spellcheck.ini>:

 [PrimaryDictionary]
 affix      = /foo/bar/baz.aff
 dictionary = /foo/bar/baz.dic

=head1 DESCRIPTION

This plugin sets the primary dictionary to what is specified.  It is useful if you have a dictionary
at an arbitrary path that you want to use.

=head1 OPTIONS

=head2 affix

The Hunspell affix file.

=head2 dictionary

The Hunspell dictionary file.

=head1 CONSTRUCTOR

=head2 new

 my $plugin = Test::SpellCheck::Plugin::PrimaryDictionary->new(%options);

This creates a new instance of the plugin.  Any of the options documented above
can be passed into the constructor.

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

=head1 SEE ALSO

=over 4

=item L<Test::SpellCheck>

=item L<Test::SpellCheck::Plugin>

=back
