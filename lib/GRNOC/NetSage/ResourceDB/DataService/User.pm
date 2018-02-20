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

    my $config = GRNOC::Config->new( config_file => $self->{'config_file'}, force_array => 0);
    $self->{'config'} = $config;

    return $self;
}

sub get_ip_blocks {

    my ( $self, %args ) = @_;

    my $remote_user = $args{'remote_user'};

    my $select_fields = [
                         'ip_block.ip_block_id as ip_block_id',
                         'ip_block.name as name',
                         'ip_block.abbr as abbr',
                         'ip_block.description as description',
                         'ip_block.addr_str as addr_str',
                         'ip_block.addr_lower as addr_lower',
                         'ip_block.addr_upper as addr_upper',
                         'ip_block.mask as mask',
                         'ip_block.asn as asn',
                         'ip_block.organization_id as organization_id',
                         'ip_block.country_code as country_code',
                         'ip_block.url as url',
                         'ip_block.notes as notes',
                         'ip_block.postal_code as postal_code',
                         'ip_block.latitude as latitude',
                         'ip_block.longitude as longitude',
                         'ip_block.discipline_id as discipline_id',
                         'ip_block.role_id as role_id',
                         'country.name as country_name',
                         'country.continent_code as continent_code',
                         'continent.name as continent_name',
                         'role.name as role_name',
                         'organization.name as organization_name',
                         'organization.abbr as org_abbr',
                         'discipline.name as discipline_name'
                         ];

    my @where = ();

    # handle optional ip_block_id param
    my $id_param = GRNOC::MetaParameter->new(name => 'ip_block_id', field => 'ip_block.ip_block_id');
    @where = $id_param->process(args => \%args, where => \@where);

    # handle optional text_str param - addr_str or name or abbr or organization.name can be like text_str
    my $addr_param = GRNOC::MetaParameter->new(name => 'text_str', field => 'ip_block.addr_str');
    @where = $addr_param->process(args => \%args, where => \@where);

    my $name_param = GRNOC::MetaParameter->new( name => 'text_str', field => 'ip_block.name' );
    @where = $name_param->process(args => \%args, where => \@where);

    my $abbr_param = GRNOC::MetaParameter->new( name => 'text_str', field => 'ip_block.abbr' );
    @where = $abbr_param->process(args => \%args, where => \@where);

    my $org_name_param = GRNOC::MetaParameter->new(name => 'text_str', field => 'organization.name');
    @where = $org_name_param->process(args => \%args, where => \@where);

    # get the order_by value
    my $order_by_param = GRNOC::MetaParameter::OrderBy->new();
    my $order_by = $order_by_param->parse( %args );
    if (! $order_by) { $order_by = 'ip_block.name'; }

    my $limit = $args{'limit'};
    my $offset = $args{'offset'};

    my $from_sql = 'ip_block ';

    # Filters ip_blocks by optional project_id
    if (defined $args{'project_id'}) {
        my $project_param = GRNOC::MetaParameter->new(name => 'project_id', field => 'project.project_id');
        @where = $project_param->process(args => \%args, where => \@where);

        $from_sql .= 'join ip_block_project on (ip_block.ip_block_id = ip_block_project.ip_block_id) ';
        $from_sql .= 'join project on (ip_block_project.project_id = project.project_id) ';
    }

    $from_sql .= 'left join organization on ( ip_block.organization_id = organization.organization_id ) ';
    $from_sql .= 'left join role on ( ip_block.role_id = role.role_id ) ';
    $from_sql .= 'left join discipline on ( ip_block.discipline_id = discipline.discipline_id ) ';
    $from_sql .= 'left join country on ( country.country_code = ip_block.country_code ) ';
    $from_sql .= 'left join continent on ( country.continent_code = continent.continent_code ) ';

    $self->_add_dynamic_parameters(\%args, \@where);

    my $results = $self->dbq_ro()->select( table => $from_sql,
                                           fields => $select_fields,
                                           where => [-or => \@where],
                                           order_by => $order_by,
                                           limit => $limit,
                                           offset => $offset );
    if (!$results) {
        $self->error( 'An unknown error occurred getting the ip blocks.' );
        return;
    }

    my $num_rows = $self->dbq_ro()->num_rows();

    my $result = GRNOC::NetSage::ResourceDB::DataService::Result->new( results => $results,
                                                                 total => $num_rows,
                                                                 offset => $offset );
    return $result;
}

sub update_project {
    my ($self, %args) = @_;

    my @where = ();

    my $param = GRNOC::MetaParameter->new(
        name  => 'project_id',
        field => 'project.project_id'
    );

    @where = $param->process(args => \%args, where => \@where);

    my $project_id = $args{'project_id'};
    delete $args{'project_id'};

    my $result = $self->dbq_rw()->update(
        table => 'project',
        fields => \%args,
        where => [-and => \@where]
    );

    if (!defined $result || $result != 1) {
        return { error => $self->dbq_rw()->get_error() };
    }

    $self->add_events(
        project_id => $project_id,
        message => "$ENV{'REMOTE_USER'} updated this project."
    );

    return { results => [{ project_id => $project_id }] };
}

sub get_projects {
    my ($self, %args) = @_;

    my $remote_user = $args{'remote_user'};

    my $fields = [
        'project.project_id as project_id',
        'project.name as name',
        'project.abbr as abbr',
        'project.description as description',
        'project.url as url',
        'project.notes as notes',
        'project.email as email',
        'project.owner as owner'
    ];

    my @where = ();

    my $param = undef;
    my $table = '';
    if (defined $args{'ip_block_id'}) {
        $param = GRNOC::MetaParameter->new(
            name  => 'ip_block_id',
            field => 'ip_block_project.ip_block_id'
        );
        @where = $param->process(args => \%args, where => \@where);

        $table .= 'ip_block_project ';
        $table .= 'join project on (ip_block_project.project_id = project.project_id)';

    } elsif (defined $args{'project_id'}) {
        $param = GRNOC::MetaParameter->new(
            name  => 'project_id',
            field => 'project_id'
        );

        @where = $param->process(args => \%args, where => \@where);

        $table .= 'project';

    } else {
        $table .= 'project';
    }

    my $name_param = GRNOC::MetaParameter->new(name => 'name', field => 'project.name');
    @where = $name_param->process(args => \%args, where => \@where);

    my $order_by_param = GRNOC::MetaParameter::OrderBy->new();
    my $order_by = $order_by_param->parse( %args );
    if (! $order_by) { $order_by = 'project.name'; }

    my $results = $self->dbq_ro()->select(
        table  => $table,
        fields => $fields,
        where  => [-and => \@where],
        order_by => $order_by
    );
    if (!$results) {
        $self->error('An unknown error occurred getting the projects.');
        return undef;
    }

    my $num_rows = $self->dbq_ro()->num_rows();
    my $result = GRNOC::NetSage::ResourceDB::DataService::Result->new(
        results => $results,
        total => $num_rows
    );

    return $result;
}

sub get_events {
    my ($self, %args) = @_;

    my $remote_user = $args{'remote_user'};

    my $fields = [
        'event.event_id as event_id',
        'event.message as message',
        'event.date as date',
        'event.project_id as project_id',
        'event.ip_block_id as ip_block_id',
        'event.organization_id as organization_id',
        'event.user_id as user_id'
    ];

    my @where = ();
    foreach my $name (keys %args) {
        my $param = GRNOC::MetaParameter->new(
            name  => $name,
            field => "event.$name"
        );

        @where = $param->process(args => \%args, where => \@where);
    }

    my $results = $self->dbq_ro()->select(
        table  => 'event',
        fields => $fields,
        where  => [-and => \@where],
        order_by => [{-desc => 'date'}],
        limit => 10
    );
    if (!$results) {
        $self->error('An unknown error occurred getting the events.');
        return undef;
    }

    my $num_rows = $self->dbq_ro()->num_rows();
    my $result = GRNOC::NetSage::ResourceDB::DataService::Result->new(
        results => $results,
        total => $num_rows
    );

    return $result;
}

sub _add_dynamic_parameters {
    my $self = shift;
    my $args = shift;
    my $where = shift;

    foreach my $name ( keys %{ $self->valid_dynamic_db_names() } ) {
        # handle optional $name_id param
        my $role_id_param = GRNOC::MetaParameter->new( name => "${name}_id",
            field => "${name}.${name}_id" );

        @$where = $role_id_param->process( args => $args,
            where => $where );

    }

}

sub set_project_ip_block_links {
    my ($self, %args) = @_;

    my @where = ();

    my $param = GRNOC::MetaParameter->new(
        name  => 'project_id',
        field => 'project_id'
    );

    @where = $param->process(args => \%args, where => \@where);

    my $result = undef;
    $result = $self->dbq_rw()->delete(
        table => 'ip_block_project',
        where => [-and => \@where]
    );

    if (!defined $result) {
        return { error => $self->dbq_rw()->get_error() };
    }

    $result = undef;
    foreach my $ip_block_id (@{$args{'ip_block_id'}}) {
        $result = $self->dbq_rw()->insert(
            table  => 'ip_block_project',
            fields => { project_id => $args{'project_id'}, ip_block_id => $ip_block_id }
        );
    }

    if (!defined $result || $result < 1) {
        return { error => $self->dbq_rw()->get_error() };
    }

    return { results => [ int($result) ] };
}

1;
