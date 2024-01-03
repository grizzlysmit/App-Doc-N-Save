#!/usr/bin/env raku
use v6;
use JSON::Fast;

my %*SUB-MAIN-OPTS;
%*SUB-MAIN-OPTS«named-anywhere» = True;
#%*SUB-MAIN-OPTS<bundling>       = True;

=begin pod

=head2 Mk-Raku-Dirs 

A B<Raku> program for either create a full skeleton repository
from a few simple arguments or make sure that an existing repository is complete. 

=begin code :lang<bash>

mk-raku-dirs --help
Usage:
  mk-raku-dirs empty <name> [<additional-files> ...] [-l|--lib=<Str>] [-b|--bin=<Str>] [-d|--docs=<Str>] [-T|--tags=<Str>] [-p|--depends=<Str>] [-t|--test=<Str>] [--test-depends=<Str>] [--git-dir=<Str>] [-m|--markdown-path=<Str>] [-c|--comment|--git-comment=<Str>] [-a|--application|--app] [-o|--only-app] [-D|--description=<Str>] [--git-url=<Str>] [-u|--git-user=<Str>] [-e|--email=<Str>] [-U|--git-username=<Str>] [--zef-auth=<Str>]
  mk-raku-dirs here <name> [<additional-files> ...] [-l|--lib=<Str>] [-b|--bin=<Str>] [-d|--docs=<Str>] [-T|--tags=<Str>] [-p|--depends=<Str>] [-t|--test=<Str>] [--test-depends=<Str>] [--git-dir=<Str>] [-m|--markdown-path=<Str>] [-c|--comment|--git-comment=<Str>] [-a|--application|--app] [-o|--only-app] [-D|--description=<Str>] [-u|--git-user=<Str>] [-e|--email=<Str>] [-U|--git-username=<Str>] [--zef-auth=<Str>]

=end code

L<Top of Document|#table-of-contents>

=end pod

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
                     Str :U(:$git-username) is copy = Str,
                     Str :$zef-auth is copy = Str,
                     *@additional-files --> Int:D) {
    $lib = %*ENV«DOC_N_SAVE_LIB» if $lib eq 'rakulib' && (%*ENV«DOC_N_SAVE_LIB»:exists) && (%*ENV«DOC_N_SAVE_LIB».IO ~~ :d);
    $bin = %*ENV«DOC_N_SAVE_BIN» if $bin eq 'bin' && (%*ENV«DOC_N_SAVE_BIN»:exists) && (%*ENV«DOC_N_SAVE_BIN».IO ~~ :d);
    $docs = %*ENV«DOC_N_SAVE_DOCS» if $docs eq 'docs' && (%*ENV«DOC_N_SAVE_DOCS»:exists) && (%*ENV«DOC_N_SAVE_DOCS».IO ~~ :d);
    $markdown-path = %*ENV«DOC_N_SAVE_MARKDOWN-PATH» if $markdown-path eq 'README.md' && (%*ENV«DOC_N_SAVE_MARKDOWN-PATH»:exists)
                                                                                                && (%*ENV«DOC_N_SAVE_MARKDOWN-PATH».IO ~~ :d);
    without $git-user {
        if %*ENV«GIT_USER»:exists {
            $git-user = %*ENV«GIT_USER»;
        } else {
            my Str:D $tmp = qx[git config --global --get user.name];
            $tmp .=chomp;
            $git-user = $tmp if $tmp ne '';
        }
    }
    without $git-username {
        if %*ENV«GITHUB_USERNAME»:exists {
            $git-username = %*ENV«GITHUB_USERNAME»;
        } else {
            $git-username = "$*USER";
        }
    }
    without $git-user {
        my Str:D $msg = qq[you need to set up git correctly first could not obtain your git user.name\n];
        $msg         ~= qq[run git config --global user.name "FIRST_NAME LAST_NAME"\n];
        $msg         ~= qq[don't forget to change FIRST_NAME and LAST_NAME to you details.\n];
        die $msg;
    }
    without $email {
        if %*ENV«GIT_EMAIL»:exists {
            $email = %*ENV«GIT_EMAIL»;
        } else {
            my Str:D $tmp = qx[git config --global --get user.email];
            $tmp .=chomp;
            $email = $tmp if $tmp ne '';
        }
    }
    without $email {
        my Str:D $msg = qq[you need to set up git correctly first could not obtain your git user.email\n];
        $msg         ~= qq[run git config --global user.email "MY_NAME@example.com"\n];
        $msg         ~= qq[don't forget to change MY_NAME@example.com to you details.\n];
        die $msg;
    }
    without $zef-auth {
        if %*ENV«MK_RAKU_DIRS_ZEF_AUTH»:exists {
            $zef-auth = %*ENV«MK_RAKU_DIRS_ZEF_AUTH»;
        } else {
            my Str:D $msg = qq[you must specifiy zef-auth either set the environment variable ];
            $msg         ~= qq[MK_RAKU_DIRS_ZEF_AUTH to the value, or pass it using --zef-auth=<Auth>];
            die $msg;
        }
    }
    my Bool:D $module = $name ~~ rx/ '.rakumod' $ / || (@additional-files.grep( { rx/ '.rakumod' $ / }).elems > 0);
    $only-app = !$module;
    $app = True if $only-app;
    $app = True if $name.IO.basename.starts-with('App::', :ignorecase);
    $app = True if $name ~~ rx/ '.raku' $ /;
    my $dir = $name.IO.basename;
    $dir ~~ s/ '.raku' \w* $ //;
    $dir ~~ s:global/'::'/-/;
    if $dir.IO ~~ :e {
        "directory $dir already exists".say;
        exit 1;
    }
    my IO::Path $path = $dir.IO.mkdir;
    say $path;
    &*chdir($path);
    ".gitignore".IO.spurt(qq[.*.swp\nscratch/*\nrakulib/.precomp/\nsdist/\n.fez\nscratch/\narchive/\n]);
    "archive".IO.mkdir;
    without $git-dir {
        $git-dir = $dir;
    }
    unless $only-app {
        my IO::Path $p = $lib.IO.mkdir;
        $p.symlink('lib', :!absolute) unless $lib eq 'lib';
    }
    $docs.IO.mkdir;
    unless $markdown-path.IO.dirname eq '' {
        $markdown-path.IO.dirname.IO.mkdir;
    }
    $test.IO.mkdir;
    if !$only-app {
        unless $lib.IO ~~ :d {
            die "Error: $lib does not exist or is not a directory";
        }
    }
    unless $docs.IO ~~ :d {
        die "Error: $docs does not exist or is not a directory";
    }
    unless $markdown-path.IO.dirname.IO ~~ :d {
        die "Error: {$markdown-path.IO.dirname} does not exist or is not a directory";
    }
    if $app {
        $bin.IO.mkdir;
    } 
    "$test/001-Meta-test.rakutest".IO.spurt(q:to/END/);
    use v6;
    use lib 'lib';
    use Test;

    plan 1;

    constant AUTHOR = ?%*ENV<AUTHOR_TESTING>;

    if AUTHOR {
        require Test::META <&meta-ok>;
        meta-ok;
        done-testing;
    }
    else {
         skip-rest "Skipping author test";
         exit;
    }
    done-testing;
    END
    my %provides;
    my Str:D $pod = $name.IO.basename;
    my Str:D $_name = $name.IO.basename;
    if $name ~~ rx/ '.raku' $ / {
        $pod ~~ s:ignorecase/ ^ 'App::' //;
        "$bin/$pod".IO.spurt(qq[#!/usr/bin/env raku\nuse v6;\n\n]);
        "$bin/$pod".IO.chmod(0o755);
        $_name ~~ s/ '.raku' $ //;
        %provides{$_name} = "$bin/$pod";
        $app = True;
    } elsif $name ~~ rx/ '.rakumod' $ / {
        $pod ~~ s:g!'::'!/!;
        $_name ~~ s/ '.rakumod' $ //;
        my Str:D $pod_d = $pod;
        $pod_d ~~ s/ '.raku' \w* $ //;
        "$lib/$pod_d".IO.dirname.mkdir;
        "$lib/$pod".IO.spurt(qq[unit module {$_name}:ver<0.1.0>:auth<$git-user ($email)>;\n\n]);
        %provides{$_name} = "$lib/$pod";
    } elsif $name ~~ rx/ '.rakudoc' $ / {
        my Str:D $_name = $name.IO.basename;
        $_name ~~ s/ '.rakudoc' $ //;
        "$docs/$pod".IO.spurt(qq[=begin pod\n\n=head1 $_name\n\n=end pod]);
        %provides{$_name} = "$docs/$pod";
    } elsif $name ~~ rx/ '.rakutest' $ / {
        $_name ~~ s/ '.rakutest' $ //;
        "$test/$pod".IO.spurt(qq[use Test;\n\ndone-testing;]);
    } elsif $app {
        $pod ~~ s:ignorecase/ ^ 'App::' //;
        $pod ~= '.raku';
        "$bin/$pod".IO.spurt(qq[#!/usr/bin/env raku\nuse v6;\n\n]);
        "$bin/$pod".IO.chmod(0o755);
        %provides{$_name} = "$bin/$pod";
    }
    $markdown-path.IO.spurt(qq[$_name\n{'=' x $_name.chars}\n\n]);
    for @additional-files -> $additional-file {
        $pod = $additional-file.IO.basename;
        if $additional-file ~~ rx/ '.raku' $ / {
            $pod ~~ s:ignorecase/ ^ 'App::' //;
            "$bin/$pod".IO.spurt(qq[#!/usr/bin/env raku\nuse v6;\n\n]);
            "$bin/$pod".IO.chmod(0o755);
            my Str:D $additional-filename = $additional-file.IO.basename;
            $additional-filename ~~ s/ '.raku' $ //;
            %provides{$additional-filename} = "$bin/$pod";
            $app = True;
        } elsif $additional-file ~~ rx/ '.rakumod' $ / {
            $pod ~~ s:g!'::'!/!;
            my Str:D $additional-filename = $additional-file.IO.basename;
            $additional-filename ~~ s/ '.rakumod' $ //;
            my Str:D $pod_d = $pod;
            $pod_d ~~ s/ '.raku' \w* $ //;
            "$lib/$pod_d".IO.dirname.IO.mkdir;
            qq["$lib/$pod_d".IO.dirname.IO.mkdir;].say;
            "$lib/$pod".IO.spurt(qq[unit module {$additional-filename}:ver<0.1.0>:auth<$git-user ($email)>;\n\n]);
            "created $lib/$pod".say;
            %provides{$additional-filename} = "$lib/$pod";
        } elsif $additional-file ~~ rx/ '.rakudoc' $ / {
            my Str:D $additional-filename = $additional-file.IO.basename;
            $additional-filename ~~ s/ '.rakudoc' $ //;
            "$docs/$pod".IO.spurt(qq[=begin pod\n\n=head1 $additional-filename\n\n=end pod]);
        }
    } # for @additional-pod-files -> $additional-pod-file #
    without $description {
        if $only-app {
            if @additional-files {
                $description = qq[A set of Raku applications for ];
            } else {
                $description = qq[A Raku application for ];
            }
        } elsif $app && $module {
            if @additional-files {
                $description = qq[A set of Raku applications and modules for ];
            } else {
                $description = qq[A Raku application for ];
            }
        } elsif $name ~~ rx/ '.rakutest' $ / {
            $_name ~~ s/ '.rakutest' $ //;
            "$test/$pod".IO.spurt(qq[use Test;\n\ndone-testing;]);
        }
    }
    my IO::Path $meta6 = 'META6.json'.IO;
    my @test-depends = $test-depends.split(':');
    my @tags = $tags.split(':');
    my @depends = $depends.split(':');
    my $meta = {
        name => $name,
        description => "$description.",
        perl => "6.d",
        license => "LGPL-3.0-or-later",
        authors => [
            "$git-user <$email>"
        ],
        depends => @depends,
        provides => %provides,
        source-url  => "https://github.com/$git-username/$git-dir.git",
        support => {
            source => "https://github.com/$git-username/$git-dir.git",
            email => $email,
            bugtracker => "https://github.com/$git-username/$git-dir/issues"
        },
        auth => "$zef-auth",
        version => "0.1.0",
        "tags" => @tags,
      test-depends => @test-depends
    };
    my Str:D $json = to-json $meta;
    $meta6.spurt($json, :createonly);
    "git init".say;
    my Proc $p0 = run 'git', 'init';
    exit 1 if $p0.exitcode != 0;
    "git add .".say;
    my Proc $p1 = run 'git', 'add', '.';
    exit 1 if $p1.exitcode != 0;
    my Str:D $datetime = DateTime.now.Str;
    qq[git commit -a -m "$git-comment $datetime"].say;
    my Proc $p2 = run 'git', 'commit', '-a', '-m', "$git-comment $datetime";
    exit 1 if $p2.exitcode != 0;
    "git branch -M main".say;
    my Proc $p3 = run 'git', 'branch', '-M', 'main';
    exit 1 if $p3.exitcode != 0;
    with $git-url {
        "git remote add origin $git-url".say;
        my Proc $p4 = run 'git', 'remote', 'add', 'origin', $git-url;
        exit 1 if $p4.exitcode != 0;
        "git push -u origin main".say;
        my Proc $p5 = run 'git', 'push', '-u', 'origin', 'main';
        exit 1 if $p5.exitcode != 0;
        "git status".say;
        my Proc $p6 = run 'git', 'status';
        exit 1 if $p6.exitcode != 0;
    } else {
        qq[no :git-url set so you will need to do the rest yourself i.e.].say;
        qq[git remote add origin <git-url>].say;
        qq[git push -u origin main].say;
        qq[NB: you need to set up the remote repository on github or whatever and you will get the git-url there.].say;
    }
    exit 0;
} #`««« multi sub MAIN('empty', Str:D $name, Str:D :l(:$lib) is copy = 'rakulib', Str:D :b(:$bin) is copy = 'bin',
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
                     *@additional-files --> Int:D)  »»»

multi sub MAIN('here', Str:D $name, Str:D :l(:$lib) is copy = 'rakulib', Str:D :b(:$bin) is copy = 'bin',
                     Str:D :d(:$docs) is copy = 'docs', Str:D :T(:$tags) = '',
                     Str:D :p(:$depends) = '', Str:D :t(:$test) = 't',
                     Str:D :$test-depends = '', Str :$git-dir is copy = Str,
                     Str:D :m(:$markdown-path) is copy = 'README.md',
                     Str:D :c(:comment(:$git-comment)) = "updated with $*PROGRAM-NAME", 
                     Bool:D :a(:application(:$app)) is copy = False, 
                     Bool:D :o(:$only-app) is copy = False, 
                     Str :D(:$description) is copy = Str, 
                     Str :u(:$git-user) is copy = Str,
                     Str :e(:$email) is copy = Str,
                     Str :U(:$git-username) is copy = Str,
                     Str :$zef-auth is copy = Str,
                     *@additional-files --> Int:D) {
    $lib = %*ENV«DOC_N_SAVE_LIB» if $lib eq 'rakulib' && (%*ENV«DOC_N_SAVE_LIB»:exists) && (%*ENV«DOC_N_SAVE_LIB».IO ~~ :d);
    $bin = %*ENV«DOC_N_SAVE_BIN» if $bin eq 'bin' && (%*ENV«DOC_N_SAVE_BIN»:exists) && (%*ENV«DOC_N_SAVE_BIN».IO ~~ :d);
    $docs = %*ENV«DOC_N_SAVE_DOCS» if $docs eq 'docs' && (%*ENV«DOC_N_SAVE_DOCS»:exists) && (%*ENV«DOC_N_SAVE_DOCS».IO ~~ :d);
    $markdown-path = %*ENV«DOC_N_SAVE_MARKDOWN-PATH» if $markdown-path eq 'README.md' && (%*ENV«DOC_N_SAVE_MARKDOWN-PATH»:exists)
                                                                                                && (%*ENV«DOC_N_SAVE_MARKDOWN-PATH».IO ~~ :d);
    without $git-user {
        if %*ENV«GIT_USER»:exists {
            $git-user = %*ENV«GIT_USER»;
        } else {
            my Str:D $tmp = qx[git config --global --get user.name];
            $tmp .=chomp;
            $git-user = $tmp if $tmp ne '';
        }
    }
    without $git-user {
        my Str:D $msg = qq[you need to set up git correctly first could not obtain your git user.name\n];
        $msg         ~= qq[run git config --global user.name "FIRST_NAME LAST_NAME"\n];
        $msg         ~= qq[don't forget to change FIRST_NAME and LAST_NAME to you details.\n];
        die $msg;
    }
    without $git-username {
        if %*ENV«GITHUB_USERNAME»:exists {
            $git-username = %*ENV«GITHUB_USERNAME»;
        } else {
            $git-username = "$*USER";
        }
    }
    without $email {
        if %*ENV«GIT_EMAIL»:exists {
            $email = %*ENV«GIT_EMAIL»;
        } else {
            my Str:D $tmp = qx[git config --global --get user.email];
            $tmp .=chomp;
            $email = $tmp if $tmp ne '';
        }
    }
    without $email {
        my Str:D $msg = qq[you need to set up git correctly first could not obtain your git user.email\n];
        $msg         ~= qq[run git config --global user.email "MY_NAME@example.com"\n];
        $msg         ~= qq[don't forget to change MY_NAME@example.com to you details.\n];
        die $msg;
    }
    without $zef-auth {
        if %*ENV«MK_RAKU_DIRS_ZEF_AUTH»:exists {
            $zef-auth = %*ENV«MK_RAKU_DIRS_ZEF_AUTH»;
        } else {
            my Str:D $msg = qq[you must specifiy zef-auth either set the environment variable ];
            $msg         ~= qq[MK_RAKU_DIRS_ZEF_AUTH to the value, or pass it using --zef-auth=<Auth>];
            die $msg;
        }
    }
    my Bool:D $module = $name ~~ rx/ '.rakumod' $ / || (@additional-files.grep( { rx/ '.rakumod' $ / }).elems > 0);
    $only-app = !$module;
    $app = True if $only-app;
    $app = True if $name.IO.basename.starts-with('App::', :ignorecase);
    $app = True if $name ~~ rx/ '.raku' $ /;
    ".gitignore".IO.spurt(qq[.*.swp\nscratch/*\nrakulib/.precomp/\nsdist/\n.fez\nscratch/\narchive/\n], :createonly) unless ".gitignore".IO ~~ :e;
    "archive".IO.mkdir unless "narchive".IO ~~ :e;
    without $git-dir {
        my Str:D $dir = $name.IO.basename;
        $dir ~~ s/ '.raku' \w* $ //;
        $git-dir = $dir;
    }
    unless $only-app {
        my IO::Path $p = $lib.IO.mkdir unless $lib.IO ~~ :d;
        $p.symlink('lib', :!absolute) unless $lib eq 'lib' || $lib.IO !~~ :d || 'lib'.IO ~~ :l;
    }
    $docs.IO.mkdir unless $docs.IO ~~ :d;
    unless $markdown-path.IO.dirname eq '' || $markdown-path.IO.dirname.IO ~~ :d {
        $markdown-path.IO.dirname.IO.mkdir;
    }
    $test.IO.mkdir unless $test.IO ~~ :d;
    if !$only-app {
        unless $lib.IO ~~ :d {
            die "Error: $lib does not exist or is not a directory";
        }
    }
    unless $docs.IO ~~ :d {
        die "Error: $docs does not exist or is not a directory";
    }
    unless $markdown-path.IO.dirname.IO ~~ :d {
        die "Error: {$markdown-path.IO.dirname} does not exist or is not a directory";
    }
    if $app || $bin.IO !~~ :d {
        $bin.IO.mkdir;
    } 
    "$test/001-Meta-test.rakutest".IO.spurt(q:to/END/, :createonly) unless "$test/001-Meta-test.rakutest".IO ~~ :f;
    use v6;
    use lib 'lib';
    use Test;

    plan 1;

    constant AUTHOR = ?%*ENV<AUTHOR_TESTING>;

    if AUTHOR {
        require Test::META <&meta-ok>;
        meta-ok;
        done-testing;
    }
    else {
         skip-rest "Skipping author test";
         exit;
    }
    done-testing;
    END
    my %provides;
    my Str:D $pod = $name.IO.basename;
    my Str:D $_name = $name.IO.basename;
    if $name ~~ rx/ '.raku' $ / {
        $pod ~~ s:ignorecase/ ^ 'App::' //;
        "$bin/$pod".IO.spurt(qq[#!/usr/bin/env raku\nuse v6;\n\n], :createonly) unless "$bin/$pod".IO ~~ :f;
        "$bin/$pod".IO.chmod(0o755);
        $_name ~~ s/ '.raku' $ //;
        %provides{$_name} = "$bin/$pod";
        $app = True;
    } elsif $name ~~ rx/ '.rakumod' $ / {
        $pod ~~ s:g!'::'!/!;
        $_name ~~ s/ '.rakumod' $ //;
        my Str:D $pod_d = $pod;
        $pod_d ~~ s/ '.raku' \w* $ //;
        "$lib/$pod_d".IO.dirname.mkdir;
        "$lib/$pod".IO.spurt(qq[unit module {$_name}:ver<0.1.0>:auth<$git-user ($email)>;\n\n], :createonly) unless "$lib/$pod".IO ~~ :f;
        %provides{$_name} = "$lib/$pod";
    } elsif $name ~~ rx/ '.rakudoc' $ / {
        my Str:D $_name = $name.IO.basename;
        $_name ~~ s/ '.rakudoc' $ //;
        "$docs/$pod".IO.spurt(qq[=begin pod\n\n=head1 $_name\n\n=end pod], :createonly) unless "$docs/$pod".IO ~~ :f;
        %provides{$_name} = "$docs/$pod";
    } elsif $name ~~ rx/ '.rakutest' $ / {
        $_name ~~ s/ '.rakutest' $ //;
        "$test/$pod".IO.spurt(qq[use Test;\n\ndone-testing;], :createonly) unless "$docs/$pod".IO ~~ :f;
    } elsif $app {
        $pod ~~ s:ignorecase/ ^ 'App::' //;
        $pod ~= '.raku';
        "$bin/$pod".IO.spurt(qq[#!/usr/bin/env raku\nuse v6;\n\n], :createonly) unless "$docs/$pod".IO ~~ :f;
        "$bin/$pod".IO.chmod(0o755);
        %provides{$_name} = "$bin/$pod";
    } else {
        my Str:D $msg = qq[Error: unknown extension {$pod.IO.ext} I cannot cope.];
        die $msg;
    }
    $markdown-path.IO.spurt(qq[$_name\n{'=' x $_name.chars}\n\n], :createonly) unless "$docs/$pod".IO ~~ :f;
    for @additional-files -> $additional-file {
        $pod = $additional-file.IO.basename;
        if $additional-file ~~ rx/ '.raku' $ / {
            $pod ~~ s:ignorecase/ ^ 'App::' //;
            "$bin/$pod".IO.spurt(qq[#!/usr/bin/env raku\nuse v6;\n\n], :createonly) unless "$bin/$pod".IO ~~ :f;
            "$bin/$pod".IO.chmod(0o755);
            my Str:D $additional-filename = $additional-file.IO.basename;
            $additional-filename ~~ s/ '.raku' $ //;
            %provides{$additional-filename} = "$bin/$pod";
            $app = True;
        } elsif $additional-file ~~ rx/ '.rakumod' $ / {
            $pod ~~ s:g!'::'!/!;
            my Str:D $additional-filename = $additional-file.IO.basename;
            $additional-filename ~~ s/ '.rakumod' $ //;
            my Str:D $pod_d = $pod;
            $pod_d ~~ s/ '.raku' \w* $ //;
            "$lib/$pod_d".IO.dirname.IO.mkdir unless "$docs/$pod_d".IO ~~ :d;
            qq["$lib/$pod_d".IO.dirname.IO.mkdir;].say;
            "$lib/$pod".IO.spurt(qq[unit module {$additional-filename}:ver<0.1.0>:auth<$git-user ($email)>;\n\n], :createonly)
                                                                                                                unless "$lib/$pod".IO ~~ :f;
            "created $lib/$pod".say;
            %provides{$additional-filename} = "$lib/$pod";
        } elsif $additional-file ~~ rx/ '.rakudoc' $ / {
            my Str:D $additional-filename = $additional-file.IO.basename;
            $additional-filename ~~ s/ '.rakudoc' $ //;
            "$docs/$pod".IO.spurt(qq[=begin pod\n\n=head1 $additional-filename\n\n=end pod], :createonly) unless "$docs/$pod".IO ~~ :f;
        } else {
            my Str:D $msg = qq[Error: unknown extension \`{$pod.IO.ext}' I cannot cope skipping file: {$additional-file}.];
            warn $msg;
        }
    } # for @additional-pod-files -> $additional-pod-file #
    without $description {
        if $only-app {
            if @additional-files {
                $description = qq[A set of Raku applications for ];
            } else {
                $description = qq[A Raku application for ];
            }
        } elsif $app && $module {
            if @additional-files {
                $description = qq[A set of Raku applications and modules for ];
            } else {
                $description = qq[A Raku application for ];
            }
        } elsif $name ~~ rx/ '.rakutest' $ / {
            $_name ~~ s/ '.rakutest' $ //;
            "$test/$pod".IO.spurt(qq[use Test;\n\ndone-testing;], :createonly) unless "$test/$pod".IO ~~ :f;
        }
    }
    my IO::Path $meta6 = 'META6.json'.IO;
    my @test-depends = $test-depends.split(':');
    my @tags = $tags.split(':');
    my @depends = $depends.split(':');
    my $meta = {
        name => $name,
        description => "$description.",
        perl => "6.d",
        license => "LGPL-3.0-or-later",
        authors => [
            "$git-user <$email>"
        ],
        depends => @depends,
        provides => %provides,
        source-url  => "https://github.com/$git-username/$git-dir.git",
        support => {
            source => "https://github.com/$git-username/$git-dir.git",
            email => $email,
            bugtracker => "https://github.com/$git-username/$git-dir/issues"
        },
        auth => "$zef-auth",
        version => "0.1.0",
        "tags" => @tags,
      test-depends => @test-depends
    };
    my Str:D $json = to-json $meta;
    $meta6.spurt($json, :createonly) unless $meta6 ~~ :f;
    "git init".say unless ".git/config".IO ~~ :f;
    unless ".git/config".IO ~~ :f {
        my Proc $p0 = run 'git', 'init';
        exit 1 if $p0.exitcode != 0;
    }
    "git add .".say;
    my Proc $p1 = run 'git', 'add', '.';
    exit 1 if $p1.exitcode != 0;
    my Str:D $datetime = DateTime.now.Str;
    qq[git commit -a -m "$git-comment $datetime"].say;
    my Proc $p2 = run 'git', 'commit', '-a', '-m', "$git-comment $datetime";
    exit 1 if $p2.exitcode != 0;
    "git push --all".say;
    my Proc $p3 = run 'git', 'push', '--all';
    exit 1 if $p3.exitcode != 0;
    "git status".say;
    my Proc $p4 = run 'git', 'status';
    exit 1 if $p4.exitcode != 0;
    exit 0;
} #`««« multi sub MAIN('here', Str:D $name, Str:D :l(:$lib) is copy = 'rakulib', Str:D :b(:$bin) is copy = 'bin',
                     Str:D :d(:$docs) is copy = 'docs', Str:D :T(:$tags) = '',
                     Str:D :p(:$depends) = '', Str:D :t(:$test) = 't',
                     Str:D :$test-depends = '', Str :$git-dir is copy = Str,
                     Str:D :m(:$markdown-path) is copy = 'README.md',
                     Str:D :c(:comment(:$git-comment)) = "updated with $*PROGRAM-NAME", 
                     Bool:D :a(:application(:$app)) is copy = False, 
                     Bool:D :o(:$only-app) is copy = False, 
                     Str :D(:$description) is copy = Str, 
                     Str :u(:$git-user) is copy = Str,
                     Str :e(:$email) is copy = Str,
                     Str :U(:$git-username) is copy = Str,
                     Str :$zef-auth is copy = Str,
                     *@additional-files --> Int:D) »»»
