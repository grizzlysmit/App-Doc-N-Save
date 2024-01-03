#!/usr/bin/env raku
use JSON::Fast;

=begin pod

=head2 release

A B<Raku> program to fez upload programs or modules to zef and update the
the git repositories release tags. 

B<Note: I found the original release.raku on the web somewhere in L<raku.land|https://raku.land/>,
if you are the originator please claim it so I can give credit>.

=begin code :lang<bash>

release_d --help
Usage:
  release_d

=end code

L<Top of Document|#table-of-contents>

=end pod

sub MAIN() {
    given from-json(slurp('META6.json')) -> (:$version!, *%) {
        shell("fez upload");
        tag("release-$version");
    }
}

sub tag($tag) {
    shell "git tag -a -m '$tag' $tag && git push --tags origin"
}
