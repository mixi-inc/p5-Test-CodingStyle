use utf8;
use strict;
use warnings;

use Test::More;
use Test::CodingStyle::Finder;
use Test::CodingStyle::Linter;

my @errors;
my $linter = Test::CodingStyle::Linter->new({
    rule_path => './obey_rule/',
    target => [
        'lib',
    ],
    after_lint => sub {
        my ($linter, $filename, $info) = @_;
        my $builder = Test::More->builder;

        if ($info->{result}) {
            $builder->ok(1, sprintf('%s at %s', @$info{qw/title filename/}));
        }
        else {
            push @errors, $info;
        }
    },
});

$linter->run;
::ok(1, 'dummy');

# Beacause of easier debug , display at last.
for my $error (@errors) {
    my $builder = Test::More->builder;
    $builder->ok(0, sprintf('%s :: %s at %s', @$error{qw/message title filename/}));
}

::done_testing;

__END__

=encoding utf8

=head1 NAME

sample_obey.t

=cut
