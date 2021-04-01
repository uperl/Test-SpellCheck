package Test::SpellCheck::INI;

use strict;
use warnings;
use 5.026;
use experimental qw( signatures );
use base qw( Config::INI::Reader );

# ABSTRACT: INI Parser for Test::SpellCheck
# VERSION

=head1 DESCRIPTION

This class is private to L<Test::SpellCheck>.

=head1 SEE ALSO

=over 4

=item L<Test::SpellCheck>

=back

=cut

sub new ($class)
{
  my $self = $class->SUPER::new;
  $self->{data} = [[undef,{}]];
  return $self;
}

sub change_section ($self, $name)
{
  push $self->{data}->@*, [$name,{}];
}

sub set_value ($self, $name, $value)
{
  my $h = $self->{data}->[-1]->[1];
  if(exists $h->{$name})
  {
    if(ref $h->{$name} eq 'ARRAY')
    {
      push $h->{$name}->@*, $value;
    }
    else
    {
      $h->{$name} = [ $h->{$name}, $value ];
    }
  }
  else
  {
    $h->{$name} = $value;
  }
}

sub finalize ($self)
{
  foreach my $array ($self->{data}->@*)
  {
    my $hash = pop $array->@*;
    foreach my $key (sort keys %$hash)
    {
      my $value = $hash->{$key};
      push $array->@*, $key => $value;
    }
  }
}

1;
