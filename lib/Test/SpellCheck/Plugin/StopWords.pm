package Test::SpellCheck::Plugin::StopWords;

use strict;
use warnings;
use 5.026;
use experimental qw( signatures );
use Path::Tiny qw( path );
use Ref::Util qw( is_plain_arrayref );

# ABSTRACT: Test::SpellCheck plugin that adds arbitrary jargon words
# VERSION

=head1 OPTIONS

=head2 word

=head2 file

=head1 CONSTRUCTOR

=head2 new

=cut

sub new ($class, %args)
{
  my %stopwords;

  if($args{file})
  {
    my @words = path($args{file})->lines_utf8;
    chomp @words;
    $stopwords{$_} = 1 for @words;
  }

  if(defined $args{word})
  {
    if(is_plain_arrayref $args{word})
    {
      $stopwords{$_} = 1 for $args{word}->@*;
    }
    else
    {
      $stopwords{$args{word}} = 1;
    }
  }

  bless {
    stopwords => [sort keys %stopwords],
  }, $class;
}


sub stopwords ($self)
{
  return $self->{stopwords}->@*;
}

1;
