use  Test2::V0 -no_srand => 1;
use 5.026;
use Test::SpellCheck::Plugin::PerlWords;
use Path::Tiny qw( path );

my $plugin = Test::SpellCheck::Plugin::PerlWords->new;
isa_ok $plugin, 'Test::SpellCheck::Plugin::PerlWords';

my @files = $plugin->dictionary;

note "files[]=$_" for @files;

is ref $files[0], '';

@files = map { path($_) } @files;

is
  \@files,
  array {
    item object {
      call sub { -f $_[0] } => T();
    };
    end;
  },
;

done_testing;
