package Test::SpellCheck::Plugin::PerlWords;

use strict;
use warnings;
use 5.026;
use experimental qw( signatures );
use File::ShareDir::Dist qw( dist_share );
use Path::Tiny qw( path );
use Text::HumanComputerWords 0.02;
use List::Util 1.29 qw( pairmap );

# ABSTRACT: Test::SpellCheck plugin that adds Perl jargon words
# VERSION

=head1 SYNOPSIS

 spell_check ['PerlWords'];

Or from C<spellcheck.ini>:

 [PerlWords]

=head1 DESCRIPTION

This plugin adds a number of Perl jargon words like "autovivify" and C<gethostbyaddr>
as an additional dictionary.  This means they are potential suggestions as well as
not considered misspellings on their own.

This plugin also provides the appropriate computer word specification to separate
computer "words" from Perl technical documentation.  Currently it essentially takes
the defaults from C<default_perl> method from L<Text::HumanComputerWords> and
changes C<path_name> to C<skip> since that isn't currently supported by
L<Test::SpellCheck> core.

=head1 OPTIONS

None.

=head1 CONSTRUCTOR

=head2 new

 my $plugin = Test::SpellCheck::Plugin::PerlWords->new(%options);

This creates a new instance of the plugin.

=cut

sub new ($class)
{
  bless {
    root => path(dist_share('Test-SpellCheck'))
  }, $class;
}

sub dictionary ($self)
{
  return (
    map { $_->stringify } $self->{root}->child('perl.dic'),
  );
}

sub splitter ($self)
{
  pairmap { $a eq 'path_name' ? ('ignore', $b) : ($a,$b) } Text::HumanComputerWords->default_perl;
}

1;

=head1 SEE ALSO

=over 4

=item L<Test::SpellCheck>

=item L<Test::SpellCheck::Plugin>

=back
