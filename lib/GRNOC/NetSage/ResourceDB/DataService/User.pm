package GRNOC::NetSage::ResourceDB::DataService::User;

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

    # get/store the mongodb handle
    #$self->mongo_rw( GRNOC::TSDS::MongoDB->new( @_, privilege => 'rw' ) );
    #$self->mongo_ro( GRNOC::TSDS::MongoDB->new( @_, privilege => 'ro' ) );

    # store the other dataservices
    #$self->metadata( GRNOC::TSDS::DataService::MetaData->new( @_ ) );

    my $config = GRNOC::Config->new( config_file => $self->{'config_file'}, force_array => 0);
    $self->{'config'} = $config;
    #$self->{'proxy_users'} = $config->get('/config/proxy-users/username') || [];

    # Make sure it's an array, we set force_array to 0 above but we always
    # assume that the proxy users are in array form
    #$self->{'proxy_users'} = [$self->{'proxy_users'}] if (! ref $self->{'proxy_users'});

    return $self;
}

sub get_roles {

    my ( $self, %args ) = @_;

    warn "getting roles";

    my $remote_user = $args{'remote_user'};

    my $select_fields = ['role.role_id',
                         'role.name',
                         ];

    my @where = ();

    # handle optional role_id param
    my $role_id_param = GRNOC::MetaParameter->new( name => 'role_id',
                                                      field => 'role.role_id' );

    @where = $role_id_param->process( args => \%args,
                                         where => \@where );

    # get the order_by value
    my $order_by_param = GRNOC::MetaParameter::OrderBy->new();
    my $order_by = $order_by_param->parse( %args );

    my $limit = $args{'limit'};
    my $offset = $args{'offset'};

    my $from_sql = 'role ';

    my $results = $self->dbq_rw()->select( table => $from_sql,
                                           fields => $select_fields,
                                           where => [-and => \@where],
                                           order_by => $order_by,
                                           limit => $limit,
                                           offset => $offset );

    if ( !$results ) {

        $self->error( 'An unknown error occurred getting the roles.' );
        return;
    }

    my $num_rows = $self->dbq_rw()->num_rows();

    my $result = GRNOC::NetSage::ResourceDB::DataService::Result->new( results => $results,
                                                                 total => $num_rows,
                                                                 offset => $offset );

    return $result;

}


### callbacks ###
sub _get_roles {

    my ( $self, $method, $args ) = @_;

    #my $result = $self->{'dataservice'}->get_roles( remote_user => $ENV{'REMOTE_USER'},
    #                                                   $self->process_args( $args ) );

    my $result; # TODO: fix
    # handle error
    if ( !$result ) {

        #$self->error( $self->{'dataservice'}->error() );
        return;
    }

    return {'results' => $result->results(),
            'total' => $result->total(),
            'offset' => $result->offset(),
            'warning' => $result->warning()};
}

1;

