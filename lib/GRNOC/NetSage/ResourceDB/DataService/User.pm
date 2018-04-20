package GRNOC::NetSage::ResourceDB::DataService::User;

#########################################
# Functions that DO NOT require a logged-in user
#########################################

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
                         'organization.organization_id as org_id',
                         'organization.abbr as org_abbr',
                         'discipline.name as discipline_name'
                         ];

    my @where = ();

    # handle optional ip_block_id param
    my $id_param = GRNOC::MetaParameter->new(name => 'ip_block_id', field => 'ip_block.ip_block_id');
    @where = $id_param->process(args => \%args, where => \@where);

    # handle optional text_str param - addr_str or name or abbr or organization.name can be like text_str
    my $address_param = GRNOC::MetaParameter->new(name => 'text_str', field => 'ip_block.addr_str');
    @where = $address_param->process(args => \%args, where => \@where);
    my $name_param = GRNOC::MetaParameter->new( name => 'text_str', field => 'ip_block.name' );
    @where = $name_param->process(args => \%args, where => \@where);
    my $abbr_param = GRNOC::MetaParameter->new( name => 'text_str', field => 'ip_block.abbr' );
    @where = $abbr_param->process(args => \%args, where => \@where);
    my $org_name_param = GRNOC::MetaParameter->new(name => 'text_str', field => 'organization.name');
    @where = $org_name_param->process(args => \%args, where => \@where);

    # handle optional abbr param
    my $abbrev_param = GRNOC::MetaParameter->new(name => 'abbr', field => 'ip_block.abbr');
    @where = $abbrev_param->process(args => \%args, where => \@where);

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

    # handle optional 'abbr' param
    my $abbr_param = GRNOC::MetaParameter->new( name => "abbr", field => "project.abbr" );
    @where = $abbr_param->process( args => \%args, where => \@where );

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

sub get_table_dynamically {

    my ( $self, $name, %args ) = @_;

    if ( !$self->_is_dbname_valid( $name ) ) {
        $self->error( "Invalid db name specified: $name" );
        return;
    }

    my $remote_user = $args{'remote_user'};

    my @select_fields = ( "${name}_id");

    my $field_obj = $self->dynamic_fields();
    my @field_list = keys %{ $field_obj->{ $name } };
    foreach my $field ( @field_list ) {
        # add to @select_fields list
        push @select_fields, $field;
    }

    my @where = ();

    # handle optional $name_id param
    my $id_param = GRNOC::MetaParameter->new( name => "${name}_id",
                                              field => "${name}.${name}_id" );
    @where = $id_param->process( args => \%args,
                                 where => \@where );

    # handle optional 'name' param
    my $name_param = GRNOC::MetaParameter->new( name => "name",
                                              field => "name" );

    @where = $name_param->process( args => \%args,
                                 where => \@where );

    # handle optional 'abbr' param
    my $abbr_param = GRNOC::MetaParameter->new( name => "abbr",
                                              field => "abbr" );

    @where = $abbr_param->process( args => \%args,
                                 where => \@where );

    # get the order_by value
    my $order_by_param = GRNOC::MetaParameter::OrderBy->new();
    my $order_by = $order_by_param->parse( %args );
    if (! $order_by) { $order_by = "name"; }

    my $limit = $args{'limit'};
    my $offset = $args{'offset'};

    my $from_sql = "$name ";

    my $results = $self->dbq_rw()->select( table => $from_sql,
                                           fields => \@select_fields,
                                           where => [-and => \@where],
                                           order_by => $order_by,
                                           limit => $limit,
                                           offset => $offset );

    if ( !$results ) {

        $self->error( "An unknown error occurred getting the ${name}s" );
        return;
    }

    my $num_rows = $self->dbq_rw()->num_rows();

    # add country_names for organizations
    if ($name eq "organization") {
        my $data = GRNOC::NetSage::ResourceDB::DataService::Data->new;
        my $countries = $data->get_countries();
        foreach my $res (@$results) {
            my $code = $res->{'country_code'};
            $res->{'country_name'} = $countries->{$code};
        }
    }

    my $result = GRNOC::NetSage::ResourceDB::DataService::Result->new( results => $results,
                                                                 total => $num_rows,
                                                                 offset => $offset );

    return $result;

}

sub get_events {
    my ($self, %args) = @_;

    my $remote_user = $args{'remote_user'};

    my $fields = [
        'event.event_id as event_id',
        'event.date as date',
        'event.message as message',
        'event.user as user',
        'event.ip_block_id as ip_block_id',
        'event.project_id as project_id',
        'event.organization_id as organization_id',
        'event.discipline_id as discipline_id',
        'event.role_id as role_id',
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

sub get_loggedin_user {
    my ( $self, %args ) = @_;
    my $result;

    # if they are logged in, get the user's username from $ENV 
    my $env_user = $ENV{'REMOTE_USER'};

    # if no user is logged in, return total= -1
    if (!$env_user) {
        $result = GRNOC::NetSage::ResourceDB::DataService::Result->new(
            results => [{ loggedin => "false",
                          adminuser => "false",
                          username => "",
                          userid => undef }],
            total => -1
        );
        return $result;
    }

    # if user is logged in, look for them in our db. 
    my $from_sql = 'user ';
    my $select_fields = [ 'user_id', 'username', 'name' ];
    my @where = ();

    $args{'username'} = $env_user;
    my $where_param = GRNOC::MetaParameter->new( name => 'username',
                                                 field =>  'user.username');
    @where = $where_param->process( args => \%args,
                                 where => \@where );

    my $dbresults = $self->dbq_ro()->select( table => $from_sql,
                                           fields => $select_fields,
                                           where => [-or => \@where],
                                           );
    if (!$dbresults) {
        $self->error( 'An unknown error occurred searching for a user in resourcedb.' );
        warn( 'An unknown error occurred searching for a user in resourcedb.' );
        return undef;
    }

    my $num_rows = $self->dbq_ro()->num_rows();

    if ($num_rows == 0) {
        # viewer is logged in (via shibboleth) but is not in our db
        $result = GRNOC::NetSage::ResourceDB::DataService::Result->new(
            results => [{ loggedin => "true",
                          adminuser => "false",
                          username => $env_user,
                          userid => undef }],
            total => 0
        );
    } 
    else {
        # viewer is logged in (via shibboleth) and is in our db
        $result = GRNOC::NetSage::ResourceDB::DataService::Result->new(
            results => [{ loggedin => "true",
                          adminuser => "true",
                          username => $env_user,
                          userid => $dbresults->[0]->{'user_id'} }],
            total => 1
        );
    };

    return $result;
}

sub send_us_email {
    # from contact form
    my ( $self, %args ) = @_;

    my $to = $self->{'config'}->get('/config/contacts');

    if (!$args{'phone'}) { $args{'phone'} = " "; }
    my $body =  "FROM:  ".$args{'name'}."\nORG:    ".$args{'org'}."\nEMAIL:  ".$args{'email'}.
                    "\nPHONE:  ".$args{'phone'}."\n\n".$args{'msg'};

    my $email = MIME::Lite->new(
        To => $to,
        From => 'ScienceRegistry',
        Subject => 'Message from Science Registry Contact Form',
        Data => $body
    );

    # Send email. return 1 for success, 0 for error. $self->error('xx') will be displayed to the user.
    eval { $email->send; };
    if($@) {
        warn( 'An error occurred sending an email: '.$@ );
        $self->error( 'An error occurred sending the email.' );
        return 0;
    }

    # this just checks to see if the email was dispatched ok, not if it arrived ok.
    if (!$email->last_send_successful) {
        warn( 'An error occurred sending an email. ' );
        $self->error( 'An error occurred sending the email.' );
        return 0;
    }

    return 1;
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

1;
