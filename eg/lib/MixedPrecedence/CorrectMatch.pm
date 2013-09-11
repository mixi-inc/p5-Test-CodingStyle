package MixedPrecedence::Permit;
use strict;
use warnings;

sub func_1{
    if( not 1 or 1 and 1 ){
        # pass here
    }
    else{
        # not pass here
    }
}

sub func_2{
    if( ! 1 || 1 && 1 ){
        # pass here
    }
    else{
        # not pass here
    }
}

1;
