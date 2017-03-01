package GRNOC::NetSage::ResourceDB::DataService::Admin;

use strict;
use warnings;

use GRNOC::Config;
use GRNOC::DatabaseQuery;

use Data::Dumper;

use base 'GRNOC::NetSage::ResourceDB::DataService';

my $singleton;

### constructor ###
sub new {

    my $caller = shift;

    my $class = ref( $caller );
    $class = $caller if ( !$class );

    # if we've created this object (singleton) before, just return it
    return $singleton if ( defined( $singleton ) );

    my $self = $class->SUPER::new( @_ );

    bless( $self, $class );

    # store our newly created object as the singleton
    $singleton = $self;

    my $config = GRNOC::Config->new( config_file => $self->{'config_file'}, force_array => 0);
    $self->{'config'} = $config;

    return $self;
}

sub add_ip_blocks {

    my ( $self, %args ) = @_;

    warn "add_ip_block_args: " . Dumper %args;

    my $remote_user = $args{'remote_user'};
    # TODO: check remote_user, what should this be?

    my $from_sql = 'ip_block ';

    my $fields = $self->_get_ip_block_args( %args );

    my $results = $self->dbq_rw()->insert( table => $from_sql,
                                           fields => $fields
                                       );

    if ( !$results ) {

        $self->error( 'An unknown error occurred adding the ip blocks.' );
        return;
    }

    my $num_rows = $self->dbq_rw()->num_rows();

    my $result = GRNOC::NetSage::ResourceDB::DataService::Result->new( results => $results,
                                                                 total => $num_rows,
                                                                 );

    return $result;

}

sub _get_ip_block_args {
    my ( $self, %args_in ) = @_;

    warn "args_in: " . Dumper %args_in;

    my %args = ();

    #while( my ($key, $val) = each %args_in ) {
    #    if ( ! defined ( $val ) ) {
    #        next;
    #    }
    #    $args{ $key } = $val;
    #}

    my @all_args = (
        'name',
        'addr_str',
        #'addr_lower',
        #'addr_upper',
        'mask',
        'asn',
        'organization_id',
        'country_code',
        'country_name',
        'continent_code',
        'continent_name',
        'postal_code',
        'latitude',
        'longitude',
        'project_id',
        'discipline_id',
        'role_id',
    );

    foreach my $arg( @all_args ) {
        if ( not defined $args_in{ $arg } ) {
            next;
        }
        $args{ $arg } = $args_in{ $arg };

    }


    warn "ip block args: " . Dumper %args;

    return \%args;

}

1;

