package Test::SpellCheck::Plugin::PerlComment;

use strict;
use warnings;
use 5.026;
use PPI;
use experimental qw( signatures );

# ABSTRACT: Test::SpellCheck for checking spelling in Perl comments
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
  my $doc = PPI::Document->new($filename);
  foreach my $comment (($doc->find('PPI::Token::Comment') || [])->@*)
  {
    next if $comment->location->[0] == 1 &&
            "$comment" =~ /^#!/;
    foreach my $frag (split /\s/, "$comment")
    {
      next unless $frag =~ /\w/;
      if($frag =~ /^[a-z]+::([a-z]+(::[a-z]+)*('s)?)$/i)
      {
        my @row = ( 'module', "$filename", $comment->location->[0], $frag );
        $callback->(@row);
      }
      else
      {
        foreach my $word (split /\b{wb}/, $frag)
        {
          next unless $word =~ /\w/;
          my @row = ( 'word', "$filename", $comment->location->[0], $word );
          $callback->(@row);
        }
      }
    }
  }
  return $self;
}

1;


