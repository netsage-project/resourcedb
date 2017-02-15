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

use String::MkPasswd qw( mkpasswd );
use MIME::Lite::TT;
use Data::Dumper;
use Time::HiRes;

use constant SERVICE_CACHE_FILE => '/etc/grnoc/name-service-cacher/name-service.xml';
use constant COOKIE_FILE => '/tmp/netsage_resourcedb_cookies';

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
    #$self->_init();

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

sub error {

    my ( $self, $error ) = @_;

    $self->{'error'} = $error if ( defined( $error ) );

    return $self->{'error'};
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

1;
