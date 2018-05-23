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

sub _get_dynamic_where_parameters {
    my ( $self, $method ) = @_;
    foreach my $name ( keys %{ $self->valid_dynamic_db_names() } ) {
        # add the optional 'name_id' input param to the get_$names() method
        $method->add_input_parameter( name        => "${name}_id",
            pattern     => $INTEGER,
            required    => 0,
            multiple    => 1,
            description => "The id of the $name");
    }
}

sub _init_get_methods {
    my $self = shift;

    my $method;

    # --get_users
    $method = GRNOC::WebService::Method->new( name => 'get_users',
                                                   description => "Returns info about users.",
                                                   expires => "-1d",
                                                   callback => sub { $self->_get_users( @_ ) } );

    # add the optional 'user_id' input param to the get_users() method
    $method->add_input_parameter( name        => 'user_id',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 1,
                                  description => 'The id of the user');

    # add the optional 'username' input param to the get_users() method
    $method->add_input_parameter( name        => 'username',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The username of the user');

    $self->websvc()->register_method($method);
}

sub _init_add_methods {
    my $self = shift;

    my $method;

    # --dynamically-added add methods
    $self->valid_dynamic_db_names( $self->user_ds()->valid_dynamic_db_names() );
    $self->_init_dynamic_add_methods( @_ );

    # --add_user
    $method = GRNOC::WebService::Method->new( name => 'add_user',
                                                   description => "Adds a user to the database.",
                                                   expires => "-1d",
                                                   callback => sub { $self->_add_user( @_ ) } );

    # add the REQUIRED username input param to the  method
    $method->add_input_parameter( name        => 'username',
                                  pattern     => $TEXT,
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'The username');

    # add the REQUIRED name input param to the  method
    $method->add_input_parameter( name        => 'name',
                                  pattern     => $TEXT,
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'The name of the user (first and last)');

    $self->websvc()->register_method( $method );

    # --add_ip_blocks
    $method = GRNOC::WebService::Method->new( name => 'add_ip_blocks',
                                                   description => "Adds the specified IP blocks.",
                                                   expires => "-1d",
                                                   callback => sub { $self->_add_ip_blocks( @_ ) } );

    # add the REQUIRED 'addr_str' input param to the  method
    $method->add_input_parameter( name        => 'addr_str',
                                  pattern     => $TEXT,
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'The address string (CIDR)');

    $self->_add_ip_block_params( $method );
    $self->websvc()->register_method( $method );

    # --add_event
    $method = GRNOC::WebService::Method->new( name => 'add_event',
                                                   description => "Adds the specified event.",
                                                   expires => "-1d",
                                                   callback => sub { $self->_add_event( @_ ) } );
    $method->add_input_parameter( name        => 'message',
                                  pattern     => $TEXT,
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'The event message');
    $method->add_input_parameter( name        => 'user',
                                  pattern     => $INTEGER,
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'The id of the user that made the change');
    $method->add_input_parameter( name        => 'ip_block_id',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The event ip_block_id, for an ip_block change');
    $method->add_input_parameter( name        => 'project_id',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The event project_id, for a project change');
    $method->add_input_parameter( name        => 'organization_id',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The event organization_id, for an organization change');
    $method->add_input_parameter( name        => 'discipline_id',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The event discipline_id, for a discipline change');
    $method->add_input_parameter( name        => 'role_id',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The event role_id, for a role change');
    $method->add_input_parameter( name        => 'user_id',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The event user_id, for a user change');
    $self->websvc()->register_method( $method );

    # --add_project
    $method = GRNOC::WebService::Method->new( name => 'add_project',
                                              description => "Add the specified project.",
                                              expires => "-1d",
                                              callback => sub { $self->_add_project( @_ ) } );
    $method->add_input_parameter( name        => 'name',
                                  pattern     => $TEXT,
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'The project name');
    $method->add_input_parameter( name        => 'abbr',
                                  pattern     => $TEXT,
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'A short name for the project');
    $method->add_input_parameter( name        => 'description',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The project description');
    $method->add_input_parameter( name        => 'url',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The project webpage');
    $method->add_input_parameter( name        => 'notes',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The project notes');
    $method->add_input_parameter( name        => 'owner',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The main contact for the project');
    $method->add_input_parameter( name        => 'email',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The email of the contact');
    $self->websvc()->register_method($method);

    #-- set_project_ip_block_links
    $method = GRNOC::WebService::Method->new(
        name => 'set_project_ip_block_links',
        description => "Updates project project_id.",
        expires => "-1d",
        callback => sub { $self->_set_project_ip_block_links( @_ ) } );

    $method->add_input_parameter(
        name        => 'project_id',
        pattern     => $INTEGER,
        required    => 1,
        multiple    => 0,
        description => 'The id of the project'
    );

    $method->add_input_parameter(
        name        => 'ip_block_id',
        pattern     => $INTEGER,
        required    => 1,
        multiple    => 1,
        description => 'The id of the IP blocks to add'
    );

    $self->_get_dynamic_where_parameters($method);
    $self->websvc()->register_method($method);
}

sub _init_update_methods {
    my $self = shift;

    my $method;

    $self->valid_dynamic_db_names( $self->user_ds()->valid_dynamic_db_names() );

    $self->_init_dynamic_update_methods( @_ );


    # --update_user
    $method = GRNOC::WebService::Method->new( name => 'update_user',
                                                   description => "Updates the specified user.",
                                                   expires => "-1d",
                                                   callback => sub { $self->_update_user( @_ ) } );

    # add the required 'user_id' input param to the update_user() method
    $method->add_input_parameter( name        => 'user_id',
                                  pattern     => $INTEGER,
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'The id of the user');

    # add the required 'username' input param to the  method
    $method->add_input_parameter( name        => 'username',
                                  pattern     => $TEXT,
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'The username of the person');

    # add the required 'name' input param to the  method
    $method->add_input_parameter( name        => 'name',
                                  pattern     => $TEXT,
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'The full name of the person');

    $self->websvc()->register_method( $method );

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
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'The address string (CIDR)');

    $self->_add_ip_block_params( $method );
    $self->websvc()->register_method( $method );

    #-- update_project
    $method = GRNOC::WebService::Method->new(
        name => 'update_project',
        description => "Updates project project_id.",
        expires => "-1d",
        callback => sub { $self->_update_project( @_ ) } );

    $method->add_input_parameter(
        name        => 'project_id',
        pattern     => $INTEGER,
        required    => 1,
        multiple    => 0,
        description => 'The id of the project'
    );

    $method->add_input_parameter(
        name        => 'name',
        pattern     => $TEXT,
        required    => 1,
        multiple    => 0,
        description => 'The name of the project'
    );

    $method->add_input_parameter(
        name        => 'abbr',
        pattern     => $TEXT,
        required    => 1,
        multiple    => 0,
        description => 'A short name for the project'
    );

    $method->add_input_parameter(
        name        => 'description',
        pattern     => $TEXT,
        required    => 0,
        multiple    => 0,
        description => 'The description of the project'
    );
    $method->add_input_parameter(
        name        => 'owner',
        pattern     => $TEXT,
        required    => 0,
        multiple    => 0,
        description => 'The main contact for the project'
    );

    $method->add_input_parameter(
        name        => 'email',
        pattern     => $TEXT,
        required    => 0,
        multiple    => 0,
        description => 'The email of the main contact'
    );

    $method->add_input_parameter(
        name        => 'url',
        pattern     => $TEXT,
        required    => 0,
        multiple    => 0,
        description => 'The webpage for the project'
    );

    $method->add_input_parameter(
        name        => 'notes',
        pattern     => $TEXT,
        required    => 0,
        multiple    => 0,
        description => 'The notes for the project'
    );

    $self->websvc()->register_method($method);
}

sub _init_delete_methods {
    my $self = shift;

    my $method;

    $self->valid_dynamic_db_names( $self->user_ds()->valid_dynamic_db_names() );

    $self->_init_dynamic_delete_methods( @_ );


    # --delete_user
    $method = GRNOC::WebService::Method->new( name => 'delete_user',
                                                   description => "Deletes the specified user.",
                                                   expires => "-1d",
                                                   callback => sub { $self->_delete_user( @_ ) } );

    # add the required 'user'_id input param to the delete_user() method
    $method->add_input_parameter( name        => 'user_id',
                                  pattern     => $INTEGER,
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'The id of the user to delete');

    $self->websvc()->register_method( $method );

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

    # --delete_project
    $method = GRNOC::WebService::Method->new( name => 'delete_project',
                                                   description => "Deletes the specified project.",
                                                   expires => "-1d",
                                                   callback => sub { $self->_delete_project( @_ ) } );

    # add the required 'project_id' input param to the delete_project() method
    $method->add_input_parameter( name        => 'project_id',
                                  pattern     => $INTEGER,
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'The id of the project to delete');

    $self->websvc()->register_method( $method );

}

sub _init_dynamic_add_methods {
    my $self = shift;

    foreach my $name ( keys %{ $self->valid_dynamic_db_names() } ) {
        my $plural = $self->get_plural( $name );
        my $method;
        # --add_$name
        $method = GRNOC::WebService::Method->new( name => "add_$name",
            description => "Add the ${name}",
            expires => "-1d",
            callback => sub { $self->_add_table_dynamically( $name, @_ ) } );


        # add the REQUIRED 'name' input param to all the basic dynamic methods
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

sub _init_dynamic_update_methods {
    my $self = shift;

    foreach my $name ( keys %{ $self->valid_dynamic_db_names() } ) {
        my $plural = $self->get_plural( $name );
        my $method;
        #--update_$name
        $method = GRNOC::WebService::Method->new( name => "update_$name",
            description => "Updates the $plural",
            expires => "-1d",
            callback => sub { $self->_update_table_dynamically( $name, @_ ) } );

        # add the REQUIRED 'id' input param to all the basic dynamic methods
        $method->add_input_parameter(
            name        => "${name}_id",
            pattern     => $NUMBER_ID,
            required    => 1,
            multiple    => 0,
            description => "The id of the $name");

        # add the REQUIRED 'name' input param to all the basic dynamic methods
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

sub _init_dynamic_delete_methods {
    my $self = shift;

    foreach my $name ( keys %{ $self->valid_dynamic_db_names() } ) {
        my $method;
        #-- delete_$name
        $method = GRNOC::WebService::Method->new( name => "delete_${name}",
            description => "Deletes the ${name}",
            expires => "-1d",
            callback => sub { $self->_delete_table_dynamically( $name, @_ ) } );

        # add the REQUIRED 'id' input param to all the basic dynamic methods
        $method->add_input_parameter(
            name        => "${name}_id",
            pattern     => $NUMBER_ID,
            required    => 1,
            multiple    => 0,
            description => "The id of the $name");

        $self->websvc()->register_method( $method );

    }

}

#--------------------
sub _add_ip_block_params {
    my ( $self, $method ) = @_;

    # add the optional 'name' input param to the  method
    $method->add_input_parameter( name        => 'name',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The name of the ip resource block');

    # add the optional 'abbr' input param to the  method
    $method->add_input_parameter( name        => 'abbr',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The short name of the ip resource block');

    # add the optional 'description' input param to the method
    $method->add_input_parameter( name        => 'description',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The description of the ip resource block');

    # add the optional 'url' input param to the method
    $method->add_input_parameter( name        => 'url',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The url of the ip resource block');

    # add the optional 'notes' input param to the method
    $method->add_input_parameter( name        => 'notes',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The notes of the ip resource block');

    # add the optional 'asn' input param to the  method
    $method->add_input_parameter( name        => 'asn',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The ASN of the IP block');

    # add the REQUIRED 'organization_id' input param to the  method
    $method->add_input_parameter( name        => 'organization_id',
                                  pattern     => $INTEGER,
                                  required    => 1,
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
        
        } elsif ( $field eq "abbr" ) {
            # add the optional 'abbr' input param to all the basic dynamic methods
            $method->add_input_parameter(
                name        => $field,
                pattern     => $TEXT,
                multiple    => 0,
                required    => 0,
                description => "The abbreviation of the $name");

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

        } elsif ( $field eq "notes" ) {
            # add the optional 'notes' input param to all the basic dynamic methods
            $method->add_input_parameter(
                name        => $field,
                pattern     => $TEXT,
                required    => 0,
                multiple    => 0,
                description => "The notes of the $name");
        }
    }
}
#--------------------

### callbacks ###

sub _set_project_ip_block_links {
    my ($self, $method, $args) = @_;

    my $result = $self->admin_ds()->set_project_ip_block_links( $self->process_args( $args ) );
    if (!$result) {
        $method->set_error( $self->admin_ds()->error() );
        return;
    }

    return $result;
}

### CALLBACKS - dynamic tables

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


### CALLBACKS - get methods

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

sub _add_event {
    my ( $self, $method, $args ) = @_;

    my $result = $self->admin_ds()->add_event( $self->process_args( $args ) );
    if ( !$result ) {
        $method->set_error( $self->admin_ds()->error() );
        return;
    }

    return { 'results' => $result };
}

sub _add_project {
    my ( $self, $method, $args ) = @_;

    my $result = $self->admin_ds()->add_project( $self->process_args( $args ) );
    if ( !$result ) {
        $method->set_error( $self->admin_ds()->error() );
        return;
    }

    return { 'results' => $result };
}

### CALLBACKS - update methods

sub _update_user {
    my ( $self, $method, $args ) = @_;

    my $result = $self->admin_ds()->update_user( $self->process_args( $args ) );
    if ( !$result ) {
        $method->set_error( $self->admin_ds()->error() );
        return;
    }

    return { 'results' => $result };
}

sub _update_ip_blocks {
    my ( $self, $method, $args ) = @_;

    my $result = $self->admin_ds()->update_ip_blocks( $self->process_args( $args ) );
    if ( !$result ) {
        $method->set_error( $self->admin_ds()->error() );
        return;
    }

    return { 'results' => $result };
}

sub _update_project {
    my ( $self, $method, $args ) = @_;

    my $result = $self->admin_ds()->update_project($self->process_args( $args ));
    if (!$result) {
        $method->set_error( $self->admin_ds()->error() );
        return;
    }

    return $result;
}

### CALLBACKS - delete methods

sub _delete_user {

    my ( $self, $method, $args ) = @_;

    my $result = $self->admin_ds()->delete_user( $self->process_args( $args ) );

    # handle error
    if ( !$result ) {

        $method->set_error( $self->admin_ds()->error() );
        return;
    }

    return { 'results' => $result };

}

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

sub _delete_project {

    my ( $self, $method, $args ) = @_;

    my $result = $self->admin_ds()->delete_project( $self->process_args( $args ) );

    # handle error
    if ( !$result ) {

        $method->set_error( $self->admin_ds()->error() );
        return;
    }

    return { 'results' => $result };

}


1;

