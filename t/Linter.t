use strict;
use warnings;
use utf8;

use parent 'Test::Class';

use lib 't/lib';
use Test::More;
use Test::CodingStyle::Linter;

sub new_instance : Tests {
    my $linter = Test::CodingStyle::Linter->new({
        rule_path => 't/lib',
        target    => [ 't/lib/Sample' ],
    });

    isa_ok $linter, 'Test::CodingStyle::Linter';
    is_deeply $linter->target, [qw(
        t/lib/Sample.pm
        t/lib/Sample
    )],
      'target includes sibling pm';
}

__PACKAGE__->runtests;
