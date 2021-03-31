use 5.026;
use Test2::V0 -no_srand => 1;
use Test::SpellCheck::Plugin::Combo;

subtest 'basic' => sub {

  my $plugin = Test::SpellCheck::Plugin::Combo->new;
  isa_ok 'Test::SpellCheck::Plugin::Combo';

};

done_testing;


