return +{
    title       => 'no_strict-no_life',
    description => q/ Checking for existing 'use strict' /,
    point       => 1,
    target_dir  => [qw( lib/Strict )],
    target_ext  => [qw( pm )],
    blacklist   => [qw( lib/Strict/Black.pm)],
    except_list => [qw( lib/Strict/Permit.pm)],
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

