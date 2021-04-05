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
      elsif($frag =~ /^[a-z]+:\/\//i
      || $frag =~ /^(file|ftps?|gopher|https?|ldapi|ldaps|mailto|mms|news|nntp|nntps|pop|rlogin|rtsp|sftp|snew|ssh|telnet|tn3270|urn|wss?):\S/i)
      {
        my @row = ( 'url_link', "$filename", $comment->location->[0], [ undef, undef ] );
        my $url = URI->new($frag);
        if(defined $url->fragment)
        {
          $row[3]->[1] = $url->fragment;
          $url->fragment(undef);
        }
        $row[3]->[0] = "$url";
        $callback->(@row);
      }
      elsif($frag =~ m{^/(usr|home|opt|)/}
      ||    $frag =~ m{^[a-z]:[\\/]}
      ||    $frag =~ m{\.(html|pl|pm|pod|c|h|py|tar|gz|xz|zip|bz2)})
      {
        # ignore things that look like unix or windows paths or filenames
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

=head1 SEE ALSO

=over 4

=item L<Test::SpellCheck>

=item L<Test::SpellCheck::Plugin>

=back
