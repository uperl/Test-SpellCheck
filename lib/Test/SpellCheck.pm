package Test::SpellCheck;

use strict;
use warnings;
use 5.026;
use experimental qw( signatures );
use Ref::Util qw( is_ref is_blessed_ref );
use File::Globstar qw( globstar );
use Test2::API qw( context );
use Text::Hunspell::FFI;
use Carp qw( croak );
use base qw( Exporter );

our @EXPORT = qw ( spell_check );

# ABSTRACT: Check spelling of POD and other documents
# VERSION

=head1 FUNCTIONS

=head2 spell_check

 spell_check

=cut

sub spell_check
{
  my $plugin;
  my @files;
  my $test_name;
  my @note;
  my @diag;
  my $hs;

  if(defined $_[0] && is_blessed_ref $_[0])
  {
    $plugin = shift;
  }
  else
  {
    require Test::SpellCheck::Plugin::Perl;
    $plugin = Test::SpellCheck::Plugin::Perl->new;
  }

  if(defined $_[0] && !is_ref $_[0])
  {
    @files = sort map { globstar $_ } split /\s+/, shift;
  }
  else
  {
    @files = sort map { globstar $_ } split /\s+/, 'bin/* script/* lib/**/*.pm lib/**/*.pod';
  }

  if(defined $_[0] && !is_ref $_[0])
  {
    $test_name = shift;
  }
  else
  {
    $test_name = "spell check";
  }

  if($plugin->can('primary_dictionary'))
  {
    my($affix, $dic) = $plugin->primary_dictionary;
    $hs = Text::Hunspell::FFI->new($affix, $dic);
    push @note, "using affix file $affix";
    push @note, "using dictionary file $dic";
  }
  else
  {
    croak("plugin provides no primary dictionaries");
  }

  if($plugin->can('dictionary'))
  {
    foreach my $dic ($plugin->dictionary)
    {
      $hs->add_dic($dic);
      push @note, "using dictionary file $dic";
    }
  }

  my %bad_words;

  foreach my $file (@files)
  {
    my %stopwords;
    push @note, "check $file";
    $plugin->stream($file, sub ($type, $fn, $ln, $word) {
      if($type eq 'word')
      {
        foreach my $word (split /_/, $word)
        {
          return if $stopwords{$word};
          return if $hs->check($word);
          push $bad_words{$word}->@*, [$fn,$ln];
        }
      }
      elsif($type eq 'stopword')
      {
        $stopwords{$word} = 1;
      }
      elsif($type eq 'module')
      {
        # TODO
      }
      elsif($type eq 'url_link')
      {
        # TODO
      }
      elsif($type eq 'pod_link')
      {
        # TODO
      }
      elsif($type eq 'error')
      {
        push @diag, $word;
      }
    }) if $plugin->can('stream');
  }

  foreach my $word (keys %bad_words)
  {
    my $diag = "Misspelled: $word\n";
    my @suggestions = $hs->suggest($word);
    $diag .= "  maybe: @suggestions" if @suggestions;
    foreach my $loc ($bad_words{$word}->@*)
    {
      my($fn, $ln) = @$loc;
      $diag .= "  found at $fn line $ln.\n";
    }
    push @diag, $diag;
  }

  my $ctx = context();
  if(@diag)
  {
    $ctx->fail($test_name, @diag);
  }
  else
  {
    $ctx->pass($test_name);
  }
  $ctx->note($_) for @note;
  $ctx->release;

  return !scalar @diag;
}

1;


