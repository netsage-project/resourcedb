#--------------------------------------------------------------------
#----- GRNOC NetSage ResourceDB DataService Result Library
#-----
#----- Copyright(C) 2017 The Trustees of Indiana University
#--------------------------------------------------------------------
#----- $HeadURL$
#----- $Id$
#-----
#----- This library stores results and additional metadata for rows
#----- returned from queries to the resource database.
#--------------------------------------------------------------------

package GRNOC::NetSage::ResourceDB::DataService::Result;

use strict;
use warnings;

sub new {

    my $caller = shift;

    my $class = ref( $caller );
    $class = $caller if ( !$class );

    my $self = {'results' => undef,
                'total' => undef,
                'offset' => undef,
                'warning' => undef,
                @_};

    bless( $self, $class );

    return $self;
}

sub results {

    my ( $self, $results ) = @_;

    if ( defined( $results ) ) {

        $self->{'results'} = $results;
    }

    return $self->{'results'};
}

sub total {

    my ( $self, $total ) = @_;

    if ( defined( $total ) ) {

        $self->{'total'} = $total;
    }

    return $self->{'total'};
}

sub offset {

    my ( $self, $offset ) = @_;

    if ( defined( $offset ) ) {

        $self->{'offset'} = $offset;
    }

    return $self->{'offset'};
}

sub warning {

    my ( $self, $warning ) = @_;

    if ( defined( $warning ) ) {

        $self->{'warning'} = $warning;
    }

    return $self->{'warning'};
}

1;
