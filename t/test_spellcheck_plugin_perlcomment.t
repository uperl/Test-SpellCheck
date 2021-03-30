use 5.026;
use utf8;
use Test2::V0 -no_srand => 1;
use experimental qw( signatures );
use lib 't/lib';
use Path::Tiny qw( path );
use Test::SourceFile;
use Test::SpellCheck::Plugin::PerlComment;
use YAML qw( Dump );

subtest 'basic' => sub {

  my $plugin = Test::SpellCheck::Plugin::PerlComment->new;
  isa_ok 'Test::SpellCheck::Plugin::PerlComment';

  my $file = file( 'Foo.pm' => <<~'PERL' );
    #!/usr/bin/perl

    say "Hello World"; # one
    exit;              # two
    PERL

  my %words;

  $plugin->stream("$file", sub ($type, $fn, $ln, $word) {
    return unless $type eq 'word';
    push $words{$word}->@*, [path($fn)->basename,$ln];
  });

  is
    \%words,
    {
      one => [['Foo.pm', 3]],
      two => [['Foo.pm', 4]],
    },
  or diag Dump(\%words);

};

subtest 'ignore POD' => sub {

  my $plugin = Test::SpellCheck::Plugin::PerlComment->new;
  isa_ok 'Test::SpellCheck::Plugin::PerlComment';

  my $file = file( 'Foo.pm' => <<~'PERL' );
    #!/usr/bin/perl

    say "Hello World"; # one

    =head1 DESCRIPTION

    foo baar baz

     say "Hello World!";  #  three
     exit                 # four

    and some more

    =cut

    exit;              # two
    PERL

  my %words;

  $plugin->stream("$file", sub ($type, $fn, $ln, $word) {
    return unless $type eq 'word';
    push $words{$word}->@*, [path($fn)->basename,$ln];
  });

  is
    \%words,
    {
      one => [['Foo.pm', 3]],
      two => [['Foo.pm', 16]],
    },
  or diag Dump(\%words);

};

done_testing;
