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

    * [doc-n-save](#doc-n-save-1)

    * [mk-raku-dirs](#mk-raku-dirs)

    * [release](#release)

    * [release_d](#release_d)

NAME
====

Doc-N-Save 

AUTHOR
======

Francis Grizzly Smit (grizzly@smit.id.au)

VERSION
=======

0.1.5

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

  * [doc-n-save](#doc-n-save-1) a program for generating Documentation from pod files (files containing pod6 markup) and saving the result to git.

  * [mk-raku-dirs](#mk-raku-dirs) either create a full skeleton repository from a few simple arguments or make sure that an existing repository is complete. 

  * [release](#release) is a program to send a new release to **zef** via **fez**.

  * [release_d](#release_d) is a program to send a new release to **zef** via **fez** this one solves a bug in **fez**.

### doc-n-save 

```bash
doc-n-save --help
Usage:
doc-n-save <name> [<additional-pod-files> ...] [-l|--lib=<Str>] [-b|--bin=<Str>] [-e|--exts=<Str>] [-d|--docs=<Str>] [-m|--markdown-path=<Str>] [-o|--only-app] [--separate-markdown-files] [-c|--comment=<Str>]
```

[Top of Document](#table-of-contents)

Mk-Raku-Dirs 
-------------

A **Raku** program for either create a full skeleton repository from a few simple arguments or make sure that an existing repository is complete. 

```bash
mk-raku-dirs --help
Usage:
  mk-raku-dirs empty <name> [<additional-files> ...] [-l|--lib=<Str>] [-b|--bin=<Str>] [-d|--docs=<Str>] [-T|--tags=<Str>] [-p|--depends=<Str>] [-t|--test=<Str>] [--test-depends=<Str>] [--git-dir=<Str>] [-m|--markdown-path=<Str>] [-c|--comment|--git-comment=<Str>] [-a|--application|--app] [-o|--only-app] [-D|--description=<Str>] [--git-url=<Str>] [-u|--git-user=<Str>] [-e|--email=<Str>] [-U|--git-username=<Str>] [--zef-auth=<Str>]
  mk-raku-dirs here <name> [<additional-files> ...] [-l|--lib=<Str>] [-b|--bin=<Str>] [-d|--docs=<Str>] [-T|--tags=<Str>] [-p|--depends=<Str>] [-t|--test=<Str>] [--test-depends=<Str>] [--git-dir=<Str>] [-m|--markdown-path=<Str>] [-c|--comment|--git-comment=<Str>] [-a|--application|--app] [-o|--only-app] [-D|--description=<Str>] [-u|--git-user=<Str>] [-e|--email=<Str>] [-U|--git-username=<Str>] [--zef-auth=<Str>]
```

[Top of Document](#table-of-contents)

release
-------

A **Raku** program to fez upload programs or modules to zef and update the the git repositories release tags. 

**Note: I found the original release.raku on the web somewhere in [raku.land](https://raku.land/), if you are the originator please claim it so I can give credit**.

```bash
release_d --help
Usage:
  release_d
```

[Top of Document](#table-of-contents)

release_d 
----------

A **Raku** program to fez upload programs or modules to zef and update the the git repositories release tags. 

**Note1: you will need a *archive/* directory for this best put it in your *.gitignore* as those archieve files get too big**.

**Note2:** This uses git archive to get around a fez/zef update bug.

**Note3:** I found the original release.raku on the web somewhere in [raku.land](https://raku.land/), if you are the originator please claim it so I can give credit.

```bash
release_d --help
Usage:
  release_d
```

[Top of Document](#table-of-contents)

