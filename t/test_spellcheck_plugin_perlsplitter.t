use Test2::V0 -no_srand => 1;
use Test::SpellCheck::Plugin::PerlSplitter;
use List::Util 1.29 qw( pairs );
use 5.026;

subtest 'basic' => sub {

  my $plugin = Test::SpellCheck::Plugin::PerlSplitter->new;
  isa_ok $plugin, 'Test::SpellCheck::Plugin::PerlSplitter';

  is
    [pairs( $plugin->splitter )],
    array {
      # has at least one element
      item D();

      # none of the types are path_name,
      # since we do not support that in core
      all_items array {
        item !string('path_name');
        item D();
      };
      etc;
    },
  ;


};

done_testing;
