package Test::SpellCheck::Plugin::PerlComment;

use strict;
use warnings;
use 5.026;
use PPI;
use URI;
use experimental qw( signatures );

# ABSTRACT: Test::SpellCheck plugin for checking spelling in Perl comments
# VERSION

=head1 SYNOPSIS

 spell_check ['PerlComments'];

Or from C<spellcheck.ini>:

 [PerlComments]

=head1 DESCRIPTION

This plugin adds checking of Perl comments.

=head1 OPTIONS

None.

=head1 CONSTRUCTOR

=head2 new

 my $plugin = Test::SpellCheck::Plugin::PerlComment->new;

This creates a new instance of the plugin.

=cut

sub new ($class)
{
  bless {}, $class;
}

sub stream ($self, $filename, $splitter, $callback)
{
  my $doc = PPI::Document->new($filename);
  foreach my $comment (($doc->find('PPI::Token::Comment') || [])->@*)
  {
    next if $comment->location->[0] == 1 &&
            "$comment" =~ /^#!/;
    foreach my $event ($splitter->split("$comment"))
    {
      my($type, $word) = @$event;
      my @row = ( $type, "$filename", $comment->location->[0], $word );
      $callback->(@row);
    }
  }
  return $self;
}

1;

=head1 SEE ALSO

=over 4

=item L<Test::SpellCheck>

=item L<Test::SpellCheck::Plugin>

=back
