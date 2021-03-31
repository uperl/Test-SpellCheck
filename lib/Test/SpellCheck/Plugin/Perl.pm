package Test::SpellCheck::Plugin::Perl;

use strict;
use warnings;
use 5.026;
use Test::SpellCheck::Plugin::Lang::EN::US;
use Test::SpellCheck::Plugin::PerlComment;
use Test::SpellCheck::Plugin::PerlPOD;
use Test::SpellCheck::Plugin::PerlWords;
use base qw( Test::SpellCheck::Plugin::Combo );
use PerlX::Maybe;
use experimental qw( signatures );

# ABSTRACT: Test::SpellCheck plugin for checking spelling in Perl source
# VERSION

=head1 CONSTRUCTOR

=head2 new

=cut

sub new ($class, %args)
{
  $class->SUPER::new(
    Test::SpellCheck::Plugin::Lang::EN::US->new,
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


