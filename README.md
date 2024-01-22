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

      * [doc-n-save prompt create config](#doc-n-save-prompt-create-config)

      * [doc-n-save](#doc-n-save-1)

      * [doc-n-save](#doc-n-save-1)

      * [doc-n-save](#doc-n-save-1)

      * [doc-n-save](#doc-n-save-1)

      * [doc-n-save](#doc-n-save-1)

    * [mk-raku-dirs](#mk-raku-dirs)

    * [release](#release)

    * [release-d](#release-d)

NAME
====

Doc-N-Save 

AUTHOR
======

Francis Grizzly Smit (grizzly@smit.id.au)

VERSION
=======

0.1.12

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

  * [release-d](#release-d) is a program to send a new release to **zef** via **fez** this one solves a bug in **fez**.

### doc-n-save.raku

### doc-n-save 

```bash
doc-n-save --help
Usage:
  doc-n-save [-c|--comment=<Str>]
  doc-n-save create config <name> [<additional-pod-files> ...] [-l|--lib=<Str>] [-b|--bin=<Str>] [-e|--exts=<Str>] [-d|--docs=<Str>] [-m|--markdown-path=<Str>] [-o|--only-app] [--separate-markdown-files] [-c|--comment=<Str>]
  doc-n-save prompt create config [<name>] [<additional-pod-files> ...] [-l|--lib=<Str>] [-b|--bin=<Str>] [-e|--exts=<Str>] [-d|--docs=<Str>] [-m|--markdown-path=<Str>] [-o|--only-app] [--separate-markdown-files] [-c|--comment=<Str>]
  doc-n-save explicit <name> [<additional-pod-files> ...] [-l|--lib=<Str>] [-b|--bin=<Str>] [-e|--exts=<Str>] [-d|--docs=<Str>] [-m|--markdown-path=<Str>] [-o|--only-app] [--separate-markdown-files] [-c|--comment=<Str>]
```

**`doc-n-save`** expects to be run from the root directory of the project.

  * Where

    * The first form **`doc-n-save [-c|--comment=<Str>]`** expects a **`.doc-n-save.json`** file to exist in the root directory of the project which is where you run doc-n-save from. 

      * comment should be a string to override the comment in the **`.doc-n-save.json`** file or leave it out to leave that comment in.

    * the **`doc-n-save create config`** creates a **`.doc-n-save.json`** file for the first form to use.

    *     B<C<doc-n-save prompt create config>> also creates a config file B<C<.doc-n-save.json>> but gives you a

      input-menu that allows you to build the correct values a step at a time.

    * The **`doc-n-save explicit`** form takes all the same arguments as the **`doc-n-save create config`** form but does the create docs and save them to git without saving the args like the other.

[Top of Document](#table-of-contents)

### doc-n-save prompt create config

Build the **.doc-n-save.json** file interactively using a menu system. 

```sh
doc-n-save prompt create config --help
Usage:
  doc-n-save prompt create config [<name>] [<additional-pod-files> ...] [-l|--lib=<Str>] [-b|--bin=<Str>] [-e|--exts=<Str>] [-d|--docs=<Str>] [-m|--markdown-path=<Str>] [-o|--only-app] [--separate-markdown-files] [-c|--comment=<Str>]
```

```sh
Configure Doc-N-Save
         0	name > doc-n-save   
         1	lib > rakulib       
         2	bin > bin           
         3	exts > rakumod, raku, rakudoc
         4	docs > docs         
         5	markdown-path > README.md
         6	only-app > False    
         7	separate-markdown-files > False
         8	comment > using doc-n-save
         9	additional-pod-files > mk-raku-dirs, release, release-d
        10	cancel > cancel     
        11	OK > OK             
use cancel, bye, bye bye, quit, q, or 11 to quit or enter to accept the values as is
choose a candidate 0..11 =:> B<⌼>
```

[Top of Document](#table-of-contents)

Mk-Raku-Dirs.raku
-----------------

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

release.raku
------------

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

release-d.raku 
---------------

release-d 
----------

release_d 
----------

A **Raku** program to fez upload programs or modules to zef and update the the git repositories release tags. 

**Note1: you will need a *archive/* directory for this best put it in your *.gitignore* as those archieve files get too big**.

**Note2:** This uses git archive to get around a fez/zef update bug.

**Note3:** I found the original release.raku on the web somewhere in [raku.land](https://raku.land/), if you are the originator please claim it so I can give credit.

```bash
release-d --help
Usage:
  release-d
```

[Top of Document](#table-of-contents)

