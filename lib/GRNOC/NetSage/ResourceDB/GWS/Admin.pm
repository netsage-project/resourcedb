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

sub _init_get_methods {
    my $self = shift;

    my $method;

    # --get_users
    $method = GRNOC::WebService::Method->new( name => 'get_users',
                                                   description => "Returns info about users.",
                                                   expires => "-1d",
                                                   #default_order_by => ['name'],
                                                   callback => sub { $self->_get_users( @_ ) } );

    # add the optional 'user_id' input param to the get_users() method
    $method->add_input_parameter( name        => 'user_id',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 1,
                                  description => 'The id (username) of the user');

    $self->websvc()->register_method($method);

    # --get_loggedin_user
    $method = GRNOC::WebService::Method->new( name => 'get_loggedin_user',
                                                   description => "Returns info about the user that is currently logged in and adds them to the database if they are not there.",
                                                   expires => "-1d",
                                                   callback => sub { $self->_get_loggedin_user( @_ ) } );

    $self->websvc()->register_method($method);
}

sub _init_add_methods {
    my $self = shift;

    my $method;

    $self->valid_dynamic_db_names( $self->user_ds()->valid_dynamic_db_names() );

    $self->_init_dynamic_add_methods( @_ );

    # --add_user
    $method = GRNOC::WebService::Method->new( name => 'add_user',
                                                   description => "Adds a user to the database.",
                                                   expires => "-1d",
                                                   callback => sub { $self->_add_user( @_ ) } );

    # add the required user_id (ie, username from .htaccess file) input param to the  method
    $method->add_input_parameter( name        => 'user_id',
                                  pattern     => $TEXT,
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'The user_id (ie, username)');

    # add the optional name input param to the  method
    $method->add_input_parameter( name        => 'name',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The name of the user (first and last)');

    $self->websvc()->register_method( $method );

    # --add_ip_blocks
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

    # --add_events
    $method = GRNOC::WebService::Method->new( name => 'add_events',
                                                   description => "Adds the specified events.",
                                                   expires => "-1d",
                                                   callback => sub { $self->_add_events( @_ ) } );
    $method->add_input_parameter( name        => 'message',
                                  pattern     => $TEXT,
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'The event message');
    $method->add_input_parameter( name        => 'ip_block_id',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The event ip_block_id');
    $method->add_input_parameter( name        => 'project_id',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The event project_id');
    $method->add_input_parameter( name        => 'organization_id',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The event organization_id');
    $method->add_input_parameter( name        => 'user_id',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The event user_id');
    $self->websvc()->register_method( $method );

    # --add_projects
    $method = GRNOC::WebService::Method->new( name => 'add_projects',
                                              description => "Adds the specified projects.",
                                              expires => "-1d",
                                              callback => sub { $self->_add_projects( @_ ) } );
    $method->add_input_parameter( name        => 'name',
                                  pattern     => $TEXT,
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'The event message');
    $method->add_input_parameter( name        => 'description',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The event ip_block_id');
    $method->add_input_parameter( name        => 'url',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The event project_id');
    $method->add_input_parameter( name        => 'owner',
                                  pattern     => $TEXT,
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'The event organization_id');
    $method->add_input_parameter( name        => 'email',
                                  pattern     => $TEXT,
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'The event user_id');
    $self->websvc()->register_method($method);
}

sub _init_update_methods {
    my $self = shift;

    my $method;

    $self->valid_dynamic_db_names( $self->user_ds()->valid_dynamic_db_names() );

    $self->_init_dynamic_update_methods( @_ );


    # --update_ip_blocks
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


    # --delete_ip_blocks
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

    # add the optional 'description' input param to the method
    $method->add_input_parameter( name        => 'description',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The description of the ip resource block');


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
        my $plural = $self->get_plural( $name );
        my $method;
        # add
        $method = GRNOC::WebService::Method->new( name => "add_$plural",
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

        # add the optional 'description' input param to all the basic dynamic methods
        $method->add_input_parameter( 
            name        => 'description',
            pattern     => $TEXT,
            required    => 0,
            multiple    => 0,
            description => "The description of the $name");


        $self->_add_dynamic_add_update_parameters( $name, $method );

        $self->websvc()->register_method( $method );

    }


}

sub _add_dynamic_add_update_parameters {
    my ( $self, $name, $method ) = @_;

    # add dynamic fields here
    my $field_obj = $self->dynamic_fields();
    my @field_list = keys %{ $field_obj->{ $name } };

    foreach my $field ( @field_list ) {
        # add optional webservice parameter
        if ( $field eq "owner" ) {
            # add the optional 'owner' input param to all the basic dynamic methods
            $method->add_input_parameter(
                name        => $field,
                pattern     => $TEXT,
                multiple    => 0,
                required    => 0,
                description => "The owner of the $name");

        } elsif ( $field eq "country_code" || $field eq "continent_code" ) {
            # add the optional 'country_code' or 'continent_code' input param to all the basic dynamic methods
            $method->add_input_parameter(
                name        => $field,
                pattern     => $TEXT,
                multiple    => 0,
                required    => 0,
                description => "The code of the $name");

        } elsif ( $field eq "url" ) {
            # add the optional 'url' input param to all the basic dynamic methods
            $method->add_input_parameter(
                name        => $field,
                pattern     => $TEXT,
                multiple    => 0,
                required    => 0,
                description => "The url of the $name");

        } elsif ( $field eq "email" ) {
            # add the optional 'email' input param to all the basic dynamic methods
            $method->add_input_parameter(
                name        => $field,
                pattern     => $TEXT,
                multiple    => 0,
                required    => 0,
                description => "The email of the $name");

        } elsif ( $field eq "postal_code" ) {
            # add the optional 'postal code' input param to all the basic dynamic methods
            $method->add_input_parameter(
                name        => $field,
                pattern     => $TEXT,
                multiple    => 0,
                required    => 0,
                description => "The postal code of the $name");

        } elsif ( $field eq "latitude" ) {
            # add the optional 'latitude' input param to all the basic dynamic methods
            $method->add_input_parameter(
                name        => $field,
                pattern     => $FLOAT,
                required    => 0,
                multiple    => 0,
                description => "The latitude of the $name");


        } elsif ( $field eq "longitude" ) {
            # add the optional 'longitude' input param to all the basic dynamic methods
            $method->add_input_parameter(
                name        => $field,
                pattern     => $FLOAT,
                required    => 0,
                multiple    => 0,
                description => "The longitude of the $name");

        } elsif ( $field eq "country_name" ) {
            # add the optional 'country name' input param to all the basic dynamic methods
            $method->add_input_parameter(
                name        => $field,
                pattern     => $TEXT,
                required    => 0,
                multiple    => 0,
                description => "The country name of the $name");

        } elsif ( $field eq "continent_name" ) {
            # add the optional 'continent_name' input param to all the basic dynamic methods
            $method->add_input_parameter(
                name        => $field,
                pattern     => $TEXT,
                required    => 0,
                multiple    => 0,
                description => "The continent_name of the $name");

        }
    }
}

sub _init_dynamic_update_methods {
    my $self = shift;

    foreach my $name ( keys %{ $self->valid_dynamic_db_names() } ) {
        my $plural = $self->get_plural( $name );
        my $method;
        # add
        $method = GRNOC::WebService::Method->new( name => "update_$plural",
            description => "Updates the $plural",
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
            required    => 0,
            multiple    => 0,
            description => "The name of the $name");

        # add the optional 'description' input param to all the basic dynamic methods
        $method->add_input_parameter( 
            name        => 'description',
            pattern     => $TEXT,
            required    => 0,
            multiple    => 0,
            description => "The description of the $name");

        $self->_add_dynamic_add_update_parameters( $name, $method );

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


### CALLBACKS - get methods

sub _get_users {
    my ( $self, $method, $args ) = @_;

    my $result = $self->admin_ds()->get_users( $self->process_args( $args ) );
    if ( !$result ) {
        $method->set_error( $self->admin_ds()->error() );
        return;
    }

    return {'results' => $result->results(),
            'total' => $result->total(),
            'offset' => $result->offset(),
            'warning' => $result->warning()};
}

sub _get_loggedin_user {
    my ( $self, $method, $args ) = @_;

    my $result = $self->admin_ds()->get_loggedin_user( $self->process_args( $args ) );

    if ( !$result ) {
        $method->set_error( $self->admin_ds()->error() );
        return;
    }

    return {'results' => $result->results(),
            'total' => $result->total(),
            'offset' => $result->offset(),
            'warning' => $result->warning()};
}

### CALLBACKS - add methods

sub _add_user {
    my ( $self, $method, $args ) = @_;

    my $result = $self->admin_ds()->add_user( $self->process_args( $args ) );
    if ( !$result ) {
        $method->set_error( $self->admin_ds()->error() );
        return;
    }

    return { 'results' => $result };

}
sub _add_ip_blocks {
    my ( $self, $method, $args ) = @_;

    my $result = $self->admin_ds()->add_ip_blocks( $self->process_args( $args ) );
    if ( !$result ) {
        $method->set_error( $self->admin_ds()->error() );
        return;
    }

    return { 'results' => $result };
}

sub _add_events {
    my ( $self, $method, $args ) = @_;

    my $result = $self->admin_ds()->add_events( $self->process_args( $args ) );
    if ( !$result ) {
        $method->set_error( $self->admin_ds()->error() );
        return;
    }

    return { 'results' => $result };
}

sub _add_projects {
    my ( $self, $method, $args ) = @_;

    my $result = $self->admin_ds()->add_projects( $self->process_args( $args ) );
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

