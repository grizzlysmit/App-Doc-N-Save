Mk-Raku-Dirs 
=============

Table of Contents
-----------------

  * [NAME](#name)

  * [AUTHOR](#author)

  * [VERSION](#version)

  * [TITLE](#title)

  * [SUBTITLE](#subtitle)

  * [COPYRIGHT](#copyright)

  * [Introduction](#introduction)

  * [list-by(…)](#list-by)

    * [Examples:](#examples)

      * [A more complete example:](#a-more-complete-example)

      * [Another example:](#another-example)

        * [An Example of the above code **`list-editors-backups(…)`** at work:](#An-Example-of-the-above-code-list-editors-backups-at-work)

  * [The default callbacks](#the-default-callbacks)

    * [The hash of hashes stuff](#the-hash-of-hashes-stuff)

    * [The array of hashes stuff](#the-array-of-hashes-stuff)

NAME
====

Display::Listings 

AUTHOR
======

Francis Grizzly Smit (grizzly@smit.id.au)

VERSION
=======

0.1.0

TITLE
=====

Display::Listings

SUBTITLE
========

A Raku module for displaying lines in a listing.

COPYRIGHT
=========

LGPL V3.0+ [LICENSE](https://github.com/grizzlysmit/Display-Listings/blob/main/LICENSE)

[Top of Document](#table-of-contents)

Introduction
============

A **Raku** program for generating docs and saving it's changes to git. 

### Primary MAIN 

```raku
multi sub MAIN('empty', Str:D $name, Str:D :l(:$lib) is copy = 'rakulib', Str:D :b(:$bin) is copy = 'bin',
                     Str:D :d(:$docs) is copy = 'docs', Str:D :T(:$tags) = '',
                     Str:D :p(:$depends) = '', Str:D :t(:$test) = 't',
                     Str:D :$test-depends = '', Str :$git-dir is copy = Str,
                     Str:D :m(:$markdown-path) is copy = 'README.md',
                     Str:D :c(:comment(:$git-comment)) = 'first commit', 
                     Bool:D :a(:application(:$app)) is copy = False, 
                     Bool:D :o(:$only-app) is copy = False, 
                     Str :D(:$description) is copy = Str, 
                     Str :$git-url is copy = Str,
                     Str :u(:$git-user) is copy = Str,
                     Str :e(:$email) is copy = Str,
                     Str :$zef-auth is copy = Str,
                     *@additional-files --> Int:D)
```

[Top of Document](#table-of-contents)

