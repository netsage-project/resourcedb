package GRNOC::NetSage::ResourceDB::GWS::User;

use strict;
use warnings;

use GRNOC::Config;
use GRNOC::DatabaseQuery;
use GRNOC::WebService::Method;
use GRNOC::WebService::Regex;
use GRNOC::NetSage::ResourceDB::DataService::User;

use Data::Dumper;

our $websvc;

use base 'GRNOC::NetSage::ResourceDB::GWS';

sub new {

    my $caller = shift;

    my $class = ref( $caller );
    $class = $caller if ( !$class );

    my $self = $class->SUPER::new( @_ );

    bless( $self, $class );

    # get/store our data service
    $self->user_ds( GRNOC::NetSage::ResourceDB::DataService::User->new( @_ ) );

    return $self;
}

sub _init_get_methods {

    my $self = shift;

    my $method;

    # get_roles
    $method = GRNOC::WebService::Method->new( name => 'get_roles',
                                                   description => "Returns the Roles.",
                                                   expires => "-1d",
                                                   #default_order_by => ['name'],
                                                   callback => sub { $self->_get_roles( @_ ) } );

    # add the optional 'request_id' input param to the get_roles() method
    $method->add_input_parameter( name        => 'role_id',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 1,
                                  description => 'The id of the role');

    $self->websvc()->register_method( $method );


    # get_organizations
    $method = GRNOC::WebService::Method->new( name => 'get_organizations',
                                                   description => "Returns the Organizations.",
                                                   expires => "-1d",
                                                   #default_order_by => ['name'],
                                                   callback => sub { $self->_get_organizations( @_ ) } );

    # add the optional 'request_id' input param to the get_organizations() method
    $method->add_input_parameter( name        => 'organization_id',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 1,
                                  description => 'The id of the organization');

    $self->websvc()->register_method( $method );


}


### callbacks ###

sub _get_roles {

    my ( $self, $method, $args ) = @_;

    my $result = $self->user_ds()->get_roles( $self->process_args( $args ) );

    # handle error
    if ( !$result ) {

        $method->set_error( $self->user_ds()->error() );
        return;
    }

    return {'results' => $result->results(),
            'total' => $result->total(),
            'offset' => $result->offset(),
            'warning' => $result->warning()};
}


sub _get_organizations {

    my ( $self, $method, $args ) = @_;

    my $result = $self->user_ds()->get_organizations( $self->process_args( $args ) );

    # handle error
    if ( !$result ) {

        $method->set_error( $self->user_ds()->error() );
        return;
    }

    return {'results' => $result->results(),
            'total' => $result->total(),
            'offset' => $result->offset(),
            'warning' => $result->warning()};
}


1;

