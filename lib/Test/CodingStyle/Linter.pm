package Test::CodingStyle::Linter;

use utf8;
use strict;
use warnings;

=encoding utf-8

=head1 NAME

Test::CodingStyle::Linter

=head1 SYNOPSIS

    use Test::CodingStyle::Linter;

    my @errors;
    my $linter = Test::CodingStyle::Linter->new({
        target => [
            'lib/Sample1',
            'lib/Sample2',
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

=cut

use parent 'Class::Accessor::Fast';

use Params::Validate qw(ARRAYREF CODEREF SCALAR);
use File::Find qw//;
use File::Slurp;
use File::Spec;

use List::MoreUtils;
use Test::CodingStyle::Finder;
use Test::CodingStyle::Strip;

my @CALLBACK_NAMES = qw(
    before_process_file
    after_process_file
    before_lint
    after_lint
);
my $EMPTY_CALLBACK = sub {};

__PACKAGE__->mk_ro_accessors(qw(
    rule_path
    target
    include_guidelines
    exclude_guidelines
    execute_blacklist
), @CALLBACK_NAMES);


sub new {
    my $class = shift;
    my %options = Params::Validate::validate(@_, {
        rule_path          => { type => SCALAR},
        target             => { type => ARRAYREF },
        include_guidelines => { type => ARRAYREF, default => [] },
        exclude_guidelines => { type => ARRAYREF, default => [] },
        execute_blacklist  => { type => SCALAR, default => 0},
        (
            map {
                $_ => +{ type => CODEREF, default => $EMPTY_CALLBACK }
            } @CALLBACK_NAMES
        ),
    });

    $options{target} = [ map { (__sibling_pm_if_exists($_), $_) } @{$options{target}} ];
    return $class->SUPER::new(\%options);
}

sub __sibling_pm_if_exists {
    my $path = shift;
    my $pm = "$path.pm";

    return unless -f $pm;
    return $pm;
}

sub _is_guideline_included {
    my $self = shift;
    my ($guideline) = @_;

    return 1 if List::MoreUtils::any { $guideline->title eq $_ } @{ $self->include_guidelines };
    return 0 if List::MoreUtils::any { $guideline->title eq $_ } @{ $self->exclude_guidelines };

    return not @{ $self->include_guidelines };
}

sub guidelines {
    my $self = shift;

    unless ($self->{_guidelines}) {
        my @guidelines = Test::CodingStyle::Finder::find_guideline_plugins(
            $self->rule_path
        );
        $self->{_guidelines} = [ grep { $self->_is_guideline_included($_) } @guidelines ];
    }

    return $self->{_guidelines};
}

sub run_recent_files {
    my $self = shift;

    my $files = Test::CodingStyle::Finder::find_recent_updated_files();
    
    foreach my $file (@{$files}) {
        next unless List::MoreUtils::any { $file =~ /\A$_/ } @{$self->target};
        next unless -e $file;
        $self->_process_found_file($file);
    }
}

sub run {
    my $self = shift;

    File::Find::find({
        wanted => sub {
            my $file = $File::Find::name;
            $self->_process_found_file($file);
        },
        preprocess => sub {
            grep { $_ ne '.git' } @_;
        },
        no_chdir => 1,
    }, @{ $self->target });
}

sub _process_found_file {
    my ($self, $file) = @_;
    my @guidelines = @{ $self->guidelines };

    my $text;

    $self->before_process_file->($self, $file);
    for my $guideline (@guidelines) {
        my $is_blacklist = 0;
        next unless $guideline->has_target_ext($file);
        next unless $guideline->has_target_dir_pattern($file);
        if ($guideline->is_in_blacklist($file)) {
            next unless $self->execute_blacklist;
            $is_blacklist = 1;
        } 

        $text = __read_module_file($file) unless $text;

        $self->before_lint->($self, $file, {
            title    => $guideline->title,
            filename => $file,
            is_blacklist => $is_blacklist,
        });

        my ( $result, $message ) = $guideline->run($text);

        $self->after_lint->($self, $file, {
            title    => $guideline->title,
            filename => $file,
            message  => $message,
            result   => $result,
            is_blacklist => $is_blacklist,
        });
    }
    $self->after_process_file->($self, $file);
}

sub __read_module_file {
    my $file = shift;

    my $text  = File::Slurp::read_file($file);
    my $strip = Test::CodingStyle::Strip->new;

    return $strip->strip($text);
}


1;
