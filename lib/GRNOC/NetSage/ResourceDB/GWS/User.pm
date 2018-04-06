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


    return $self;
}

sub _init_get_methods {

    my $self = shift;
    my $method_in = shift;
    my $args = shift;

    my $method;


    $self->valid_dynamic_db_names( $self->user_ds()->valid_dynamic_db_names() );

    $self->_init_dynamic_get_methods( @_ );


    # --get_ip_blocks
    $method = GRNOC::WebService::Method->new( name => 'get_ip_blocks',
                                                   description => "Returns the IP blocks.",
                                                   expires => "-1d",
                                                   callback => sub { $self->_get_ip_blocks( @_ ) } );

    # add the optional 'ip_block_id' input param to the get_ip_blocks() method
    $method->add_input_parameter( name        => 'ip_block_id',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 1,
                                  description => 'The id of the IP block');

    # add the optional 'text_str' logic parameter
    # acccepts options such as text_str_like=127.0 or text_str_like=NASA
    $method->add_logic_parameter(
                                name => "text_str",
                                pattern => $TEXT,
                                description => "The IP address, name, abbr, or org name to match on" );

    # add the optional 'abbr' logic param to the get_ip_blocks() method [needs to be logic param !?]
    $method->add_logic_parameter(
                                name => "abbr",
                                pattern => $TEXT,
                                description => "The abbr" );

    # add the optional 'project_id' logic param to the get_ip_blocks() method [needs to be logic param !?]
    $method->add_logic_parameter(
                                name => "project_id",
                                pattern => $INTEGER,
                                description => "The project id to match on" );

    # add the optional 'limit' input param to the get_ip_blocks() method
    $method->add_input_parameter( name        => 'limit',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The limit of how many results to return');

    # add the optional 'offset' input param to the get_ip_blocks() method
    $method->add_input_parameter( name        => 'offset',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The offset (pagination)');

    # add the rest of the parameters
    $self->_get_dynamic_where_parameters( $method );
    $self->websvc()->register_method( $method );

    #-- get_projects
    $method = GRNOC::WebService::Method->new(
        name => 'get_projects',
        description => "Returns the projects of IP block.",
        expires => "-1d",
        callback => sub { $self->_get_projects( @_ ) } );

    $method->add_input_parameter(
        name        => 'ip_block_id',
        pattern     => $INTEGER,
        required    => 0,
        multiple    => 0,
        description => 'The id of the IP block'
    );

    $method->add_input_parameter(
        name        => 'project_id',
        pattern     => $INTEGER,
        required    => 0,
        multiple    => 0,
        description => 'The id of the IP block'
    );

    # add the optional 'abbr' logic param to the get_projects() method
    $method->add_logic_parameter(
         name => "abbr",
         pattern => $TEXT,
         description => "The abbr" 
    );

    # add the rest of the fields 
    $self->_get_dynamic_where_parameters($method);

    # handle name_like
    $method->add_logic_parameter(
        name => "name",
        pattern => $TEXT,
        description => "The text to look for in project name",
    );

    $self->websvc()->register_method($method);

    #-- get_events
    $method = GRNOC::WebService::Method->new(
        name        => 'get_events',
        description => 'Get all events.',
        expires     => '-1d',
        callback    => sub { $self->_get_events(@_) }
    );
    $method->add_input_parameter( name        => 'event_id',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The event_id');
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
    $self->websvc()->register_method($method);

    # --get_loggedin_user
    $method = GRNOC::WebService::Method->new( name => 'get_loggedin_user',
                                                   description => "Returns info about the user that is currently logged in and adds them to the database if they are not there.",
                                                   expires => "-1d",
                                                   callback => sub { $self->_get_loggedin_user( @_ ) } );

    $self->websvc()->register_method($method);
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

# 'get' methods for roles, organizations, desciplines, countries, continents
sub _init_dynamic_get_methods {
    my ( $self, $method_in, $args ) = @_;

    foreach my $name ( keys %{ $self->valid_dynamic_db_names() } ) {
        my $plural = $self->get_plural( $name );
        my $method;
        #-- get_$names
        $method = GRNOC::WebService::Method->new( name => "get_$plural",
            description => "Returns the $plural",
            expires => "-1d",
            callback => sub { $self->_get_table_dynamically( $name, @_ ) } );

        # add the optional 'name_id' input param to the get_$names() method
        $method->add_input_parameter( name        => "${name}_id",
            pattern     => $INTEGER,
            required    => 0,
            multiple    => 1,
            description => "The id of the $name");

        # add the optional 'name' input param to the get_$names() method
        $method->add_input_parameter( name        => "name",
            pattern     => $TEXT,
            required    => 0,
            multiple    => 1,
            description => "The name of the $name");

        # add the optional 'abbr' input param to the get_$names() method
        $method->add_input_parameter( name        => "abbr",
            pattern     => $TEXT,
            required    => 0,
            multiple    => 1,
            description => "The abbr of the $name");

        # allow name_like
        $method->add_logic_parameter( name      => "name",
            pattern => $TEXT,
            description => "The name of the $name to match on");

        # add the optional 'limit' input param to the get_$names() method
        $method->add_input_parameter( name        => "limit",
            pattern     => $INTEGER,
            required    => 0,
            multiple    => 0,
            description => "The limit of number of items to return");

        # add the optional 'offset' input param to the get_$names() method
        $method->add_input_parameter( name        => "offset",
            pattern     => $INTEGER,
            required    => 0,
            multiple    => 0,
            description => "The offset number of records for pagination");

        $self->websvc()->register_method( $method );

    }
}

sub _init_email_methods {
    my $self = shift;

    my $method;

    # --send_us_email
    $method = GRNOC::WebService::Method->new( name => 'send_us_email',
                                                   description => "Sends email to us with contact form entries.",
                                                   expires => "-1d",
                                                   callback => sub { $self->_send_us_email( @_ ) } );

    # add the required 'name' input param to the send_us_email() method
    $method->add_input_parameter( name        => 'name',
                                  pattern     => $TEXT,
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'The name of the user');
    # add the required 'org' input param to the send_us_email() method
    $method->add_input_parameter( name        => 'org',
                                  pattern     => $TEXT,
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'The org/position of the user');
    # add the required 'email' input param to the send_us_email() method
    $method->add_input_parameter( name        => 'email',
                                  pattern     => $TEXT,
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'The email address of the user');
    # add the optional 'phone' input param to the send_us_email() method
    $method->add_input_parameter( name        => 'phone',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The phone no. of the user');
    # add the required 'msg' input param to the send_us_email() method
    $method->add_input_parameter( name        => 'msg',
                                  pattern     => $TEXT,
                                  required    => 1,
                                  multiple    => 0,
                                  description => 'The message the user wants to send');

    $self->websvc()->register_method($method);
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

sub _get_projects {
    my ( $self, $method, $args ) = @_;

    my $result = $self->user_ds()->get_projects( $self->process_args( $args ) );
    if (!$result) {
        $method->set_error( $self->user_ds()->error() );
        return;
    }

    return {
        'results' => $result->results(),
        'total' => $result->total(),
        'offset' => $result->offset(),
        'warning' => $result->warning()
    };
}

sub _get_events {
    my ( $self, $method, $args ) = @_;

    my $result = $self->user_ds()->get_events( $self->process_args( $args ) );
    if (!$result) {
        $method->set_error( $self->user_ds()->error() );
        return;
    }

    return {
        'results' => $result->results(),
        'total' => $result->total(),
        'offset' => $result->offset(),
        'warning' => $result->warning()
    };
}

sub _send_us_email {
    my ( $self, $method, $args ) = @_;

    my $result = $self->user_ds()->send_us_email( $self->process_args( $args ) );
    if ( !$result ) {
        $method->set_error( $self->user_ds()->error() );
        return;
    }

    return { 'results' => $result };
}

1;
