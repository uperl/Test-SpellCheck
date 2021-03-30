use 5.026;
use utf8;
use Test2::V0 -no_srand => 1;
use experimental qw( signatures );
use lib 't/lib';
use Path::Tiny qw( path );
use Test::SourceFile;
use Test::SpellCheck::Plugin::PerlPOD;
use YAML qw( Dump );

subtest 'basic' => sub {

  my $plugin = Test::SpellCheck::Plugin::PerlPOD->new;
  isa_ok 'Test::SpellCheck::Plugin::PerlPOD';

  my $file = file( 'Foo.pod' => <<~'PERL' );
    =head1 DESCRIPTION

    one

     say "Hello World!";  # two
     exit                 # three

    four

    =cut
    PERL

  my %words;

  $plugin->stream("$file", sub ($type, $fn, $ln, $word) {
    return unless $type eq 'word';
    push $words{$word}->@*, [path($fn)->basename,$ln];
  });

  is
    \%words,
    {
      description => [['Foo.pod', 1]],
      one         => [['Foo.pod', 3]],
      two         => [['Foo.pod', 5]],
      three       => [['Foo.pod', 6]],
      four        => [['Foo.pod', 8]],
    },
  or diag Dump(\%words);

};

subtest 'ignore Perl' => sub {

  my $plugin = Test::SpellCheck::Plugin::PerlPOD->new;
  isa_ok 'Test::SpellCheck::Plugin::PerlPOD';

  my $file = file( 'Foo.pm' => <<~'PERL' );
    #!/usr/bin/perl

    say "Hello World"; # foo bar baz

    =head1 DESCRIPTION

    one

     say "Hello World!";  # two
     exit                 # three

    four

    =cut

    exit;              # and some more
    PERL

  my %words;

  $plugin->stream("$file", sub ($type, $fn, $ln, $word) {
    return unless $type eq 'word';
    push $words{$word}->@*, [path($fn)->basename,$ln];
  });

  is
    \%words,
    {
      description => [['Foo.pm', 5]],
      one         => [['Foo.pm', 7]],
      two         => [['Foo.pm', 9]],
      three       => [['Foo.pm', 10]],
      four        => [['Foo.pm', 12]],
    },
  or diag Dump(\%words);

};

done_testing;
