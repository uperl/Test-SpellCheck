package Test::SpellCheck::Plugin::PerlPOD;

use strict;
use warnings;
use 5.026;
use Pod::Simple::Words;
use experimental qw( signatures );
use Ref::Util qw( is_plain_arrayref );

# ABSTRACT: Test::SpellCheck plugin for checking spelling in POD
# VERSION

=head1 OPTIONS

=head2 skip_sections

=head2 lang

=head1 CONSTRUCTOR

=head2 new

=cut

sub new ($class, %args)
{
  my $skip_sections;

  $DB::single = 1;
  if(defined $args{skip_sections})
  {
    $skip_sections = is_plain_arrayref $args{skip_sections} ? [$args{skip_sections}->@*] : [$args{skip_sections}];
  }
  else
  {
    $skip_sections = ['contributors', 'author', 'copyright and license'];
  }

  bless {
    skip_sections => $skip_sections,
  }, $class;
}

sub stream ($self, $filename, $callback)
{
  my $parser = Pod::Simple::Words->new;
  $parser->callback($callback);
  $DB::single = 1;
  $parser->skip_sections($self->{skip_sections}->@*);
  $parser->parse_file($filename);
  return $self;
}

1;


