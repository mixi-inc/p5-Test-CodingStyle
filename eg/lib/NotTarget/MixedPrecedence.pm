package NotTarget::MixedPrecedence;
use strict;
use warnings;

sub func{
    if( not 1 || 1 ){
        # not pass here
    }
    else{
        # pass here
    }
}

1;
