package Test::SpellCheck::Plugin::Perl;

use strict;
use warnings;
use 5.026;
use Module::Load qw( load );
use Test::SpellCheck::Plugin::PerlPOD;
use Test::SpellCheck::Plugin::PerlWords;
use base qw( Test::SpellCheck::Plugin::Combo );
use Carp qw( croak );
use PerlX::Maybe;
use Ref::Util qw( is_plain_arrayref );
use experimental qw( signatures );

our @CARP_NOT = qw( Test::SpellCheck );

# ABSTRACT: Test::SpellCheck plugin for checking spelling in Perl source
# VERSION

=head1 OPTIONS

=head2 skip_sections

=head2 lang

=head2 check_comments

=head1 CONSTRUCTOR

=head2 new

=cut

sub new ($class, %args)
{
  my $lang_class;
  my @lang_args;

  if(defined $args{lang})
  {
    if(is_plain_arrayref $args{lang})
    {
      $lang_class = 'Test::SpellCheck::Plugin::PrimaryDictionary';
      my($affix, $dic) = $args{lang}->@*;
      @lang_args = (affix => $affix, dictionary => $dic);
    }
    elsif($args{lang} =~ /^([a-z]{2})-([a-z]{2})$/i)
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

  my @plugins = (
    $lang_class->new(@lang_args),
    Test::SpellCheck::Plugin::PerlWords->new,
    Test::SpellCheck::Plugin::PerlPOD->new(
      maybe skip_sections => $args{skip_sections},
    ),
  );

  if($args{check_comments} // 1)
  {
    require Test::SpellCheck::Plugin::PerlComment;
    push @plugins, Test::SpellCheck::Plugin::PerlComment->new;
  }

  $class->SUPER::new(@plugins);
}

1;


