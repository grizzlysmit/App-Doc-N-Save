#!/usr/bin/env raku
use JSON::Fast;

=begin pod

=head2 release_d 

A B<Raku> program to fez upload programs or modules to zef and update the
the git repositories release tags. 

B<Note1: you will need a I<archive/> directory for this best put it in your I<.gitignore> as those archieve files get too big>.

B<Note2:> This uses git archive to get around a fez/zef update bug.

B<Note3:> I found the original release.raku on the web somewhere in L<raku.land|https://raku.land/>,
if you are the originator please claim it so I can give credit.

=begin code :lang<bash>

release_d --help
Usage:
  release_d

=end code

L<Top of Document|#table-of-contents>

=end pod

sub MAIN() {
    given from-json(slurp('META6.json')) -> (:$version!, *%) {
        my Str:D $datetime = DateTime.now.Str;
        my Str:D $filename = "archive/{$datetime}-Gzz-Text-Utils-{$version}.tar.gz";
        my Str:D $archive  = "git archive --format=tar.gz --output=$filename HEAD";
        $archive.say;
        shell($archive);
        #shell("git add $filename");
        my Str:D $fez = "fez upload --file=$filename";
        $fez.say;
        shell($fez);
        tag("release-$version");
    }
}

sub tag($tag) {
    shell "git tag -a -m '$tag' $tag && git push --tags origin"
}
