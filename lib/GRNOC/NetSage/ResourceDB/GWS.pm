# GlobalNOC Web Service base class
# Other GWS modules should inherit this
# Provides common helper methods that all GWS methods should use

package GRNOC::NetSage::ResourceDB::GWS;

use strict;
use warnings;

use GRNOC::Config;
use GRNOC::DatabaseQuery;
use GRNOC::WebService::Dispatcher;
use GRNOC::WebService::Regex;

use HTML::Parser;
use Data::Dumper;

use GRNOC::NetSage::ResourceDB::DataService;
use GRNOC::NetSage::ResourceDB::DataService::User;
use GRNOC::NetSage::ResourceDB::DataService::Admin;

sub new {

    my $caller = shift;

    my $class = ref( $caller );
    $class = $caller if ( !$class );

    my $self = {
        config_file => undef,
        @_
    };

    bless( $self, $class );

    $self->{'dataservice'} = GRNOC::NetSage::ResourceDB::DataService->new(@_);

    # get/store our user data service
    $self->user_ds( GRNOC::NetSage::ResourceDB::DataService::User->new( @_ ) );

    # get/store our admin data service
    $self->admin_ds( GRNOC::NetSage::ResourceDB::DataService::Admin->new( @_ ) );

    $self->_init();

    return $self;
}

sub _init {
    my $self = shift;

    $self->_init_config();
    $self->_init_websvc();

    $self->_init_get_methods();
    $self->_init_add_methods();
    $self->_init_update_methods();
    #$self->_init_delete_methods();
}

sub config {
    my ( $self, $config ) = @_;

    $self->{'config'} = $config if ( defined( $config ) );

    return $self->{'config'};
}

sub handle_request {
    my $self = shift;
    $self->{'websvc'}->handle_request( $self );
}

sub process_args {
    my ( $self, $args ) = @_;

    my %results;

    my @names = keys( %$args );

    foreach my $name ( @names ) {

        if ( $args->{$name}{'is_set'} ) {

            $results{$name} = $args->{$name}{'value'};
        }
    }

    return %results;
}


sub _init_config {
    my $self = shift;

    my $config = GRNOC::Config->new( config_file => $self->{'config_file'},
                                     force_array => 0 );

    $self->config( $config );
}

sub _init_websvc {
    my $self = shift;

    my $config = $self->config();

    $config->{'force_array'} = 1;
    my $proxy_users = $config->get( '/config/proxy-users/username' );
    $config->{'force_array'} = 0;

    # create websvc dispatcher object
    my $websvc = GRNOC::WebService::Dispatcher->new( allowed_proxy_users => $proxy_users );

    # add the input validator which will reject any input that contains HTML
    $websvc->add_default_input_validator( name => 'disallow_html',
                                          description => 'This default input validator will invalidate any input that contains HTML.',
                                          callback => sub { $self->_disallow_html( @_ ); } );

    $self->{'websvc'} = $websvc;
}


sub _init_get_methods {}

sub _init_add_methods {}

sub _init_update_methods {}

sub _init_delete_methods {}

sub _disallow_html {

    my ( $self, $method, $input ) = @_;

    my $parser = HTML::Parser->new();

    my $contains_html = 0;

    $parser->handler( start => sub { $contains_html = 1 }, 'tagname' );

    $parser->parse( $input );
    $parser->eof();

    return !$contains_html;
}

sub valid_dynamic_db_names {

    my ( $self, $valid_dynamic_db_names ) = @_;

    $self->{'valid_dynamic_db_names'} = $valid_dynamic_db_names if ( defined( $valid_dynamic_db_names ) );

    return $self->{'valid_dynamic_db_names'};
}

sub user_ds {

    my ( $self, $user_ds ) = @_;

    $self->{'user_ds'} = $user_ds if ( defined( $user_ds ) );

    return $self->{'user_ds'};
}

sub admin_ds {

    my ( $self, $admin_ds ) = @_;

    $self->{'admin_ds'} = $admin_ds if ( defined( $admin_ds ) );

    return $self->{'admin_ds'};
}

sub websvc {

    my ( $self, $websvc ) = @_;

    $self->{'websvc'} = $websvc if ( defined( $websvc ) );

    return $self->{'websvc'};
}


1;

