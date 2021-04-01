use 5.026;
use Test2::V0 -no_srand => 1;
use experimental qw( signatures );
use lib 't/lib';
use Test::SourceFile;
use Test::SpellCheck;
use File::chdir;

local $Test::SpellCheck::VERBOSE = 1;

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

  local $Test::SpellCheck::VERBOSE = 0;

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

subtest 'global-stopwords' => sub {

  spell_check ['Combo',
    ['PrimaryDictionary', affix => 'corpus/foo.afx', dictionary => 'corpus/foo.dic' ],
    ['StopWords', word => 'foo'],
    ['TestSource', events => [['word',1,'foo']]],
  ], 'lib/Test/SpellCheck.pm';

};

subtest 'no-primary-dictionary' => sub {

  local $@ = '';
  eval { spell_check ['Combo'] };
  like "$@", qr/^plugin provides no primary dictionaries/;

};

subtest 'good-word only' => sub {
  local $Test::SpellCheck::VERBOSE = 0;

  my $mock = mock 'Text::Hunspell::FFI' => (
    override => [
      check => sub ($self, $word) {
        return 1;
      },
    ],
  );

  is
    intercept {
      spell_check ['Combo',
        ['PrimaryDictionary', affix => 'corpus/foo.afx', dictionary => 'corpus/foo.dic' ],
        ['TestSource', events => [
          ['word',1,'foo'],
          ['word',2,'bar'],
          ['word',3,'baz'],
        ]],
      ], 'lib/Test/SpellCheck.pm';
    },
    array {
      event Pass => sub {
        call name => 'spell check';
      };
      end;
    },
  ;

  is
    intercept {
      spell_check ['Combo',
        ['PrimaryDictionary', affix => 'corpus/foo.afx', dictionary => 'corpus/foo.dic' ],
        ['TestSource', events => [
          ['word',1,'foo'],
          ['word',2,'bar'],
          ['word',3,'baz'],
        ]],
      ], 'lib/Test/SpellCheck.pm', 'alt-name';
    },
    array {
      event Pass => sub {
        call name => 'alt-name';
      };
      end;
    },
  ;

};

subtest 'bad-word / error' => sub {

  local $Test::SpellCheck::VERBOSE = 0;

  my $mock = mock 'Text::Hunspell::FFI' => (
    override => [
      check => sub ($self, $word) {
        return $word eq 'bar' || $word eq 'other' ? 0 : 1;
      },
      suggest => sub ($self, $word) {
        return $word eq 'bar' ? ('xx','yy') : ();
      },
    ],
  );

  is
    intercept {
      spell_check ['Combo',
        ['PrimaryDictionary', affix => 'corpus/foo.afx', dictionary => 'corpus/foo.dic' ],
        ['TestSource', events => [
          ['word',1,'foo'],
          ['word',2,'bar'],
          ['word',3,'baz'],
        ]],
      ], 'lib/Test/SpellCheck.pm';
    },
    array {
      event Fail => sub {
        call name => 'spell check';
        call info => [
          object {
            call details => "Misspelled: bar\n  maybe: xx yy\n  found at lib/Test/SpellCheck.pm line 2.\n";
          }
        ];
      };
      end;
    },
  ;

  is
    intercept {
      spell_check ['Combo',
        ['PrimaryDictionary', affix => 'corpus/foo.afx', dictionary => 'corpus/foo.dic' ],
        ['TestSource', events => [
          ['word',1,'foo'],
          ['word',2,'bar'],
          ['word',3,'baz'],
          ['word',100, 'bar'],
          ['word',105, 'bar'],
        ]],
      ], 'lib/Test/SpellCheck.pm', 'another test name';
    },
    array {
      event Fail => sub {
        call name => 'another test name';
        call info => [
          object {
            call details => "Misspelled: bar\n  maybe: xx yy\n  found at lib/Test/SpellCheck.pm line 2.\n  found at lib/Test/SpellCheck.pm line 100.\n  found at lib/Test/SpellCheck.pm line 105.\n";
          }
        ];
      };
      end;
    },
  ;

  is
    intercept {
      spell_check ['Combo',
        ['PrimaryDictionary', affix => 'corpus/foo.afx', dictionary => 'corpus/foo.dic' ],
        ['TestSource', events => [
          ['word',1,'foo'],
          ['word',2,'bar'],
          ['word',3,'baz'],
          ['word',10,'other'],
          ['word',100, 'bar'],
          ['word',105, 'bar'],
        ]],
      ], 'lib/Test/SpellCheck.pm';
    },
    array {
      event Fail => sub {
        call info => [
          object {
            call details => "Misspelled: bar\n  maybe: xx yy\n  found at lib/Test/SpellCheck.pm line 2.\n  found at lib/Test/SpellCheck.pm line 100.\n  found at lib/Test/SpellCheck.pm line 105.\n";
          },
          object {
            call details => "Misspelled: other\n  found at lib/Test/SpellCheck.pm line 10.\n";
          },
        ];
      };
      end;
    },
  ;

  is
    intercept {
      spell_check ['Combo',
        ['PrimaryDictionary', affix => 'corpus/foo.afx', dictionary => 'corpus/foo.dic' ],
        ['TestSource', events => [
          ['word',1,'foo'],
          ['word',2,'bar'],
          ['word',3,'baz'],
          ['error',22,'an error here'],
          ['word',10,'other'],
          ['word',100, 'bar'],
          ['word',105, 'bar'],
        ]],
      ], 'lib/Test/SpellCheck.pm';
    },
    array {
      event Fail => sub {
        call info => [
          object {
            call details => "an error here";
          },
          object {
            call details => "Misspelled: bar\n  maybe: xx yy\n  found at lib/Test/SpellCheck.pm line 2.\n  found at lib/Test/SpellCheck.pm line 100.\n  found at lib/Test/SpellCheck.pm line 105.\n";
          },
          object {
            call details => "Misspelled: other\n  found at lib/Test/SpellCheck.pm line 10.\n";
          },
        ];
      };
      end;
    },
  ;

  is
    intercept {
      spell_check ['Combo',
        ['PrimaryDictionary', affix => 'corpus/foo.afx', dictionary => 'corpus/foo.dic' ],
        ['TestSource', events => [
          ['error',22,'an error here'],
        ]],
      ], 'lib/Test/SpellCheck.pm';
    },
    array {
      event Fail => sub {
        call info => [
          object {
            call details => "an error here";
          },
        ];
      };
      end;
    },
  ;

};

done_testing;
