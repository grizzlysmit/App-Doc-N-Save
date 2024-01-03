#!/usr/bin/env raku
use v6;

my %*SUB-MAIN-OPTS;
%*SUB-MAIN-OPTS«named-anywhere» = True;
#%*SUB-MAIN-OPTS<bundling>       = True;

=begin pod

=head1 Doc-N-Save 

=begin head2

Table of Contents

=end head2

=item1 L<NAME|#name>
=item1 L<AUTHOR|#author>
=item1 L<VERSION|#version>
=item1 L<TITLE|#title>
=item1 L<SUBTITLE|#subtitle>
=item1 L<COPYRIGHT|#copyright>
=item1 L<Introduction|#introduction>
=item2 L<doc-n-save|#doc-n-save-1>
=item2 L<mk-raku-dirs|/docs/mk-raku-dirs.md>
=item2 L<release|/docs/release.md>
=item2 L<release_d|/docs/release_d.md>

=NAME Doc-N-Save 
=AUTHOR Francis Grizzly Smit (grizzly@smit.id.au)
=VERSION 0.1.0
=TITLE Doc-N-Save
=SUBTITLE A collection of B<Raku> programs for managing modules and apps in B<Raku>, and do things like summit to zef etc.

=COPYRIGHT
GPL V3.0+ L<LICENSE|https://github.com/grizzlysmit/App-Doc-N-Save/blob/main/LICENSE>

L<Top of Document|#table-of-contents>

=head1 Introduction

A collection of B<Raku> programs for managing modules and apps in B<Raku>,  
and do things like summit to zef etc. 
=begin item1

BC<doc-n-save>> a program for generating Documentation from pod files
(files containing pod6 markup) and saving the result to git.

=end item1

=begin item1

L<mk-raku-dirs|/docs/mk-raku-dirs.md> either create a full skeleton repository
from a few simple arguments or make sure that an existing repository is complete. 

=end item1

=item1 L<release|/docs/release.md>
=item1 L<release_d|/docs/release_d.md>


=head3 doc-n-save 

=begin code :lang<bash>

doc-n-save --help
Usage:
  doc-n-save <name> [<additional-pod-files> ...] [-l|--lib=<Str>] [-b|--bin=<Str>] [-e|--exts=<Str>] [-d|--docs=<Str>] [-m|--markdown-path=<Str>] [-o|--only-app] [-c|--comment=<Str>]

=end code

L<Top of Document|#table-of-contents>

=end pod

multi sub MAIN(Str:D $name, Str:D :l(:$lib) is copy = 'rakulib', Str:D :b(:$bin) is copy = 'bin',
                     Str:D :e(:$exts) = 'rakumod:raku:rakudoc', Str:D :d(:$docs) is copy = 'docs',
                     Str:D :m(:$markdown-path) is copy = 'README.md',
                     Bool:D :o(:$only-app) is copy = False, 
                     Str:D :c(:$comment) = 'using doc-n-save', *@additional-pod-files --> Int:D) {
    $lib = %*ENV«DOC_N_SAVE_LIB» if $lib eq 'rakulib' && (%*ENV«DOC_N_SAVE_LIB»:exists) && (%*ENV«DOC_N_SAVE_LIB».IO ~~ :d);
    $bin = %*ENV«DOC_N_SAVE_BIN» if $bin eq 'bin' && (%*ENV«DOC_N_SAVE_BIN»:exists) && (%*ENV«DOC_N_SAVE_BIN».IO ~~ :d);
    $exts = %*ENV«DOC_N_SAVE_EXT» if $exts  eq 'rakumod:raku:rakudoc' && (%*ENV«DOC_N_SAVE_EXT»:exists) && (%*ENV«DOC_N_SAVE_EXT».IO ~~ :d);
    $docs = %*ENV«DOC_N_SAVE_DOCS» if $docs eq 'docs' && (%*ENV«DOC_N_SAVE_DOCS»:exists) && (%*ENV«DOC_N_SAVE_DOCS».IO ~~ :d);
    $markdown-path = %*ENV«DOC_N_SAVE_MARKDOWN-PATH» if $markdown-path eq 'README.md' && (%*ENV«DOC_N_SAVE_MARKDOWN-PATH»:exists)
                                                                                                && (%*ENV«DOC_N_SAVE_MARKDOWN-PATH».IO ~~ :d);
    unless $only-app || $lib.IO ~~ :d {
        die "Error: $lib does not exist or is not a directory";
    }
    unless $docs.IO ~~ :d {
        die "Error: $docs does not exist or is not a directory";
    }
    unless $markdown-path.IO.dirname.IO ~~ :d {
        die "Error: {$markdown-path.IO.dirname} does not exist or is not a directory";
    }
    my @exts = $exts.split(':');
    my Str:D $pod = $name;
    $pod ~~ s:g!'::'!/!;
    my Str:D $pod1 = '';
    if !@exts {
        if $lib.IO ~~ :d && "$lib/{$pod}.rakumod".IO ~~ :f {
            $pod1 = "$lib/{$pod}.rakumod";
        } elsif $bin.IO ~~ :d && "$bin/{$pod}.raku".IO ~~ :f {
            $pod1 = "$bin/{$pod}.raku";
        } elsif $lib.IO ~~ :d && "$lib/{$pod}.rakudoc".IO ~~ :f {
            $pod1 = "$lib/{$pod}.rakudoc";
        } elsif "$docs/{$pod}.rakudoc".IO ~~ :f {
            $pod1 = "$docs/{$pod}.rakudoc";
        } else {
            die qq[Error: pod file not found as '$lib/{$pod}.rakumod', '$bin/{$name}.raku', '$lib/{$pod}.rakudoc' nor '$docs/{$name}.rakudoc'];
        }
    } else {
        for @exts -> Str:D $ext {
            $pod1 = (("$lib/{$pod}.$ext".IO ~~ :f) ?? "$lib/{$pod}.$ext"  !! "$bin/{$pod}.$ext");
            last if $pod1.IO ~~ :f;
        }
        unless $pod1.IO ~~ :f {
            my Str:D $msg = "Error: pod file not found as any of:\n";
            my Str:D $sep = ', ';
            my Str:D $end = ",\n";
            for @exts.kv -> Int:D $ind, Str:D $ext {
                if $ind == @exts.elems - 1 {
                    $sep = ' nor ';
                    $end = '!!!';
                }
                $msg ~= qq['$lib/{$pod}.$ext'$sep'$bin/{$pod}.$ext'$end];
            }
            die $msg;
        }
    } 
    $pod = $pod1;
    my Str:D $man-path = "$docs/{$name}.1";
    my Str:D $html-path = "$docs/{$name}.html";
    "raku --doc=Man $pod  > $man-path".say;
    my Proc $p1 = run 'raku', '--doc=Man', $pod, :out;
    my $man-content = $p1.out.slurp: :close;
    $man-path.IO.spurt($man-content);
    exit 1 if $p1.exitcode != 0;
    "raku --doc=HTML $pod  > $html-path".say;
    my Proc $p2 = run 'raku', '--doc=HTML', $pod, :out;
    my $html-content = $p2.out.slurp: :close;
    $html-path.IO.spurt($html-content);
    exit 1 if $p2.exitcode != 0;
    "raku --doc=Markdown $pod  > $markdown-path".say;
    my Proc $p3 = run 'raku', '--doc=Markdown', $pod, :out;
    my $markdown-content = $p3.out.slurp: :close;
    $markdown-path.IO.spurt($markdown-content);
    exit 1 if $p3.exitcode != 0;
    for @additional-pod-files -> $additional-pod-file {
        $pod = $additional-pod-file;
        $pod ~~ s:g!'::'!/!;
        if !@exts {
            if "$lib/{$pod}.rakumod".IO ~~ :f {
                $pod1 = "$lib/{$pod}.rakumod";
            } elsif "$bin/{$pod}.raku".IO ~~ :f {
                $pod1 = "$bin/{$pod}.raku";
            } elsif "$lib/{$pod}.rakudoc".IO ~~ :f {
                $pod1 = "$lib/{$pod}.rakudoc";
            } elsif "$docs/{$pod}.rakudoc".IO ~~ :f {
                $pod1 = "$docs/{$pod}.rakudoc";
            } else {
                die qq[Error: pod file not found as '$lib/{$pod}.rakumod', '$bin/{$pod}.raku', '$lib/{$pod}.rakudoc' nor '$docs/{$pod}.rakudoc'];
            }
        } else {
            for @exts -> Str:D $ext {
                $pod1 = (("$lib/{$pod}.$ext".IO ~~ :f) ?? "$lib/{$pod}.$ext"
                                    !! (("$bin/{$additional-pod-file}.$ext".IO ~~ :f) ?? "$bin/{$additional-pod-file}.$ext"
                                                                                            !! "$docs/{$additional-pod-file}.$ext"));
                last if $pod1.IO ~~ :f;
            }
            unless $pod1.IO ~~ :f {
                my Str:D $msg = "Error: pod file not found as any of:\n";
                my Str:D $sep = ', ';
                my Str:D $end = ",\n";
                for @exts.kv -> Int:D $ind, Str:D $ext {
                    if $ind == @exts.elems - 1 {
                        $sep = ' nor ';
                        $end = '!!!';
                    }
                    $msg ~= qq['$lib/{$pod}.$ext'$sep'$bin/{$pod}.$ext'$end];
                }
                die $msg;
            }
        } 
        $pod = $pod1;
        $man-path = "$docs/{$additional-pod-file}.1";
        $html-path = "$docs/{$additional-pod-file}.html";
        $markdown-path = "$docs/{$additional-pod-file}.md";
        "raku --doc=Man $pod  > $man-path".say;
        my Proc $p1 = run 'raku', '--doc=Man', $pod, :out;
        my $man-content = $p1.out.slurp: :close;
        $man-path.IO.spurt($man-content);
        if $p1.exitcode != 0 {
            'Failed'.say;
            next;
        }
        "raku --doc=HTML $pod  > $html-path".say;
        my Proc $p2 = run 'raku', '--doc=HTML', $pod, :out;
        my $html-content = $p2.out.slurp: :close;
        $html-path.IO.spurt($html-content);
        if $p2.exitcode != 0 {
            'Failed'.say;
            next;
        }
        "raku --doc=Markdown $pod  > $markdown-path".say;
        my Proc $p3 = run 'raku', '--doc=Markdown', $pod, :out;
        my $markdown-content = $p3.out.slurp: :close;
        $markdown-path.IO.spurt($markdown-content);
        if $p3.exitcode != 0 {
            'Failed'.say;
            next;
        }
    } # for @additional-pod-files -> $additional-pod-file #
    "git pull".say;
    my Proc $p4 = run 'git', 'pull';
    exit 1 if $p4.exitcode != 0;
    my Str:D $datetime = DateTime.now.Str;
    qq[git commit -a -m "$comment $datetime"].say;
    my Proc $p5 = run 'git', 'commit', '-a', '-m', "$comment $datetime";
    exit 1 if $p5.exitcode != 0;
    "git push --all".say;
    my Proc $p6 = run 'git', 'push', '--all';
    exit 1 if $p6.exitcode != 0;
    "git status".say;
    my Proc $p7 = run 'git', 'status';
    exit 1 if $p7.exitcode != 0;
    exit 0;
}
