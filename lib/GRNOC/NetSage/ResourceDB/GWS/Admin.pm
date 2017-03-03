package GRNOC::NetSage::ResourceDB::GWS::Admin;

use strict;
use warnings;

use GRNOC::Config;
use GRNOC::DatabaseQuery;
use GRNOC::WebService::Method;
use GRNOC::WebService::Regex;
use GRNOC::NetSage::ResourceDB::DataService::Admin;

use Data::Dumper;

our $websvc;

use base 'GRNOC::NetSage::ResourceDB::GWS';

sub new {

    my $caller = shift;

    my $class = ref( $caller );
    $class = $caller if ( !$class );

    my $self = $class->SUPER::new( @_ );

    bless( $self, $class );


    return $self;
}

sub _init_add_methods {
    my $self = shift;

    my $method;

    $self->valid_dynamic_db_names( $self->user_ds()->valid_dynamic_db_names() );

    $self->_init_dynamic_add_methods( @_ );


    # add_ip_blocks
    $method = GRNOC::WebService::Method->new( name => 'add_ip_blocks',
                                                   description => "Adds the specified IP blocks.",
                                                   expires => "-1d",
                                                   callback => sub { $self->_add_ip_blocks( @_ ) } );

    # add the required 'addr_str' input param to the  method
    $method->add_input_parameter( name        => 'addr_str',
                                  pattern     => $TEXT,
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'The address string (CIDR)');

    $self->_add_ip_block_params( $method );

    $self->websvc()->register_method( $method );

}

sub _init_update_methods {
    my $self = shift;

    my $method;

    $self->valid_dynamic_db_names( $self->user_ds()->valid_dynamic_db_names() );

    $self->_init_dynamic_update_methods( @_ );


    # update_ip_blocks
    $method = GRNOC::WebService::Method->new( name => 'update_ip_blocks',
                                                   description => "Updates the specified IP blocks.",
                                                   expires => "-1d",
                                                   callback => sub { $self->_update_ip_blocks( @_ ) } );

    # add the required 'ip_block_id' input param to the update_ip_blocks() method
    $method->add_input_parameter( name        => 'ip_block_id',
                                  pattern     => $INTEGER,
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'The id of the IP block');

    # add the required 'addr_str' input param to the  method
    $method->add_input_parameter( name        => 'addr_str',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The address string (CIDR)');

    $self->_add_ip_block_params( $method );

    $self->websvc()->register_method( $method );

}

sub _init_delete_methods {
    my $self = shift;

    my $method;

    #$self->valid_dynamic_db_names( $self->user_ds()->valid_dynamic_db_names() );

    $self->_init_dynamic_delete_methods( @_ );


    # delete_ip_blocks
    $method = GRNOC::WebService::Method->new( name => 'delete_ip_blocks',
                                                   description => "Deletes the specified IP blocks.",
                                                   expires => "-1d",
                                                   callback => sub { $self->_delete_ip_blocks( @_ ) } );

    # add the required 'ip_block_id' input param to the delete_ip_blocks() method
    $method->add_input_parameter( name        => 'ip_block_id',
                                  pattern     => $INTEGER,
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'The id of the IP block to delete');

    $self->websvc()->register_method( $method );

}

sub _add_ip_block_params {
    my ( $self, $method ) = @_;

    # add the optional 'name' input param to the  method
    $method->add_input_parameter( name        => 'name',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The name of the ip resource block');


    # add the optional 'asn' input param to the  method
    $method->add_input_parameter( name        => 'asn',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The ASN of the IP block');

    # add the optional 'organization_id' input param to the  method
    $method->add_input_parameter( name        => 'organization_id',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The organization id');

    # add the optional 'discipline_id' input param to the  method
    $method->add_input_parameter( name        => 'discipline_id',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The discipline id');

    # add the optional 'role_id' input param to the  method
    $method->add_input_parameter( name        => 'role_id',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The role id');

    # add the optional 'project_id' input param to the  method
    $method->add_input_parameter( name        => 'project_id',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The project id');

    # add the optional 'country_code' input param to the  method
    $method->add_input_parameter( name        => 'country_code',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The country code');

    # add the optional 'country_name' input param to the  method
    $method->add_input_parameter( name        => 'country_name',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The country name');


    # add the optional 'continent_code' input param to the  method
    $method->add_input_parameter( name        => 'continent_code',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The continent code');

    # add the optional 'continent_name' input param to the  method
    $method->add_input_parameter( name        => 'continent_name',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The continent name');

    # add the optional 'postal_code' input param to the  method
    $method->add_input_parameter( name        => 'postal_code',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The postal code');

    # add the optional 'latitude' input param to the  method
    $method->add_input_parameter( name        => 'latitude',
                                  pattern     => $FLOAT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The latitude');

    # add the optional 'longitude' input param to the  method
    $method->add_input_parameter( name        => 'longitude',
                                  pattern     => $FLOAT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The longitude');
    return $method;
}

sub _init_dynamic_add_methods {
    my $self = shift;

    foreach my $name ( keys %{ $self->valid_dynamic_db_names() } ) {
        my $method;
        # add
        $method = GRNOC::WebService::Method->new( name => "add_${name}s",
            description => "Adds the ${name}",
            expires => "-1d",
            callback => sub { $self->_add_table_dynamically( $name, @_ ) } );

        # add the required 'name' input param to all the basic dynamic methods
        $method->add_input_parameter( 
            name        => 'name',
            pattern     => $TEXT,
            required    => 1,
            multiple    => 0,
            description => "The name of the $name");

        $self->websvc()->register_method( $method );



    }


}

sub _init_dynamic_update_methods {
    my $self = shift;

    foreach my $name ( keys %{ $self->valid_dynamic_db_names() } ) {
        my $method;
        # add
        $method = GRNOC::WebService::Method->new( name => "update_${name}s",
            description => "Updates the ${name}",
            expires => "-1d",
            callback => sub { $self->_update_table_dynamically( $name, @_ ) } );

        # add the required 'id' input param to all the basic dynamic methods
        $method->add_input_parameter(
            name        => "${name}_id",
            pattern     => $NUMBER_ID,
            required    => 1,
            multiple    => 0,
            description => "The id of the $name");

        # add the required 'name' input param to all the basic dynamic methods
        $method->add_input_parameter(
            name        => 'name',
            pattern     => $TEXT,
            required    => 1,
            multiple    => 0,
            description => "The name of the $name");

        $self->websvc()->register_method( $method );

    }


}

sub _init_dynamic_delete_methods {
    my $self = shift;

    foreach my $name ( keys %{ $self->valid_dynamic_db_names() } ) {
        my $method;
        # add
        $method = GRNOC::WebService::Method->new( name => "delete_${name}s",
            description => "Deletes the ${name}",
            expires => "-1d",
            callback => sub { $self->_delete_table_dynamically( $name, @_ ) } );

        # add the required 'id' input param to all the basic dynamic methods
        $method->add_input_parameter(
            name        => "${name}_id",
            pattern     => $NUMBER_ID,
            required    => 1,
            multiple    => 0,
            description => "The id of the $name");

        $self->websvc()->register_method( $method );

    }


}


### callbacks ###

sub _add_table_dynamically {

    my ( $self, $name, $method, $args ) = @_;

    my $result = $self->admin_ds()->add_table_dynamically( $name, $self->process_args( $args ) );

    # handle error
    if ( !$result ) {

        $method->set_error( $self->admin_ds()->error() );
        return;
    }

    return { 'results' => $result };
}

sub _update_table_dynamically {

    my ( $self, $name, $method, $args ) = @_;

    my $result = $self->admin_ds()->update_table_dynamically( $name, $self->process_args( $args ) );

    # handle error
    if ( !$result ) {

        $method->set_error( $self->admin_ds()->error() );
        return;
    }

    return { 'results' => $result };
}

sub _delete_table_dynamically {

    my ( $self, $name, $method, $args ) = @_;

    my $result = $self->admin_ds()->delete_table_dynamically( $name, $self->process_args( $args ) );

    # handle error
    if ( !$result ) {

        $method->set_error( $self->admin_ds()->error() );
        return;
    }

    return { 'results' => $result };
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


### CALLBACKS - add methods

sub _add_ip_blocks {

    my ( $self, $method, $args ) = @_;

    my $result = $self->admin_ds()->add_ip_blocks( $self->process_args( $args ) );

    # handle error
    if ( !$result ) {

        $method->set_error( $self->admin_ds()->error() );
        return;
    }

    return { 'results' => $result };
}


### CALLBACKS - update methods

sub _update_ip_blocks {

    my ( $self, $method, $args ) = @_;

    my $result = $self->admin_ds()->update_ip_blocks( $self->process_args( $args ) );

    # handle error
    if ( !$result ) {

        $method->set_error( $self->admin_ds()->error() );
        return;
    }

    return { 'results' => $result };

}

### CALLBACKS - delete methods

sub _delete_ip_blocks {

    my ( $self, $method, $args ) = @_;

    my $result = $self->admin_ds()->delete_ip_blocks( $self->process_args( $args ) );

    # handle error
    if ( !$result ) {

        $method->set_error( $self->admin_ds()->error() );
        return;
    }

    return { 'results' => $result };

}


1;

