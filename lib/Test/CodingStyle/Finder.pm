package Test::CodingStyle::Finder;
use strict;
use warnings;

use IPC::Cmd qw//;
use Path::Class;
use Test::CodingStyle::Plugin::Simple;

sub find_guideline_list{
    my $dir_path = shift;
    my $dir = dir $dir_path ;

    my @guideline_files;
    for my $file ( $dir->children ){
        if( -e $file && $file =~ /\.pl\z/ ){
            push @guideline_files , $file;
        }
    }
    return @guideline_files;
}

sub find_guideline_plugins {
    my $guideline_path = shift;
    my @guideline_list = find_guideline_list( $guideline_path );

    return map {
        my $filepath = $_;
        my $config = do $filepath;

        Test::CodingStyle::Plugin::Simple->new({
            config_filepath => "$filepath",
            blacklist       => [],
            except_list     => [],
            %$config,
        });
    } @guideline_list;
}

sub find_recent_updated_files {
    my $command = "git log --since=1.week --name-only --pretty=format:'' | egrep '.+' | egrep -v '^t/' | sort | uniq";
    my $result;
    my ($success, $error_message, $buffer, $stdout, $stderr) = IPC::Cmd::run(
        command => $command,
        verbose => 0,
    );
    if ($success && (scalar @$stderr == 0)) {        
        $result = join "", @$buffer;
    } else {        
        die (join "", @$stderr);
    }

    my @files;
    foreach my $file (split(/\n/, $result)) {        
        push @files, $file;
    }
    return \@files;
}

1;
