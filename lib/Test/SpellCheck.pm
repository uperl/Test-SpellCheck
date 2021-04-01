package Test::SpellCheck;

use strict;
use warnings;
use 5.026;
use experimental qw( signatures );
use Ref::Util qw( is_ref is_blessed_ref is_plain_arrayref );
use File::Globstar qw( globstar );
use Test2::API qw( context );
use Text::Hunspell::FFI;
use Carp qw( croak );
use Module::Load qw( load );
use base qw( Exporter );

our @EXPORT = qw ( spell_check spell_check_ini );

# ABSTRACT: Check spelling of POD and other documents
# VERSION

=head1 SYNOPSIS

 use Test2::V0;
 
 spell_check 'lib/**/*.pm';
 
 done_testing;

=head1 DESCRIPTION

 # TODO

=head1 FUNCTIONS

=head2 spell_check

 spell_check \@plugin, $files, $test_name;
 spell_check $plugin, $files, $test_name;
 spell_check $files, $test_name;
 spell_check $files;
 spell_check;

The C<spell_check> function is configurable by passing a C<$plugin> instance or a plugin
config specified with C<\@plugin> (see more detail below).  By default C<spell_check> uses
L<Test::SpellCheck::Plugin::Perl>, which is usually reasonable for most Perl distributions.

The C<$file> argument is a string containing a space separated list of files, which can
be globbed using L<File::Globstar>.  The default is C<bin/* script/* lib/**/*.pm lib/**/*.pod>
should find public documentation for most Perl distributions.

The C<$test_name> is an optional test name for the test.

=head3 common recipes

=over 4

=item Check Perl code in a language other than English

 spell_check ['Perl', lang => 'de-de'];

Or in your C<spellcheck.ini> file:

 [Perl]
 lang = de-de

This would load the German language dictionary for Germany, which would mean loading
C<Test::SpellCheck::Plugin::DE::DE> (if it existed) instead of
L<Test::SPellCheck::Plugin::EN::US>.

=item Add stop words to just one file

 =for stopwords foo bar baz

Stopwords are words that shouldn't be considered misspelled.  You can specify these
in your POD using the standard C<stopwords> directive.  If you have a lot of stopwords
then you may want to use C<=begin> and C<=end> like so:

 =begin stopwords
 
 foo bar baz
 
 =end stopwords

Stopwords specified in this way are local to just the one file.

=item Add global stopwords for all files

 spell_check ['Combo', ['Perl'],['StopWords', word => ['foo','bar','baz']]];

Or in your C<spellcheck.ini>:

 [Perl]
 [StopWords]
 word = foo
 word = bar
 word = baz

The L<Test::SpellCheck::Plugin::StopWords> plugin adds stopwords for all documents
in your test, and is useful for jargon that is relevant to your entire distribution
and not just one file.  Contrast with a dist-level dictionary (see next item), which
allows you to use Hunspell's affix rules, and for Hunspell to suggest words that come
from the dist-level dictionary.

You can specify the stopwords inline as in the above examples, or use the C<file>
directive (or both as it happens) to store the stopwords in a separate file:

 spell_check ['Combo', ['Perl'], ['StopWords', file => 'foo.txt']];

Or in your C<spellcheck.ini>:

 [Perl]
 [StopWords]
 file = foo.txt

If you use this mode, then the stop words should be stored in the file one word per line.

=item Add a dist-level dictionary

 spell_check ['Combo', ['Perl'],['Dictionary', dictionary => 'spellcheck.dic']];

Or in C<spellcheck.ini>:

 [Perl]
 [Dictionary]
 dictionary = spellcheck.dic

The L<Test::SpellCheck::Plugin::Dictionary> plugin is for adding additional dictionaries,
which can be in arbitrary filesystem locations, including inside your Perl distribution.
The L<hunspell(5)> man page can provide detailed information about the format of this
file.  The advantage of maintaining your own dictionary file is that L<Test::SpellCheck>
can suggest words from your own dictionary.  You can also take advantage of the affix
codes for your language.

=item Don't spellcheck comments

 spell_check ['Perl', check_comments => 0];

Or in your C<spellcheck.ini> file:

 [Perl]
 check_comments = 0

By default this module checks the spelling of words in internal comments, since correctly
spelled comments is good.  If you prefer to only check the POD and not internal comments,
you can set C<check_comments> to a false value.

This module will still check comments in POD verbatim blocks, since those are visible in
the POD documentation.

=item Skip / don't skip POD sections

 # these two are the same:
 spell_check ['Perl'];
 spell_check ['Perl', skip_sections => ['contributors', 'author', 'copyright and license']];

By default this module skips the sections C<CONTRIBUTORS>, C<AUTHOR> and C<COPYRIGHT AND LICENSE>
since these are often generated automatically and can include a number of names that do
not appear in the human language dictionary.  If you prefer you can include these sections,
or skip a different subset of sections.

 spell_check ['Perl', skip_sections => []];
 spell_check ['Perl', skip_sections => ['contributors', 'see also']];

In your C<spellcheck.ini> file:

 [Perl]
 skip_sections =

or with different sections:

 [Perl]
 skip_sections = contributors
 skip_sections = see also

=back

=head3 plugin spec

You can specify a plugin using the array reference notation (C<\@plugin> from above).
The first element of this array is the short form of the plugin (that is without the
C<Test::SpellCheck::Plugin> prefix).  The rest of the elements are passed to the plugin
constructor.  Most of the time, when you are not using the default plugin you will want
to combine several plugins to get the right mix, which you can do with
L<Test::SpellCheck::Plugin::Combo>.  Each argument passed to the combo plugin is itself
an array reference which specifies a plugin.  For example the default plugin (without any options)
is basically this:

 spell_check
   ['Combo',
     ['Lang::EN::US'],
     ['PerlWords'],
     ['PerlPOD', skip_sections => ['contributors', 'author', 'copyright and license']],
     ['PerlComment'],
   ],
 ;

If you didn't want to check comments, and didn't want to skip any POD sections, then you
could explicitly use this:

 spell_check
   ['Combo',
     ['Lang::EN::US'],
     ['PerlWords'],
     ['PerlPOD', skip_sections => []],
   ],
 ;

A full list of common plugins, as well as documentation for writing your own plugins can be
found at L<Test::SpellCheck::Plugin>.

=cut

sub _default_file { 'bin/* script/* lib/**/*.pm lib/**/*.pod' }

sub spell_check
{
  my $plugin;
  my @diag;
  my @note;
  my $spell;

  if(defined $_[0] && is_blessed_ref $_[0])
  {
    $plugin = shift;
  }
  elsif(defined $_[0] && is_plain_arrayref $_[0])
  {
    my($class, @args) = shift->@*;
    $class = "Test::SpellCheck::Plugin::$class";
    load $class;
    $plugin = $class->new(@args);
  }
  else
  {
    require Test::SpellCheck::Plugin::Perl;
    $plugin = Test::SpellCheck::Plugin::Perl->new;
  }

  my @files = sort map { globstar $_ } split(/\s+/, shift // _default_file());
  my $test_name = shift // 'spell check';

  if($plugin->can('primary_dictionary'))
  {
    my($affix, $dic) = $plugin->primary_dictionary;
    $spell = Text::Hunspell::FFI->new($affix, $dic);
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
      $spell->add_dic($dic);
      push @note, "using dictionary file $dic";
    }
  }

  my %global;

  if($plugin->can('stopwords'))
  {
    $global{$_} = 1 for $plugin->stopwords;
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
          return if $global{$word};
          return if $stopwords{$word};
          return if $spell->check($word);
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
    my @suggestions = $spell->suggest($word);
    $diag .= "  maybe: @suggestions\n" if @suggestions;
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

=head2 spell_check_ini

 spell_check_ini $filename, $test_name;
 spell_check_ini $filename;
 spell_check_ini;

This test works like C<spell_check> above, but the configuration is stored
in an C<.ini> file (C<spellcheck.ini> by default).  In the main section
you can specify one or more C<file> fields (which can be globbed).  Then
each section specifies a plugin.  If you don't specify any plugins, then
the default plugin will be used.  This is roughly equivalent to the default:

 ; spellcheck.ini
 file = bin/*
 file = script/*
 file = lib/**/*.pm
 file = lib/**/*.pod
 
 [Perl]
 lang           = en-us
 check_comments = 1
 skip_sections  = contributors
 skip_sections  = author
 skip_sections  = copyright and license

The intent of putting the configuration is to separate the config from
the test file, which can be useful in situations where the test file
is generated, as is common when using L<Dist::Zilla>.

Note that if you have multiple plugins specified in your C<spellcheck.ini> file,
B<the order matters>.

=cut

sub spell_check_ini ($filename='spellcheck.ini', $test_name=undef)
{
  require Test::SpellCheck::INI;
  my @config = Test::SpellCheck::INI->read_file($filename)->@*;
  my $root = shift @config;
  shift @$root;
  $root = { @$root };
  my $file;
  if(defined $root->{file})
  {
    if(is_ref $root->{file})
    {
      $file = join(' ', $root->{file}->@*);
    }
    else
    {
      $file = $root->{file};
    }
  }
  else
  {
  }
  my @plugin;
  if(@config == 0)
  {
    # do nothing
  }
  elsif(@config == 1)
  {
    @plugin = @config;
  }
  else
  {
    @plugin = ([Combo => @config]);
  }
  my $ctx = context();
  my $ret = spell_check @plugin, $file, $test_name;
  $ctx->release;

  $ret;
}

1;

=head1 CAVEATS

I am (frankly) somewhat uneasy making US English the default language, and requiring
non-English and non-US based people explicitly download separate dictionaries.  However,
English is the most common documentation language for CPAN modules, and I happen to use US
English in my every-day and technical language, even though I am Australian (and American).
In the future I may make other language combinations available by default, or detect an
appropriate languages based on the locale.

=head1 SEE ALSO

=over 4

=item L<Test::SpellCheck::Plugin>

List of common plugins for this module, plus specification for writing your own
plugins.

=item L<Test::SpellCheck::Plugin::Perl>

The default plugin used by this module.

=item L<Text::Hunspell>

XS based bindings to the Hunspell spelling library.

=item L<Text::Hunspell::FFI>

FFI based bindings to the Hunspell spelling library.

=item L<Pod::Spell>

A formatter for spellchecking POD (used by L<Test::Spelling>

=item L<Pod::Wordlist>

A list of common jargon words used in Perl documentation.

=item L<Test::Spelling>

An older spellchecker for POD.

=back

=cut
