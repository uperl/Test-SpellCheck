package Test::SpellCheck::Plugin::Perl;

use strict;
use warnings;
use 5.026;
use Module::Load qw( load );
use Test::SpellCheck::Plugin::PerlComment;
use Test::SpellCheck::Plugin::PerlPOD;
use Test::SpellCheck::Plugin::PerlWords;
use base qw( Test::SpellCheck::Plugin::Combo );
use Carp qw( croak );
use PerlX::Maybe;
use experimental qw( signatures );

our @CARP_NOT = qw( Test::SpellCheck );

# ABSTRACT: Test::SpellCheck plugin for checking spelling in Perl source
# VERSION

=head1 OPTIONS

=head2 skip_sections

=head2 lang

=head1 CONSTRUCTOR

=head2 new

=cut

sub new ($class, %args)
{
  my $lang_class;
  if(defined $args{lang})
  {
    if($args{lang} =~ /^([a-z]{2})-([a-z]{2})$/i)
    {
      $lang_class = join '::', 'Test::SpellCheck::Plugin::Lang', uc $1, uc $2;
    }
    else
    {
      croak "bad language: $args{lang}";
    }
  }
  else
  {
    $lang_class = 'Test::SpellCheck::Plugin::Lang::EN::US';
  }

  load $lang_class;

  $class->SUPER::new(
    $lang_class->new,
    Test::SpellCheck::Plugin::PerlWords->new,
    # we want to do the pod parse first, because
    # it might have some stop words that we
    # want to consider for comments.
    Test::SpellCheck::Plugin::PerlPOD->new(
      maybe skip_sections => $args{skip_sections},
    ),
    Test::SpellCheck::Plugin::PerlComment->new,
  );
}

1;


