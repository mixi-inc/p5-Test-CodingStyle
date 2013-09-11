# NAME

Test::CodingStyle - run tests by original rule

# SYNOPSIS

use Test::More;
use Test::CodingStyle::Finder;
use Test::CodingStyle::Linter;

my @errors;
my $linter = Test::CodingStyle::Linter->new({
    rule\_path => 't/obey\_rule/':
    target => \[ q/lib/ \],
    after\_lint => sub {
        my ($linter, $filename, $info) = @\_;
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

\# Because of easier debug , display at last.
for my $error (@errors) {
    my $builder = Test::More->builder;
    $builder->ok(0, sprintf('%s :: %s at %s', @$error{qw/message title filename/}));
}

::done\_testing;



# DESCRIPTION

Test::CodingStyle is Testing module which run by original rule.
Original rule should be defined some directory & that directory is given as parameter named \[rule\_path\].

Rule should be created as perl script which return hashref.

## RULE\_FILE\_FORMAT

return +{
    title       => 'no\_strict-no\_life',
    description => q/ Checking for existing 'use strict' /,
    point       => 1,
    target\_dir  => \[qw( lib/Sample )\],
    target\_ext  => \[qw( pm )\],
    blacklist   => \[qw( lib/Sample/BlackStrict.pm)\],
    except\_list => \[qw( lib/Sample/PermitNoStrict.pm)\],
    coderef     => sub{
        my $text = shift;
        if( $text =~ qr/^\\s\*use\\sstrict/xms ){
            return 1;
        }
        else{
            return ( 0 , "must need 'use strict'");
        }
    },
}

Each keys have means.
    title       \# Just Title. When Test finish , It is output.
    description \# Just Description
    point       \# When you want to have level of issue, you can set some MINOS point here. Default is 1.
    target\_dir  \# Tests run only under this directory recursive.Default is \[lib\]
    target\_ext  \# Tests run for this ext files.Default is \[pm\]
    blacklist   \# If you have file which has already have bad code , you can skip that file by this list.
    except\_list \# If you have file which should be  permitted. you & calculator can skip that file by this list.
    coderef     \# Rule is written here. you can get target file text as first parameter.
                \# If $text is valid, have to be returned 1(TRUE).
                \# Invalid case has to be return list
                \#   First   : 0(FALSE)
                \#   Second  : some message

# AUTHOR

masartz <masartz@gmail.com>

# SEE ALSO

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
