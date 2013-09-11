package Test::CodingStyle::Strip; 

use utf8;
use strict;
use warnings;

sub new {
    bless +{}, shift;
}

sub strip {
    my $self = shift;
    return $self->_strip_comment($self->_strip_pod($_[0]));
}

sub _strip_pod {
    my $self = shift;
    my $pod = 0;
    my @podless_lines;

    # Pod::Strip is too slow
    for my $line (split /\n/, $_[0]) {
        $pod = 1 if $line =~ /^=\w/;
        if ($line =~ /^=cut/) {
            $pod = 0;
            next;
        }
        last if $line =~ /^__END__$/;
        next if $pod;
        push @podless_lines, $line;
    }

    return join "\n", @podless_lines;
}

sub _strip_comment {
    my $self = shift;
    my $text = shift;

    # comment is stripped excepting with shebang
    $text =~ s/#$//mg;
    $text =~ s/#[^!].*$//mg;

    return $text;
}


1;
