package Test::SpellCheck::Plugin::Combo;

use strict;
use warnings;
use 5.026;
use Module::Load qw( load );
use Ref::Util qw( is_plain_arrayref is_blessed_ref is_ref );
use Carp qw( croak );
use experimental qw( signatures );

# ABSTRACT: Test::SpellCheck plugin for combining other plugins.
# VERSION

=head1 CONSTRUCTOR

=head2 new

=cut

sub _plugin ($spec)
{
  if(is_plain_arrayref $spec)
  {
    my($class, @args) = @$spec;
    $class = "Test::SpellCheck::Plugin::$class";
    load $class;
    return $class->new(@args);
  }
  elsif(is_blessed_ref $spec)
  {
    return $spec;
  }
  elsif(!is_ref $spec)
  {
    my $class = "Test::SpellCheck::Plugin::$spec";
    load $class;
    return $class->new;
  }
  else
  {
    croak "Unknown plugin type: @{[ ref $spec ]}";
  }
}

sub new ($class, @plugins)
{
  bless {
    plugins => [ map { _plugin($_) } @plugins ],
  }, $class;
}

sub primary_dictionary ($self)
{
  foreach my $plugin ($self->{plugins}->@*)
  {
    # TODO: make sure we don't have more than one.
    return $plugin->primary_dictionary if $plugin->can('primary_dictionary');
  }
}

sub dictionary ($self)
{
  my @dic;
  foreach my $plugin ($self->{plugins}->@*)
  {
    push @dic, $plugin->dictionary if $plugin->can('dictionary');
  }
  return @dic;
}

sub stream ($self, $filename, $callback)
{
  foreach my $plugin ($self->{plugins}->@*)
  {
    $plugin->stream($filename, $callback) if $plugin->can('stream');
  }
  return $self;
}

1;


