package Test::SpellCheck::Plugin::Combo;

use strict;
use warnings;
use 5.026;
use Module::Load qw( load );
use Ref::Util qw( is_plain_arrayref is_blessed_ref is_ref );
use Carp qw( croak );
use experimental qw( signatures );

our @CARP_NOT = qw( Test::SpellCheck );

# ABSTRACT: Test::SpellCheck plugin for combining other plugins.
# VERSION

=head1 SYNOPSIS

From your test file:

 use Test2::V0;
 use Test::SpellCheck;
 
 spell_check
   ['Combo',
     ['Lang::EN::US'],
     ['PerlPOD', skip_sections => 'author'],
     ['PerlComment'],
   ],
 ;

From your C<spellcheck.ini> file:

 [Lang::EN::US]
 [PerlPOD]
 skip_sections = author
 [PerlComment]

=head1 DESCRIPTION

This plugin combines one or more other plugins.  This can be useful if you
want more fine grain control over how L<Test::SpellCheck> works.  If you specify
two or more plugins in your C<spellcheck.ini> then the combo plugin will
automatically be used to combine those plugins.

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

=head1 CONSTRUCTOR

=head2 new

 my $plugin = Test::SpellCheck::Plugin::Combo->new(@spec);

When creating a combo plugin from Perl, you pass in a list of plugin
instances or plugin specs.  Plugin specs are just an array reference
where the first element is the short name of the plugin, and the rest
of the elements are passed to the constructor.  Thus these are all
equivalent:

 my $plugin = Test::SpellCheck::Plugin::Combo->new(
   Test::SpellCheck::Plugin::PerlPOD->new(skip_sections => ['foo','bar']),
   Test::SpellCheck::Plugin::PerlComment->new,
 );
 
 my $plugin = Test::SpellCheck::Plugin::Combo->new(
   ['PerlPOD', skip_sections => ['foo','bar']],
   ['PerlComment'],
 );
 
 ; spellcheck.ini
 [PerlPOD]
 skip_section = foo
 skip_section = bar
 [PerlComment]

=cut

sub new ($class, @plugins)
{
  bless {
    plugins => [ map { _plugin($_) } @plugins ],
  }, $class;
}

sub can ($self, $name)
{
  if($name eq 'primary_dictionary')
  {
    foreach my $plugin ($self->{plugins}->@*)
    {
      my $maybe = $plugin->can($name);
      return $maybe if defined $maybe;
    }
    return undef;
  }
  else
  {
    return $self->SUPER::can($name);
  }
}

sub primary_dictionary ($self)
{
  foreach my $plugin ($self->{plugins}->@*)
  {
    # TODO: make sure we don't have more than one.
    return $plugin->primary_dictionary if $plugin->can('primary_dictionary');
  }
  croak "no primary dictionary for this combo";
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

sub stopwords ($self)
{
  my %words;
  foreach my $plugin ($self->{plugins}->@*)
  {
    if($plugin->can('stopwords'))
    {
      $words{$_} = 1 for $plugin->stopwords;
    }
  }
  return sort keys %words;
}

sub stream ($self, $filename, $splitter, $callback)
{
  foreach my $plugin ($self->{plugins}->@*)
  {
    $plugin->stream($filename, $splitter, $callback) if $plugin->can('stream');
  }
  return $self;
}

1;

=head1 SEE ALSO

=over 4

=item L<Test::SpellCheck>

=item L<Test::SpellCheck::Plugin>

=back

