requires 'Carp';
requires 'Class::Accessor::Fast';
requires 'File::Find';
requires 'File::Slurp';
requires 'File::Spec';
requires 'IPC::Cmd';
requires 'List::MoreUtils';
requires 'Params::Validate';
requires 'Path::Class';
requires 'Test::More';

on build => sub {
    requires 'ExtUtils::MakeMaker', '6.36';
    requires 'Test::Class';
};
