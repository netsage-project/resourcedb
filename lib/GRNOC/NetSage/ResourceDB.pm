#--------------------------------------------------------------------
#----- GRNOC NetSage ResourceDB Library
#-----
#----- Copyright(C) 2017 The Trustees of Indiana University
#--------------------------------------------------------------------
#----- This module doesn't do much other than storing the version.
#----- The Frontend and DataService libraries are where most of the
#----- logic is.
#--------------------------------------------------------------------

package GRNOC::NetSage::ResourceDB;

use strict;
use warnings;

our $VERSION = '0.1.0';

sub new {

    my $caller = shift;

    my $class = ref( $caller );
    $class = $caller if ( !$class );

    my $self = {
        @_
    };

    bless( $self, $class );

    return $self;
}

sub get_version {

    my $self = shift;

    return $VERSION;
}

1;
