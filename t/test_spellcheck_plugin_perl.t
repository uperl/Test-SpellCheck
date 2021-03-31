use 5.026;
use Test2::V0 -no_srand => 1;
use experimental qw( signatures );
use lib 't/lib';
use Path::Tiny qw( path );
use Test::SourceFile;
use Test::SpellCheck::Plugin::Perl;
use YAML qw( Dump );

subtest 'combo' => sub {

  my $plugin = Test::SpellCheck::Plugin::Perl->new;
  isa_ok 'Test::SpellCheck::Plugin::Perl';

  my $file = file( 'Foo.pm' => <<~'PERL' );
    #!/usr/bin/perl

    say "Hello World"; # one

    =head1 DESCRIPTION

    two

     say "Hello World!";  # three
     exit                 # four

    five

    =cut

    exit;              # six
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
      one         => [['Foo.pm', 3]],
      two         => [['Foo.pm', 7]],
      three       => [['Foo.pm', 9]],
      four        => [['Foo.pm', 10]],
      five        => [['Foo.pm', 12]],
      six         => [['Foo.pm', 16]],
    },
  or diag Dump(\%words);

};

subtest 'skip-section' => sub {

  my $plugin = Test::SpellCheck::Plugin::Perl->new(
    skip_sections => ['skip1'],
  );

  my $file = file( 'Foo.pm' => <<~'PERL' );
    #!/usr/bin/perl

    say "Hello World"; # one

    =head1 DESCRIPTION

    two

     say "Hello World!";  # three
     exit                 # four

    =head1 SKIP1

    foo bar baz

    =head1 DESCRIPTION

    five

    =cut

    exit;              # six
    PERL

  my %words;

  $plugin->stream("$file", sub ($type, $fn, $ln, $word) {
    return unless $type eq 'word';
    push $words{$word}->@*, [path($fn)->basename,$ln];
  });

  is
    \%words,
    {
      description => [['Foo.pm', 5],['Foo.pm',16]],
      skip1       => [['Foo.pm', 12]],
      one         => [['Foo.pm', 3]],
      two         => [['Foo.pm', 7]],
      three       => [['Foo.pm', 9]],
      four        => [['Foo.pm', 10]],
      five        => [['Foo.pm', 18]],
      six         => [['Foo.pm', 22]],
    },
  or diag Dump(\%words);

};

done_testing;


