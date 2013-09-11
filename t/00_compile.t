use strict;
use Test::More;

BEGIN { 
    use_ok 'Test::CodingStyle';
    use_ok 'Test::CodingStyle::Finder';
    use_ok 'Test::CodingStyle::Linter';
    use_ok 'Test::CodingStyle::Strip';
    use_ok 'Test::CodingStyle::Plugin::Base';
    use_ok 'Test::CodingStyle::Plugin::Simple';
}
done_testing();
