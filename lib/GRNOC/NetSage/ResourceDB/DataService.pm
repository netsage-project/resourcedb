#--------------------------------------------------------------------
#----- GRNOC NetSage ResourceDB DataService Library
#-----
#----- Copyright(C) 2017 The Trustees of Indiana University
#--------------------------------------------------------------------
#----- This module contains the functionality to connect to and query
#----- the backend database.  It contains methods that are used as
#----- callbacks for the DataService/GWS.pm library.
#--------------------------------------------------------------------

package GRNOC::NetSage::ResourceDB::DataService;

use strict;
use warnings;

use GRNOC::Config;
use GRNOC::DatabaseQuery;
use GRNOC::WebService::Client;
use GRNOC::MetaParameter;
use GRNOC::MetaParameter::OrderBy;
use GRNOC::NetSage::ResourceDB::DataService::Result;
use GRNOC::NetSage::ResourceDB::DataService::Data;

use String::MkPasswd qw( mkpasswd );
use MIME::Lite::TT;
use Data::Dumper;
use Time::HiRes;

use constant SERVICE_CACHE_FILE => '/etc/grnoc/name-service-cacher/name-service.xml';
use constant COOKIE_FILE => '/tmp/netsage_resourcedb_cookies';

# Use get_table_dynamically(), etc for these quantities.
# See below for where fields in these tables are listed.
use constant VALID_DYNAMIC_DB_NAMES => {
    'organization' => 1,
    'role' => 1,
    'discipline' => 1,
    'country' => 1,
    'continent' => 1
};

### constructor ###

sub new {

    my $caller = shift;

    my $class = ref( $caller );
    $class = $caller if ( !$class );

    my $self = {'config_file' => undef,
                'error' => undef,
                @_};

    bless( $self, $class );

    # parse config, setup database connections, etc.
    my $res = $self->_init();
    if (! $res) { die ("FATAL ERROR IN DATASERVICE INITIALIZATION"); } 

    return $self;
}

### getters/setters ###

sub config {

    my ( $self, $config ) = @_;

    $self->{'config'} = $config if ( defined( $config ) );

    return $self->{'config'};
}

sub dbq_ro {

    my ( $self, $dbq_ro ) = @_;

    $self->{'dbq_ro'} = $dbq_ro if ( defined( $dbq_ro ) );

    return $self->{'dbq_ro'};
}

sub dbq_rw {

    my ( $self, $dbq_rw ) = @_;

    $self->{'dbq_rw'} = $dbq_rw if ( defined( $dbq_rw ) );

    return $self->{'dbq_rw'};
}

sub clouds {
    my ( $self, $clouds ) = @_;

    $self->{'clouds'} = $clouds if (defined $clouds);

    return $self->{'clouds'};
}

sub cache {
    my ( $self, $cache ) = @_;

    $self->{'cache'} = $cache if (defined $cache);

    return $self->{'cache'};
}

sub webservice_client {
    my ( $self, $client ) = @_;

    $self->{'client'} = $client if (defined $client);

    return $self->{'client'};
}

sub config_data {
    my ( $self, $config_data ) = @_;

    $self->{'config_data'} = $config_data if (defined $config_data);

    return $self->{'config_data'};
}

sub dynamic_fields {

    my ( $self, $dynamic_fields ) = @_;

    $self->{'dynamic_fields'} = $dynamic_fields if ( defined( $dynamic_fields ) );

    return $self->{'dynamic_fields'};
}


sub error {

    my ( $self, $error ) = @_;

    $self->{'error'} = $error if ( defined( $error ) );
    warn ("ERROR: ".$self->{'error'});

    return $self->{'error'};
}

# just a getter
sub valid_dynamic_db_names {
    my $self = shift;

    return VALID_DYNAMIC_DB_NAMES();

}


sub format_find {
    my ($self, %args) = @_;
    my $find        = $args{'find'} || {};
    my $find_logic  = $args{'find_logic'} || '$and';
    my $field_logic = $args{'field_logic'} || '$or';
    my $field       = $args{'field'};
    my $values      = $args{'values'};

    if(!defined($values)){
        return $find;
    }

    if(!defined($find->{$find_logic})){
        $find->{$find_logic} = [];
    }

    my $formatted_values = { $field_logic => [] };
    foreach my $value (@$values){
        push(@{$formatted_values->{$field_logic}}, { $field => $value});
    }
    push(@{$find->{$find_logic}}, $formatted_values);

    return $find;
}

### private methods ###

sub _is_dbname_valid {
    my ( $self, $name ) = @_;
    if ( exists ${ VALID_DYNAMIC_DB_NAMES() }{$name}  ) {
        return 1;
    }
    return 0;
}

sub _init {

    my ( $self ) = @_;

    # first parse and store the config file
    my $config = GRNOC::Config->new( config_file => $self->{'config_file'},
        force_array => 0 );

    if ( !defined( $config ) ) {

        $self->error( 'Unable to parse the config file.' );
        return 0;
    }

    $self->config( $config );

    $self->_init_dynamic_fields();

    # create the database handles
    my $dbq_ro = GRNOC::DatabaseQuery->new( name  => $config->get( '/config/database-name' ),
        user  => $config->get( '/config/database-readonly-username' ),
        pass  => $config->get( '/config/database-readonly-password' ),
        srv   => $config->get( '/config/database-host' ),
        port  => $config->get( '/config/database-port' ),
        debug => $config->get( '/config/database-query-debug' ) );

    my $ret = $dbq_ro->connect();

    if ( !$ret ) {

        $self->error( 'Unable to connect to the database using read-only credentials.' );
        return 0;
    }

    my $dbq_rw = GRNOC::DatabaseQuery->new( name  => $config->get( '/config/database-name' ),
        user  => $config->get( '/config/database-readwrite-username' ),
        pass  => $config->get( '/config/database-readwrite-password' ),
        srv   => $config->get( '/config/database-host' ),
        port  => $config->get( '/config/database-port' ),
        debug => $config->get( '/config/database-query-debug' ) );

    $ret = $dbq_rw->connect();

    if ( !$ret ) {

        $self->error( 'Unable to connect to the database using read-write credentials.' );
        return 0;
    }

    $self->dbq_ro( $dbq_ro );
    $self->dbq_rw( $dbq_rw );

    return 1;
}


sub _init_dynamic_fields {
    my ( $self ) = @_;

    my $fields = {};

    $fields->{'organization'} = {
        'name' => 1,
        'abbr' => 1,
        'description' => 1,
        'url' => 1,
        'owner' => 1,
        'email' => 1,
        'postal_code' => 1,
        'latitude' => 1,
        'longitude' => 1,
        'country_code' => 1,
        'continent_name' => 1,
        'notes' => 1
    };

    $fields->{'discipline'} = {
        'name' => 1,
        'description' => 1
    };

    $fields->{'role'} = {
        'name' => 1,
        'description' => 1
    };

    $fields->{'country'} = {
        'name' => 1,
        'country_code' => 1,
        'continent_code' => 1
    };

    $fields->{'continent'} = {
        'name' => 1,
        'continent_code' => 1
    };

    $self->dynamic_fields( $fields );


}

1;
