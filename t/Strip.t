use strict;
use warnings;

use parent 'Test::Class';
use lib 't/lib';
use Test::More;
use Test::CodingStyle::Strip;

sub empty : Tests {
    my $strip = Test::CodingStyle::Strip->new;
    is $strip->strip(''), '';
}

sub comments : Tests {
    my $strip = Test::CodingStyle::Strip->new;
    is $strip->strip('#!perl'), '#!perl', 'shabang';
    is $strip->strip("#!perl\n#comment"), "#!perl\n", 'shabang and comment';
    is $strip->strip("#1\n#2\n#"), "\n\n", 'comments';
}

sub empty_comment : Tests {
    my $strip = Test::CodingStyle::Strip->new;
    is $strip->strip(<<COMMENT), "package Sample::Module1;\n\n\n\nuse strict;\nuse warnings;";
package Sample::Module1;
#
# 'User' <<common entity>>
#
use strict;
use warnings;
COMMENT
}

sub pod : Tests {
    my $strip = Test::CodingStyle::Strip->new;
    is $strip->strip(<<POD), 'body';
=head1 NAME

This is pod

=cut
body
POD
    is $strip->strip(<<POD), 'body';
body
__END__
=head1 NAME

This is pod

=cut
POD
}

__PACKAGE__->runtests;
