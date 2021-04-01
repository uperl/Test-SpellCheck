package Test::SpellCheck::Plugin::PerlPOD;

use strict;
use warnings;
use 5.026;
use Pod::Simple::Words;
use experimental qw( signatures );
use Ref::Util qw( is_plain_arrayref );

# ABSTRACT: Test::SpellCheck plugin for checking spelling in POD
# VERSION

=head1 SYNOPSIS

 # these are the default options
 spell_check [PerlPOD, skip_sections => ['contributors', 'author', 'copyright and license']];

Or from C<spellcheck.ini>:

 [PerlPOD]
 skip_sections = contributors
 skip_sections = author
 skip_sections = copyright and license

=head1 DESCRIPTION

This plugin adds checking of POD for spelling errors.  It will also check for POD syntax errors.

=head1 OPTIONS

=head2 skip_sections

You can skip sections, which is typically useful for "author" or "copyright and license" sections,
since these are often generated and contain a number of names.

=head1 CONSTRUCTOR

=head2 new

 my $plugin = Test::SpellCheck::Plugin::PerlPOD->new(%options);

This creates a new instance of the plugin.  Any of the options documented above
can be passed into the constructor.

=cut

sub new ($class, %args)
{
  my $skip_sections;

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
  $parser->skip_sections($self->{skip_sections}->@*);
  $parser->parse_file($filename);
  return $self;
}

1;

=head1 SEE ALSO

=over 4

=item L<Test::SpellCheck>

=item L<Test::SpellCheck::Plugin>

=back
