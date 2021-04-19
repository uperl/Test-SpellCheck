package Test::SpellCheck::Plugin::PerlSplitter;

use strict;
use warnings;
use 5.026;
use Text::HumanComputerWords 0.02;
use List::Util 1.29 qw( pairmap );
use experimental qw( signatures );

# ABSTRACT: Test::SpellCheck plugin for checking spelling in Perl source
# VERSION

=head1 SYNOPSIS

In Perl:

 spell_check ['PerlSplitter'];

In L<spellcheck.ini>:

 [PerlSplitter]

=head1 DESCRIPTION

This provides the appropriate computer word specification to separate computer "words"
from Perl technical documentation.  Currently it essentially takes the defaults from
C<default_perl> method from L<Text::HumanComputerWords> and changes C<path_name> to
C<skip> since that isn't currently supported by L<Test::SpellCheck> core.

=head1 OPTIONS

None.

=head1 CONSTRUCTOR

=head2 new

 my $plugin = Test::SpellCheck::Plugin::PerlSplitter->new;

This creates a new instance of the plugin.

=cut

sub new ($class)
{
  bless {}, $class;
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
