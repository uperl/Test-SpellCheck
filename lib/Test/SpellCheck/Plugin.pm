package Test::SpellCheck::Plugin;

use strict;
use warnings;
use 5.026;

# ABSTRACT: Plugin documentation for Test::SpellCheck
# VERSION

=head1 AVAILABLE PLUGINS

=over 4

=item L<Test::SpellCheck::Plugin::Combo>

=item L<Test::SpellCheck::Plugin::Lang::EN::US>

=item L<Test::SpellCheck::Plugin::Perl>

=item L<Test::SpellCheck::Plugin::PerlPOD>

=item L<Test::SpellCheck::Plugin::PerlComment>

=back

=head1 PLUGIN AUTHORS

So you want to write a spell check plugin?  A spell check plugin is just a class.
The only requirement is that there be a C<new> constructor that can optionally take
arguments.  That's it.  All of the other methods documented below are optional.
If you do not implement them then L<Test::SpellCheck> won't use them.

=head2 new (constructor)

 sub new ($class, @args)
 {
   my $self = bless {
     ...
   }, $class;
 }

The constructor should just create a class.  The internal representation is entirely up to
you.  It does have to return an instance.  You may not return a class name and implement
the methods as class methods, even if you do not have any data to store in your class.

=head2 primary_dictionary

 sub primary_dictionary ($self)
 {
   ...
   return ($affix, $dic);
 }

This method returns the path to the primary dictionary and affix files to be used in the
test.  These files should be readable by L<Text::Hunspell::FFI>.  Only one plugin at a
time my define a primary dictionary, so if you are combining several plugins, make sure
that only one implements this method.

=head2 dictionary

 sub dictionary ($self)
 {
   ...
   return @dic;
 }

This method returns a list of one or more additional dictionaries.  These are useful
for jargon which doesn't belong in the main human language dictionary.

=head2 stream

 sub stream ($self, $filename, $callback)
 {
   ...
   $callback->( $type, $event_filename, $line_number, $text);
   ...
 }

The stream method parses the input file C<$filename> to find events.  For each event,
it calls the C<$callback> with exactly four values.  The C<$type> is one of the event
types listed below.  The C<$event_filename> is the filename the event was found in.  This
will often be the same as C<$filename>, but it could be other file if the source file
that you are reading supports including other source files.  The C<$line_number> is the
line that event was found at.  The C<$text> depends on the C<$type>.

=over 4

=item word

Regular human language word that should be checked for spelling C<$text> is the word.
If one or more words from this event type are misspelled then the L<Test::SpellCheck>
test will fail.

=item stopword

Word that should not be considered misspelled for the current C<$filename>.  This is often
for technical jargon which is spelled correctly but not in the regular human language
dictionary.

=item module

a module.  For Perl this will be of the form C<Foo::Bar>.  These are "words" that another
plugin might check, but they would do so against a module registry like CPAN or among
the locally installed modules.

=item url_link

A regular internet URL link.  Another plugin may check to make sure this does not
C<500> or C<404>.

=item pod_link

A link to a module.  For Perl this will be of the form C<Foo::Bar> or C<perldelta>.  Another
plugin may check to make sure this is a valid module.

=item error

An error happened while parsing the source file.  The error message will be in C<$text>.
If L<Test::SpellCheck> sees this event then it will fail the file.

=back

=head1 SEE ALSO

=over 4

=item L<Text::SpellCheck>

=back

=cut

1;
