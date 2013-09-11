use strict;
use warnings;
use utf8;
use parent 'Test::Class';
use lib 't/lib';
use Test::More;
use Test::CodingStyle::Plugin::Simple;

sub make_plugin {
    my %options = @_;
    Test::CodingStyle::Plugin::Simple->new({
        title   => 'DUMMY',
        coderef => sub {1},
        %options,
    });
}

sub new_instance : Tests {
    my $plugin = make_plugin;
    isa_ok $plugin, 'Test::CodingStyle::Plugin::Simple';
}

my @TEST_FILES = qw(
    t/lib/Sample.pm
    t/lib/Sample/Module1.pm
    t/lib/Sample/Module2.pm
);

sub empty_blacklist : Tests {
    my $plugin = make_plugin( blacklist => [] );
    for my $file (@TEST_FILES) {
        ok $plugin->is_target_file($file), $file;
    }
}

sub one_blacklist : Tests {
    my @test_files = @TEST_FILES;
    my $blackfile  = shift @test_files;
    my $plugin = make_plugin( blacklist => [$blackfile] );

    ok !$plugin->is_target_file($blackfile), $blackfile;
    for my $file (@test_files) {
        ok $plugin->is_target_file($file), $file;
    }
}

sub directory_blacklist : Tests {
    my $plugin = make_plugin( blacklist => [ 't/lib/Sample/' ] );

    ok $plugin->is_target_file($TEST_FILES[0]), 'white file';
    ok !$plugin->is_target_file($TEST_FILES[1]), 'black file 1';
    ok !$plugin->is_target_file($TEST_FILES[2]), 'black file 2';
}

__PACKAGE__->runtests;
