package GRNOC::NetSage::ResourceDB::DataService::User;

use strict;
use warnings;

use GRNOC::Config;
use GRNOC::DatabaseQuery;

use Data::Dumper;

use base 'GRNOC::NetSage::ResourceDB::DataService';

my $singleton;

### constructor ###
sub new {

    my $caller = shift;

    my $class = ref( $caller );
    $class = $caller if ( !$class );

    # if we've created this object (singleton) before, just return it
    return $singleton if ( defined( $singleton ) );

    my $self = $class->SUPER::new( @_ );

    bless( $self, $class );

    # store our newly created object as the singleton
    $singleton = $self;

    # get/store the mongodb handle
    #$self->mongo_rw( GRNOC::TSDS::MongoDB->new( @_, privilege => 'rw' ) );
    #$self->mongo_ro( GRNOC::TSDS::MongoDB->new( @_, privilege => 'ro' ) );

    # store the other dataservices
    #$self->metadata( GRNOC::TSDS::DataService::MetaData->new( @_ ) );

    my $config = GRNOC::Config->new( config_file => $self->{'config_file'}, force_array => 0);
    $self->{'config'} = $config;
    #$self->{'proxy_users'} = $config->get('/config/proxy-users/username') || [];

    # Make sure it's an array, we set force_array to 0 above but we always
    # assume that the proxy users are in array form
    #$self->{'proxy_users'} = [$self->{'proxy_users'}] if (! ref $self->{'proxy_users'});

    return $self;
}

sub get_roles {

    my ( $self, %args ) = @_;

    my $role_id = $args{'role_id'};
    my $order_by = $args{'order_by'};
    my $order = $args{'order'};
    my $limit = $args{'limit'};
    my $offset = $args{'offset'};


    my $sort = {};
    $sort->{'order'} = $order if $order;
    $sort->{'order_by'} = $order_by if $order_by;
    $sort->{'offset'} = $offset if $offset;
    $sort->{'limit'} = $limit if $limit;

    my $find = $self->format_find(
        field  => 'role_id',
        values => $role_id
    ); 

    my $results = $self->_get_roles($find, $sort);
    if ( !$results ) {
        $self->error( "Error getting roles" );
        return;
    }

    return $results;
}


### callbacks ###
sub _get_roles {

    my ( $self, $method, $args ) = @_;

    #my $result = $self->{'dataservice'}->get_requests( remote_user => $ENV{'REMOTE_USER'},
    #                                                   $self->process_args( $args ) );

    my $result; # TODO: fix
    # handle error
    if ( !$result ) {

        #$self->error( $self->{'dataservice'}->error() );
        return;
    }

    return {'results' => $result->results(),
            'total' => $result->total(),
            'offset' => $result->offset(),
            'warning' => $result->warning()};
}

1;

