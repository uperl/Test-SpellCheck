use 5.026;
use Test2::V0 -no_srand => 1;
use lib 't/lib';
use Test::SourceFile;
use Test::SpellCheck;
use File::chdir;

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

  spell_check_ini;

};

subtest 'ini' => sub {

  my @sc;
  my $mock = mock 'Test::SpellCheck' => (
    override => [
      spell_check => sub { @sc = @_ },
    ],
  );

  my $default = Test::SpellCheck::_default_file();

  subtest 'basic' => sub {

    my $file = file( 'spellcheck.ini' => <<~'INI' );
      INI

    {
      local $CWD = $file->parent;

      spell_check_ini;

      is
        \@sc,
        [
          undef,
          undef,
        ],
      ;
    }

    spell_check_ini $file;

    is
      \@sc,
      [
        undef,
        undef
      ],
    ;

    spell_check_ini $file, 'foo bar';

    is
      \@sc,
      [
        undef,
        'foo bar',
      ],
    ;
  };

  subtest '1 plugin' => sub {
    my $file = file( 'spellcheck.ini' => <<~'INI' );
      [Foo]
      bar = 1
      bar = 2
      baz = 3
      INI

    spell_check_ini $file;

    is
      \@sc,
      [
        ['Foo', bar => [1,2], baz => 3],
        undef,
        undef
      ],
    ;

  };

  subtest '2 plugin' => sub {
    my $file = file( 'spellcheck.ini' => <<~'INI' );
      [Foo]
      bar = 1
      bar = 2
      baz = 3
      [Xor]
      INI

    spell_check_ini $file;

    is
      \@sc,
      [
        ['Combo', ['Foo', bar => [1,2], baz => 3], ['Xor']],
        undef,
        undef
      ],
    ;

  };

  subtest 'scalar file' => sub {

    my $file = file( 'foo.ini' => <<~'INI' );
      file = lib/**/*.pm
      INI

    spell_check_ini $file;

    is
      \@sc,
      [
        'lib/**/*.pm',
        undef,
      ],
    ;

    spell_check_ini $file, 'my-test-name';

    is
      \@sc,
      [
        'lib/**/*.pm',
        'my-test-name',
      ],
    ;
  };

  subtest 'array file' => sub {

    my $file = file( 'foo.ini' => <<~'INI' );
      file = lib/**/*.pm
      file = lib/**/*.pod
      INI

    spell_check_ini $file;

    is
      \@sc,
      [
        'lib/**/*.pm lib/**/*.pod',
        undef,
      ],
    ;

    spell_check_ini $file, 'my-test-name-2';

    is
      \@sc,
      [
        'lib/**/*.pm lib/**/*.pod',
        'my-test-name-2',
      ],
    ;

  };

};

done_testing;
