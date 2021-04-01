use 5.026;
use Test2::V0 -no_srand => 1;
use Test::SpellCheck::Plugin::Combo;

subtest 'basic' => sub {

  is(
    Test::SpellCheck::Plugin::Combo->new,
    object {
      call [ isa => 'Test::SpellCheck::Plugin::Combo' ] => T();
      call [ can => 'primary_dictionary' ] => F();
    },
  );

};

subtest 'basic' => sub {

  is(
    Test::SpellCheck::Plugin::Combo->new(['Lang::EN::US']),
    object {
      call [ isa => 'Test::SpellCheck::Plugin::Combo' ] => T();
      call [ can => 'primary_dictionary' ] => T();
    },
  );

};

done_testing;


