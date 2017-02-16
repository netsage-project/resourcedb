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

    # get_requests
    $method = GRNOC::WebService::Method->new( name => 'get_roles',
                                                   description => "Returns the Roles.",
                                                   expires => "-1d",
                                                   #default_order_by => ['name'],
                                                   callback => sub { $self->_get_roles( @_ ) } );

    # add the optional 'request_id' input param to the get_requests() method
    $method->add_input_parameter( name        => 'role_id',
                                  pattern     => $INTEGER,
                                  required    => 0,
                                  multiple    => 1,
                                  description => 'The id of the role');

    $self->websvc()->register_method( $method );


}


### callbacks ###

sub _get_roles {

    my ( $self, $method, $args ) = @_;

    warn "calling get_roles ...";

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

sub _get_existing_contacts {

    my ( $self, $method, $args ) = @_;

    my $result = $self->{'dataservice'}->get_existing_contacts( $self->process_args( $args ) );

    # handle error
    if ( !$result ) {

        $method->set_error( $self->{'dataservice'}->error() );
        return;
    }

    return {'results' => $result->results(),
            'total' => $result->total(),
            'offset' => $result->offset(),
            'warning' => $result->warning()};
}

sub _get_updated_contacts {

    my ( $self, $method, $args ) = @_;

    my $result = $self->{'dataservice'}->get_updated_contacts( $self->process_args( $args ) );

    # handle error
    if ( !$result ) {

        $method->set_error( $self->{'dataservice'}->error() );
        return;
    }

    return {'results' => $result->results(),
            'total' => $result->total(),
            'offset' => $result->offset(),
            'warning' => $result->warning()};
}

sub _get_entity_contacts {

    my ( $self, $method, $args ) = @_;

    my $result = $self->{'dataservice'}->get_entity_contacts( $self->process_args( $args ) );

    # handle error
    if ( !$result ) {

        $method->set_error( $self->{'dataservice'}->error() );
        return;
    }

    return {'results' => $result->results(),
            'total' => $result->total(),
            'warning' => $result->warning()};
}

sub _get_new_contacts {

    my ( $self, $method, $args ) = @_;

    my $result = $self->{'dataservice'}->get_new_contacts( $self->process_args( $args ) );

    # handle error
    if ( !$result ) {

        $method->set_error( $self->{'dataservice'}->error() );
        return;
    }

    return {'results' => $result->results(),
            'total' => $result->total(),
            'offset' => $result->offset(),
            'warning' => $result->warning()};
}

sub _get_new_contact_methods {

    my ( $self, $method, $args ) = @_;

    my $result = $self->{'dataservice'}->get_new_contact_methods( $self->process_args( $args ) );

    # handle error
    if ( !$result ) {

        $method->set_error( $self->{'dataservice'}->error() );
        return;
    }

    return {'results' => $result->results(),
            'total' => $result->total(),
            'offset' => $result->offset(),
            'warning' => $result->warning()};
}

sub _get_existing_contact_methods {

    my ( $self, $method, $args ) = @_;

    my $result = $self->{'dataservice'}->get_existing_contact_methods( $self->process_args( $args ) );

    # handle error
    if ( !$result ) {

        $method->set_error( $self->{'dataservice'}->error() );
        return;
    }

    return {'results' => $result->results(),
            'total' => $result->total(),
            'offset' => $result->offset(),
            'warning' => $result->warning()};
}

sub _add_existing_contacts {

    my ( $self, $method, $args ) = @_;

    my $result = $self->{'dataservice'}->add_existing_contacts( $self->process_args( $args ) );

    # handle error
    if ( !$result ) {

        $method->set_error( $self->{'dataservice'}->error() );
        return;
    }

    return {'results' => $result};
}

sub _update_existing_contacts {

    my ( $self, $method, $args ) = @_;

    my $result = $self->{'dataservice'}->update_existing_contacts( $self->process_args( $args ) );

    # handle error
    if ( !$result ) {

        $method->set_error( $self->{'dataservice'}->error() );
        return;
    }

    return {'results' => $result};
}

sub _update_existing_contact_method {

    my ( $self, $method, $args ) = @_;

    my $results = $self->{'dataservice'}->update_existing_contact_method( $self->process_args( $args ) );

    # handle error
    if ( !$results ) {

        $method->set_error( $self->{'dataservice'}->error() );
        return;
    }

    return {'results' => $results};
}

sub _update_new_contacts {

    my ( $self, $method, $args ) = @_;

    my $results = $self->{'dataservice'}->update_new_contacts( $self->process_args( $args ) );

    # handle error
    if ( !$results ) {

        $method->set_error( $self->{'dataservice'}->error() );
        return;
    }

    return {'results' => $results};
}

sub _add_submission {

    my ( $self, $method, $args ) = @_;

    my $result = $self->{'dataservice'}->add_submission( remote_user => $ENV{'REMOTE_USER'},
                                                         $self->process_args( $args ) );

    # handle error
    if ( !$result ) {

        $method->set_error( $self->{'dataservice'}->error() );
        return;
    }

    return {'results' => $result };
}


sub _add_new_contact {

    my ( $self, $method, $args ) = @_;

    my $results = $self->{'dataservice'}->add_new_contact( $self->process_args( $args ) );

    # handle error
    if ( !$results ) {

        $method->set_error( $self->{'dataservice'}->error() );
        return;
    }

    return {'results' => $results};
}

sub _add_new_contact_method {

    my ( $self, $method, $args ) = @_;

    my $results = $self->{'dataservice'}->add_new_contact_method( $self->process_args( $args ) );

    # handle error
    if ( !$results ) {

        $method->set_error( $self->{'dataservice'}->error() );
        return;
    }

    return {'results' => $results};
}

sub _update_new_contact_method {

    my ( $self, $method, $args ) = @_;

    my $results = $self->{'dataservice'}->update_new_contact_method( $self->process_args( $args ) );

    # handle error
    if ( !$results ) {

        $method->set_error( $self->{'dataservice'}->error() );
        return;
    }

    return {'results' => $results};
}

sub _delete_new_contacts {

    my ( $self, $method, $args ) = @_;

    my $results = $self->{'dataservice'}->delete_new_contacts( $self->process_args( $args ) );

    # handle error
    if ( !$results ) {

        $method->set_error( $self->{'dataservice'}->error() );
        return;
    }

    return {'results' => $results};
}

sub _delete_existing_contacts {

    my ( $self, $method, $args ) = @_;

    my $results = $self->{'dataservice'}->delete_existing_contacts( $self->process_args( $args ) );

    # handle error
    if ( !$results ) {

        $method->set_error( $self->{'dataservice'}->error() );
        return;
    }

    return {'results' => $results};
}

sub _delete_existing_contact_methods {

    my ( $self, $method, $args ) = @_;

    my $results = $self->{'dataservice'}->delete_existing_contact_methods( $self->process_args( $args ) );

    # handle error
    if ( !$results ) {

        $method->set_error( $self->{'dataservice'}->error() );
        return;
    }

    return {'results' => $results};
}

sub _delete_new_contact_methods {

    my ( $self, $method, $args ) = @_;

    my $results = $self->{'dataservice'}->delete_new_contact_methods( $self->process_args( $args ) );

    # handle error
    if ( !$results ) {

        $method->set_error( $self->{'dataservice'}->error() );
        return;
    }

    return {'results' => $results};
}

sub _get_existing_contact_role_memberships {

    my ($self, $method, $args) = @_; 

    my $results = $self->{'dataservice'}->get_existing_contact_role_memberships( $self->process_args($args) );

    if ( !$results) {

        $method->set_error($self->{'dataservice'}->error());
        return;
    }   


    return {'results' => $results->results(),
            'total' => $results->total(),
            'offset' => $results->offset()};
}

sub _get_new_contact_role_memberships {

    my ($self, $method, $args) = @_; 

    my $results = $self->{'dataservice'}->get_new_contact_role_memberships( $self->process_args($args) );

    if ( !$results) {

        $method->set_error($self->{'dataservice'}->error());
        return;
    }   


    return {'results' => $results->results(),
            'total' => $results->total(),
            'offset' => $results->offset()};
}

sub _update_new_contact_role_memberships {

    my ($self, $method, $args) = @_; 

    my $results = $self->{'dataservice'}->update_new_contact_role_memberships($self->process_args($args));

    if (!$results) {

        $method->set_error($self->{'dataservice'}->error());
        return;
    }   

    return {'results' => $results};
}

sub _update_existing_contact_role_memberships {

    my ($self, $method, $args) = @_; 

    my $results = $self->{'dataservice'}->update_existing_contact_role_memberships($self->process_args($args));

    if (!$results) {

        $method->set_error($self->{'dataservice'}->error());
        return;
    }   

    return {'results' => $results};
}

sub _delete_existing_contact_role_memberships {
    
    my ($self, $method, $args) = @_; 
    my $results = $self->{'dataservice'}->delete_existing_contact_role_memberships($self->process_args($args));
    if (!$results) {
        $method->set_error($self->{'dataservice'}->error());
        return;
    }   
    return {'results' => $results};
}

sub _delete_new_contact_role_memberships {
    
    my ($self, $method, $args) = @_; 
    my $results = $self->{'dataservice'}->delete_new_contact_role_memberships($self->process_args($args));
    if (!$results) {
        $method->set_error($self->{'dataservice'}->error());
        return;
    }   
    return {'results' => $results};
}



sub _add_existing_contact_role_membership {

    my ($self, $method, $args) = @_; 

    my $results = $self->{'dataservice'}->add_existing_contact_role_membership($self->process_args($args));

    if (!$results) {
        $method->set_error($self->{'dataservice'}->error());
        return;
    }   
    return {'results' => $results};
}

sub _add_new_contact_role_membership {

    my ($self, $method, $args) = @_; 

    my $results = $self->{'dataservice'}->add_new_contact_role_membership($self->process_args($args));

    if (!$results) {
        $method->set_error($self->{'dataservice'}->error());
        return;
    }   
    return {'results' => $results};
}

1;

