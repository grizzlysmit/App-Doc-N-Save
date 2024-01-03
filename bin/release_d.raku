#!/usr/bin/env raku
use JSON::Fast;

=begin pod

=head1 release_d 

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
=item1 L<release_d|#release_d>

=NAME release_d 
=AUTHOR Francis Grizzly Smit (grizzly@smit.id.au)
=VERSION 0.1.0
=TITLE release_d
=SUBTITLE A Raku module for displaying lines in a listing.

=COPYRIGHT
LGPL V3.0+ L<LICENSE|https://github.com/grizzlysmit/Display-Listings/blob/main/LICENSE>

L<Top of Document|#table-of-contents>

=head1 Introduction

A B<Raku> program to fez upload programs or modules to zef and update the
the git repositories release tags. 

B<Note1:> This uses git archive to get around a fez/zef update bug.

B<Note2:> I found the original release.raku on the web somewhere in L<raku.land|https://raku.land/>,
if you are the originator please claim it so I can give credit.

=head3 release_d

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
