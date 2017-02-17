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

    $self->valid_dynamic_db_names( $self->user_ds()->valid_dynamic_db_names() );

    return $self;
}

sub _init_get_methods {

    my $self = shift;

    my $method_in = shift;

    my $args = shift;

    my $method;

    # get_roles
    $method = GRNOC::WebService::Method->new( name => 'get_roles',
                                                   description => "Returns the Roles.",
                                                   expires => "-1d",
                                                   #default_order_by => ['name'],
                                                   callback => sub { $self->_get_table_dynamically( "role", $method_in, $args ) } );

    # add the optional 'role_id' input param to the get_roles() method
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
                                                   callback => sub { $self->_get_table_dynamically( "organization", $method_in, $args ) } );

    # add the optional 'organization_id' input param to the get_organizations() method
    $method->add_input_parameter( name        => 'organization_id',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 1,
                                  description => 'The id of the organization');

    $self->websvc()->register_method( $method );

    # get_ip_blocks
    $method = GRNOC::WebService::Method->new( name => 'get_ip_blocks',
                                                   description => "Returns the IP blocks.",
                                                   expires => "-1d",
                                                   #default_order_by => ['name'],
                                                   callback => sub { $self->_get_ip_blocks( @_ ) } );

    # add the optional 'ip_block_id' input param to the get_ip_blocks() method
    $method->add_input_parameter( name        => 'ip_block_id',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 1,
                                  description => 'The id of the IP block');

    $self->websvc()->register_method( $method );


}


### callbacks ###

sub _get_table_dynamically {

    my ( $self, $name, $method, $args ) = @_;

    my $result = $self->user_ds()->get_table_dynamically( $name, $self->process_args( $args ) );

    # handle error
    if ( !$result ) {

        $method->set_error( $self->user_ds()->error() );
        return;
    }

    return {'results' => $result->results(),
            'total' => $result->total(),
            'offset' => $result->offset(),
            'name' => $name,
            'warning' => $result->warning()};
}


sub _get_ip_blocks {

    my ( $self, $method, $args ) = @_;

    my $result = $self->user_ds()->get_ip_blocks( $self->process_args( $args ) );

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

