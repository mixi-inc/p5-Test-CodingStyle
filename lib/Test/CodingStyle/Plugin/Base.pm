package Test::CodingStyle::Plugin::Base;

use utf8;
use strict;
use warnings;

use Carp qw(confess);

sub is_target_file {
    my $self = shift;
    my ($filepath) = @_;

    return 1;
}

sub title {
    confess 'abstract method';
}

sub run {
    my $text = shift;

    confess 'abstract method';
}


1;
