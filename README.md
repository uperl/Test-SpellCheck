# Test::SpellCheck ![linux](https://github.com/uperl/Test-SpellCheck/workflows/linux/badge.svg) ![windows](https://github.com/uperl/Test-SpellCheck/workflows/windows/badge.svg) ![macos](https://github.com/uperl/Test-SpellCheck/workflows/macos/badge.svg) ![cygwin](https://github.com/uperl/Test-SpellCheck/workflows/cygwin/badge.svg) ![msys2-mingw](https://github.com/uperl/Test-SpellCheck/workflows/msys2-mingw/badge.svg)

Check spelling of POD and other documents

# SYNOPSIS

```perl
use Test2::V0;

spell_check 'lib/**/*.pm';

done_testing;
```

# DESCRIPTION

This module is for checking the spelling of program language documentation.  It has built
in support for Perl (naturally), but provides a plugin API system which should allow it to
support other languages in the future.  It uses Hunspell at its core.

But why, you ask, when [Test::Spelling](https://metacpan.org/pod/Test::Spelling) exists?  Here briefly are some advantages and
disadvantages of this project relative to the older tester.

- "One true" spelling library and dictionary

    [Test::Spelling](https://metacpan.org/pod/Test::Spelling) is quite flexible in the spell checker that it uses under the covers,
    which is admirable in that it will work out of the box in a lot of places as long as there
    is a spell checker available.  However this makes it less reliable and consistent.
    This module instead always uses Hunspell (via [Alien::Hunspell](https://metacpan.org/pod/Alien::Hunspell) and [Text::Hunspell::FFI](https://metacpan.org/pod/Text::Hunspell::FFI)),
    and it has a default human language dictionary (which is configurable).  This makes
    it easier to rely on the results of this module, and it means you don't have to add
    stopwords for multiple spell checkers if you develop on multiple platforms with
    different checkers.  The disadvantage of all this is that the install process can be
    longer because it will build Hunspell if you don't have it installed, and it won't use
    the system human language dictionaries.

- More accurate word splitting

    We get this from [Pod::Simple::Words](https://metacpan.org/pod/Pod::Simple::Words), which uses `\b{wb}` to split words instead of
    `\b`.  This does also mean that Perls older than 5.22 will never be supported by
    this module or by [Pod::Simple::Words](https://metacpan.org/pod/Pod::Simple::Words), which could be construed as either an advantage
    or disadvantage depending on your deprecation politics.

- Doesn't have to be for Perl only

    The initial implementation is for Perl only, but the [plugin](https://metacpan.org/pod/Test::SpellCheck::Plugin)
    architecture is designed to be usable for other languages and technologies.

- Makes suggestions

    This module will suggest corrections to words that it finds are misspelled.

- Groups misspelled

    If the same misspelling exists in multiple locations, it will be reported once for
    each word, along with each location, including the line number.  I find this easier
    to manage when making corrections, especially if the appropriate action is to update
    a dist-level dictionary or add a stopword.

- Can leverage Hunspell tech

    You can write your own Hunspell dictionaries, which allows you to use their affix rules
    and for [Test::SpellCheck](https://metacpan.org/pod/Test::SpellCheck) to suggest words from your dictionaries.

- Checks Perl comments

    This module will check the spelling of Perl comments in POD verbatim blocks, and private
    comments inside your scripts and modules.  (The latter can be be turned off, if you
    prefer not to check private comments).  My feeling is that these are both documentation
    and it can be embarrassing and or confusing to have spelling errors in comments.

    There does exist [Test::Spelling::Comment](https://metacpan.org/pod/Test::Spelling::Comment), but if you want to check both POD and
    comments that it two separate checks.  I think it should be one.

- Configurable from a .ini file

    The default plugin for this module is usually reasonable for checking Perl documentation,
    but if you prefer a more customized approach you can put your configuration in a
    file, by default called `spellcheck.ini`, which allows you to separate the configuration
    from the test file.

- Uses new Hunspell format jargon list for Perl

    I elected to not use [Pod::Wordlist](https://metacpan.org/pod/Pod::Wordlist) as a default jargon list for Perl code, because
    I wanted to take advantage of the more sophisticated Hunspell affix system.  In the
    long run, I think this will eventually produce better results, but in the short term
    this modules default Perl jargon dictionary is not as complete (and also probably
    has fewer false positives) as [Pod::Wordlist](https://metacpan.org/pod/Pod::Wordlist).  It would be trivial to write a plugin
    for this module to use [Pod::Wordlist](https://metacpan.org/pod/Pod::Wordlist) if you prefer that list of stopwords though.

- Works out of the box on Strawberry and most other platforms

    [Test::Spelling](https://metacpan.org/pod/Test::Spelling) will install if it can't find a spell checker, but it won't be of
    much use if it can't actually check the spelling of words.  Because of powerful
    [Alien](https://metacpan.org/pod/Alien) and [Platypus](https://metacpan.org/pod/FFI::Platypus) technologies this module can more reliably
    install and be useful on more platforms.

The TL;DR is that I am a terrible speller and I prefer a more consistent spell checker, and
this module fixes a number of frustrations I've had with [Test::Spelling](https://metacpan.org/pod/Test::Spelling) over the years.

# FUNCTIONS

## spell\_check

```
spell_check \@plugin, $files, $test_name;
spell_check $plugin, $files, $test_name;
spell_check $files, $test_name;
spell_check $files;
spell_check;
```

The `spell_check` function is configurable by passing a `$plugin` instance or a plugin
config specified with `\@plugin` (see more detail below).  By default `spell_check` uses
[Test::SpellCheck::Plugin::Perl](https://metacpan.org/pod/Test::SpellCheck::Plugin::Perl), which is usually reasonable for most Perl distributions.

The `$file` argument is a string containing a space separated list of files, which can
be globbed using [File::Globstar](https://metacpan.org/pod/File::Globstar).  The default is `bin/* script/* lib/**/*.pm lib/**/*.pod`
should find public documentation for most Perl distributions.

The `$test_name` is an optional test name for the test.

### common recipes

- Check Perl code in a language other than English

    ```perl
    spell_check ['Perl', lang => 'de-de'];
    ```

    Or in your `spellcheck.ini` file:

    ```
    [Perl]
    lang = de-de
    ```

    This would load the German language dictionary for Germany, which would mean loading
    `Test::SpellCheck::Plugin::DE::DE` (if it existed) instead of
    [Test::SPellCheck::Plugin::EN::US](https://metacpan.org/pod/Test::SPellCheck::Plugin::EN::US).

- Add stop words to just one file

    ```
    =for stopwords foo bar baz
    ```

    Stopwords are words that shouldn't be considered misspelled.  You can specify these
    in your POD using the standard `stopwords` directive.  If you have a lot of stopwords
    then you may want to use `=begin` and `=end` like so:

    ```
    =begin stopwords

    foo bar baz

    =end stopwords
    ```

    Stopwords specified in this way are local to just the one file.

- Add global stopwords for all files

    ```perl
    spell_check ['Combo', ['Perl'],['StopWords', word => ['foo','bar','baz']]];
    ```

    Or in your `spellcheck.ini`:

    ```
    [Perl]
    [StopWords]
    word = foo
    word = bar
    word = baz
    ```

    The [Test::SpellCheck::Plugin::StopWords](https://metacpan.org/pod/Test::SpellCheck::Plugin::StopWords) plugin adds stopwords for all documents
    in your test, and is useful for jargon that is relevant to your entire distribution
    and not just one file.  Contrast with a dist-level dictionary (see next item), which
    allows you to use Hunspell's affix rules, and for Hunspell to suggest words that come
    from the dist-level dictionary.

    You can specify the stopwords inline as in the above examples, or use the `file`
    directive (or both as it happens) to store the stopwords in a separate file:

    ```perl
    spell_check ['Combo', ['Perl'], ['StopWords', file => 'foo.txt']];
    ```

    Or in your `spellcheck.ini`:

    ```
    [Perl]
    [StopWords]
    file = foo.txt
    ```

    If you use this mode, then the stop words should be stored in the file one word per line.

- Add a dist-level dictionary

    ```perl
    spell_check ['Combo', ['Perl'],['Dictionary', dictionary => 'spellcheck.dic']];
    ```

    Or in `spellcheck.ini`:

    ```
    [Perl]
    [Dictionary]
    dictionary = spellcheck.dic
    ```

    The [Test::SpellCheck::Plugin::Dictionary](https://metacpan.org/pod/Test::SpellCheck::Plugin::Dictionary) plugin is for adding additional dictionaries,
    which can be in arbitrary filesystem locations, including inside your Perl distribution.
    The [hunspell(5)](http://man.he.net/man5/hunspell) man page can provide detailed information about the format of this
    file.  The advantage of maintaining your own dictionary file is that [Test::SpellCheck](https://metacpan.org/pod/Test::SpellCheck)
    can suggest words from your own dictionary.  You can also take advantage of the affix
    codes for your language.

- Don't spellcheck comments

    ```perl
    spell_check ['Perl', check_comments => 0];
    ```

    Or in your `spellcheck.ini` file:

    ```
    [Perl]
    check_comments = 0
    ```

    By default this module checks the spelling of words in internal comments, since correctly
    spelled comments is good.  If you prefer to only check the POD and not internal comments,
    you can set `check_comments` to a false value.

    This module will still check comments in POD verbatim blocks, since those are visible in
    the POD documentation.

- Skip / don't skip POD sections

    ```perl
    # these two are the same:
    spell_check ['Perl'];
    spell_check ['Perl', skip_sections => ['contributors', 'author', 'copyright and license']];
    ```

    By default this module skips the sections `CONTRIBUTORS`, `AUTHOR` and `COPYRIGHT AND LICENSE`
    since these are often generated automatically and can include a number of names that do
    not appear in the human language dictionary.  If you prefer you can include these sections,
    or skip a different subset of sections.

    ```perl
    spell_check ['Perl', skip_sections => []];
    spell_check ['Perl', skip_sections => ['contributors', 'see also']];
    ```

    In your `spellcheck.ini` file:

    ```
    [Perl]
    skip_sections =
    ```

    or with different sections:

    ```
    [Perl]
    skip_sections = contributors
    skip_sections = see also
    ```

### plugin spec

You can specify a plugin using the array reference notation (`\@plugin` from above).
The first element of this array is the short form of the plugin (that is without the
`Test::SpellCheck::Plugin` prefix).  The rest of the elements are passed to the plugin
constructor.  Most of the time, when you are not using the default plugin you will want
to combine several plugins to get the right mix, which you can do with
[Test::SpellCheck::Plugin::Combo](https://metacpan.org/pod/Test::SpellCheck::Plugin::Combo).  Each argument passed to the combo plugin is itself
an array reference which specifies a plugin.  For example the default plugin (without any options)
is basically this:

```perl
spell_check
  ['Combo',
    ['Lang::EN::US'],
    ['PerlWords'],
    ['PerlPOD', skip_sections => ['contributors', 'author', 'copyright and license']],
    ['PerlComment'],
  ],
;
```

If you didn't want to check comments, and didn't want to skip any POD sections, then you
could explicitly use this:

```perl
spell_check
  ['Combo',
    ['Lang::EN::US'],
    ['PerlWords'],
    ['PerlPOD', skip_sections => []],
  ],
;
```

A full list of common plugins, as well as documentation for writing your own plugins can be
found at [Test::SpellCheck::Plugin](https://metacpan.org/pod/Test::SpellCheck::Plugin).

## spell\_check\_ini

```
spell_check_ini $filename, $test_name;
spell_check_ini $filename;
spell_check_ini;
```

This test works like `spell_check` above, but the configuration is stored
in an `.ini` file (`spellcheck.ini` by default).  In the main section
you can specify one or more `file` fields (which can be globbed).  Then
each section specifies a plugin.  If you don't specify any plugins, then
the default plugin will be used.  This is roughly equivalent to the default:

```
; spellcheck.ini
file = bin/*
file = script/*
file = lib/**/*.pm
file = lib/**/*.pod

[Perl]
lang           = en-us
check_comments = 1
skip_sections  = contributors
skip_sections  = author
skip_sections  = copyright and license
```

The intent of putting the configuration is to separate the config from
the test file, which can be useful in situations where the test file
is generated, as is common when using [Dist::Zilla](https://metacpan.org/pod/Dist::Zilla).

Note that if you have multiple plugins specified in your `spellcheck.ini` file,
**the order matters**.

# CAVEATS

I am (frankly) somewhat uneasy making US English the default language, and requiring
non-English and non-US based people explicitly download separate dictionaries.  However,
English is the most common documentation language for CPAN modules, and I happen to use US
English in my every-day and technical language, even though I am Australian (and American).
In the future I may make other language combinations available by default, or detect an
appropriate languages based on the locale.

# SEE ALSO

- [Test::SpellCheck::Plugin](https://metacpan.org/pod/Test::SpellCheck::Plugin)

    List of common plugins for this module, plus specification for writing your own
    plugins.

- [Test::SpellCheck::Plugin::Perl](https://metacpan.org/pod/Test::SpellCheck::Plugin::Perl)

    The default plugin used by this module.

- [Text::Hunspell](https://metacpan.org/pod/Text::Hunspell)

    XS based bindings to the Hunspell spelling library.

- [Text::Hunspell::FFI](https://metacpan.org/pod/Text::Hunspell::FFI)

    FFI based bindings to the Hunspell spelling library.

- [Pod::Spell](https://metacpan.org/pod/Pod::Spell)

    A formatter for spellchecking POD (used by [Test::Spelling](https://metacpan.org/pod/Test::Spelling)

- [Pod::Wordlist](https://metacpan.org/pod/Pod::Wordlist)

    A list of common jargon words used in Perl documentation.

- [Test::Spelling](https://metacpan.org/pod/Test::Spelling)

    An older spellchecker for POD.

- [Test::Spelling::Comment](https://metacpan.org/pod/Test::Spelling::Comment)

    Tool for checking the spelling of comments.

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2021 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
