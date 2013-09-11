package Test::CodingStyle;
use strict;
use warnings;

our $VERSION = '0.01';

1;

__END__

=head1 NAME

Test::CodingStyle - run tests by original rule

=head1 SYNOPSIS

use Test::More;
use Test::CodingStyle::Finder;
use Test::CodingStyle::Linter;

my @errors;
my $linter = Test::CodingStyle::Linter->new({
    rule_path => 't/obey_rule/':
    target => [ q/lib/ ],
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

# Because of easier debug , display at last.
for my $error (@errors) {
    my $builder = Test::More->builder;
    $builder->ok(0, sprintf('%s :: %s at %s', @$error{qw/message title filename/}));
}

::done_testing;


=head1 DESCRIPTION

Test::CodingStyle is Testing module which run by original rule.
Original rule should be defined some directory & that directory is given as parameter named [rule_path].

Rule should be created as perl script which return hashref.

=head2 RULE_FILE_FORMAT

return +{
    title       => 'no_strict-no_life',
    description => q/ Checking for existing 'use strict' /,
    point       => 1,
    target_dir  => [qw( lib/Sample )],
    target_ext  => [qw( pm )],
    blacklist   => [qw( lib/Sample/BlackStrict.pm)],
    except_list => [qw( lib/Sample/PermitNoStrict.pm)],
    coderef     => sub{
        my $text = shift;
        if( $text =~ qr/^\s*use\sstrict/xms ){
            return 1;
        }
        else{
            return ( 0 , "must need 'use strict'");
        }
    },
}

Each keys have means.
    title       # Just Title. When Test finish , It is output.
    description # Just Description
    point       # When you want to have level of issue, you can set some MINOS point here. Default is 1.
    target_dir  # Tests run only under this directory recursive.Default is [lib]
    target_ext  # Tests run for this ext files.Default is [pm]
    blacklist   # If you have file which has already have bad code , you can skip that file by this list.
    except_list # If you have file which should be  permitted. you & calculator can skip that file by this list.
    coderef     # Rule is written here. you can get target file text as first parameter.
                # If $text is valid, have to be returned 1(TRUE).
                # Invalid case has to be return list
                #   First   : 0(FALSE)
                #   Second  : some message

=head1 AUTHOR

masartz E<lt>masartz@gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
