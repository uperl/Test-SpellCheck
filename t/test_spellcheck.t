use 5.026;
use Test2::V0 -no_srand => 1;
use lib 't/lib';
use Test::SourceFile;
use Test::SpellCheck;

subtest 'basic pass' => sub {

  my $file = file( 'Foo.pm' => <<~'PERL' );
    say "hello world\n";  # a comment

    =head1 DESCRIPTION

    The quick brown fox jumps over the lazy dog.

    =cut
    PERL

  spell_check "$file";

};

subtest 'basic fail' => sub {

  my $file = file( 'Foo.pm' => <<~'PERL' );
    say "hello world\n";  # brosgjk

    =head1 DESCRIPTION

    gdkjlfg gfkdlgd gkldfgkld gdfkjgdf

    =cut
    PERL

  is
    intercept { spell_check "$file" },
    array {
      event 'Fail' => sub {};
      etc;
    },
  ;

};

subtest 'self' => sub {

  spell_check;

};

done_testing;


