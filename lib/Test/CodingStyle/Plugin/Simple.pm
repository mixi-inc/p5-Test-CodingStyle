package Test::CodingStyle::Plugin::Simple;

use utf8;
use strict;
use warnings;

use parent qw(
    Test::CodingStyle::Plugin::Base
    Class::Accessor::Fast
);

use List::MoreUtils;
use Params::Validate qw(SCALAR ARRAYREF CODEREF);
use File::Spec;

__PACKAGE__->mk_ro_accessors(qw(
    title
    description
    point
    target_dir
    target_ext
    config_filepath
    blacklist
    except_list
    coderef
));

sub new {
    my $class = shift;
    my %options = Params::Validate::validate(@_, {
        title           => { type => SCALAR },
        description     => { type => SCALAR, default => '' },
        point           => { type => SCALAR, default => 0 },
        target_dir      => { 
            type    => SCALAR|ARRAYREF,
            default => [qw(lib)]
        },
        target_ext      => { type => ARRAYREF, default => [qw(pm)] },
        coderef         => { type => CODEREF },
        config_filepath => { type => SCALAR, optional => 1 },
        blacklist       => { type => ARRAYREF, default => [] },
        except_list     => { type => ARRAYREF, default => [] },
    });

    return $class->SUPER::new(\%options);
}

sub target_dir_paths {
    my $self = shift;
    return map {
        $_ !~ /\/\z/ ? "$_/" : $_;
    } @{ $self->target_dir };
}

sub _ignore_paths {
    my $self = shift;
    return (@{ $self->blacklist }, @{ $self->except_list });
}

sub _target_dir_patterns {
    my $self = shift;
    my $patterns = $self->{_target_dir_patterns};

    unless (defined $patterns) {
        $patterns = $self->{_target_dir_patterns} = [ map {
            qr{(\A|/)\Q$_\E};
        } $self->target_dir_paths ];
    }

    return @$patterns;
}

sub _ignore_paths_and_pattern {
    my $self = shift;

    unless (exists $self->{_ignore_paths_hash}) {
        my %paths;
        my @patterns;

        for my $path ($self->_ignore_paths) {
            # "/" で終わるディレクトリ名なら前方一致、そうでなければ完全一致
            if ($path =~ m!/\z!) {
                push @patterns, "^\Q$path\E";
            }
            else {
                $paths{$path} = 1;
            }
        }

        $self->{_ignore_paths_hash} = \%paths;
        if ( my $pattern = join '|', @patterns ) {
            $self->{_ignore_path_pattern} = qr/$pattern/;
        }
    }

    return ($self->{_ignore_paths_hash}, $self->{_ignore_path_pattern});
}

sub is_target_file {
    my $self = shift;
    my ($filepath) = @_;

    return $self->has_target_ext($filepath) && (!$self->is_in_blacklist($filepath))
        && $self->has_target_dir_pattern($filepath);
}

sub has_target_ext {
    my $self = shift;
    my ($filepath) = @_;

    my $target_ext_list = join '|', @{$self->target_ext};
    return unless $filepath =~ /\.(?:$target_ext_list)\z/;
    return 1;
}

sub is_in_blacklist {
    my $self = shift;
    my ($filepath) = @_;
    my ($paths, $pattern) = $self->_ignore_paths_and_pattern;

    return 1 if exists $paths->{$filepath};
    return 1 if $pattern && $filepath =~ $pattern;
    return 0;
}

sub has_target_dir_pattern {
    my $self = shift;
    my ($filepath) = @_;
    return List::MoreUtils::any { $filepath =~ $_ } $self->_target_dir_patterns;
}

sub find_missing_files_in_blacklist {
    my $self = shift;
    return [ grep { ! -e $_ } @{ $self->blacklist } ];
}

sub run {
    my $self = shift;
    $self->coderef->(@_);
}


1;
