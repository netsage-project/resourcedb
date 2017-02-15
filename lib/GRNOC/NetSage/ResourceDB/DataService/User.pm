package GRNOC::NetSage::ResourceDB::DataService::User;

use strict;
use warnings;

use GRNOC::Config;
use GRNOC::DatabaseQuery;
use GRNOC::WebService::Dispatcher;
use GRNOC::WebService::Regex;

use HTML::Parser;
use Data::Dumper;

use base 'GRNOC::NetSage::ResourceDB::DataService';


### callbacks ###
sub _get_roles {

    my ( $self, $method, $args ) = @_;

    my $result = $self->{'dataservice'}->get_requests( remote_user => $ENV{'REMOTE_USER'},
                                                       $self->process_args( $args ) );

    # handle error
    if ( !$result ) {

        $method->set_error( $self->{'dataservice'}->error() );
        return;
    }

    return {'results' => $result->results(),
            'total' => $result->total(),
            'offset' => $result->offset(),
            'warning' => $result->warning()};
}

1;

