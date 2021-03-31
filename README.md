# Test::SpellCheck ![linux](https://github.com/uperl/Test-SpellCheck/workflows/linux/badge.svg) ![windows](https://github.com/uperl/Test-SpellCheck/workflows/windows/badge.svg) ![macos](https://github.com/uperl/Test-SpellCheck/workflows/macos/badge.svg) ![cygwin](https://github.com/uperl/Test-SpellCheck/workflows/cygwin/badge.svg) ![msys2-mingw](https://github.com/uperl/Test-SpellCheck/workflows/msys2-mingw/badge.svg)

Check spelling of POD and other documents

# SYNOPSIS

```perl
use Test2::V0;

spell_check 'lib/**/*.pm';

done_testing;
```

# DESCRIPTION

```
# TODO
```

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

    ```
    # TODO
    ```

- Add a dist-level dictionary

    ```
    # TODO
    ```

- Don't spellcheck comments

    ```
    # TODO
    ```

- Skip / don't skip POD sections

    ```
    # TODO
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
    ['PerlComment'],
  ],
;
```

A full list of common plugins, as well as documentation for writing your own plugins can be
found at [Test::SpellCheck::Plugin](https://metacpan.org/pod/Test::SpellCheck::Plugin).

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

# AUTHOR

Graham Ollis <plicease@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2021 by Graham Ollis.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
