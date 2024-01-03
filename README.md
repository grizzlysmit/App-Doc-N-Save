Doc-N-Save 
===========

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

    * [doc-n-save](#doc-n-save)

    * [mk-raku-dirs](/docs/mk-raku-dirs.md)

    * [release](/docs/release.md)

    * [release_d](/docs/release_d.md)

NAME
====

Doc-N-Save 

AUTHOR
======

Francis Grizzly Smit (grizzly@smit.id.au)

VERSION
=======

0.1.0

TITLE
=====

Doc-N-Save

SUBTITLE
========

A collection of **Raku** programs for managing modules and apps in **Raku**, and do things like summit to zef etc.

COPYRIGHT
=========

GPL V3.0+ [LICENSE](https://github.com/grizzlysmit/App-Doc-N-Save/blob/main/LICENSE)

[Top of Document](#table-of-contents)

Introduction
============

A collection of **Raku** programs for managing modules and apps in **Raku**, and do things like summit to zef etc. 

  * B`doc-n-save`> a program for generating Documentation from pod files (files containing pod6 markup) and saving the result to git.

  * [mk-raku-dirs](/docs/mk-raku-dirs.md) either create a full skeleton repository from a few simple arguments or make sure that an existing repository is complete. 

  * [release](/docs/release.md)

  * [release_d](/docs/release_d.md)

### doc-n-save 

```bash
doc-n-save --help
Usage:
  doc-n-save <name> [<additional-pod-files> ...] [-l|--lib=<Str>] [-b|--bin=<Str>] [-e|--exts=<Str>] [-d|--docs=<Str>] [-m|--markdown-path=<Str>] [-o|--only-app] [-c|--comment=<Str>]
```

[Top of Document](#table-of-contents)

