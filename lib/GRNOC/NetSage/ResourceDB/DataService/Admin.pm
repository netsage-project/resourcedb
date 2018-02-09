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

sub get_users {

    my ( $self, %args ) = @_;

    my $from_sql = 'user';

    my $select_fields = [ 'user_id', 'name' ];

    my @where = ();

    # handle optional user_id param
    my $user_id_param = GRNOC::MetaParameter->new(name => 'user_id', field => 'user.user_id');
    @where = $user_id_param->process(args => \%args, where => \@where);

    my $results = $self->dbq_ro()->select( table => $from_sql,
                                           fields => $select_fields,
                                           where => [-or => \@where],
                                           );
    if (!$results) {
        $self->error( 'An unknown error occurred getting users.' );
        return;
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

    my $from_sql = 'user ';

    my $select_fields = [ 'user_id', 'name' ];

    my @where = ();

    # handle required user_id param - always the username in .htpasswd
    $args{'user_id'} = $ENV{'REMOTE_USER'};

    my $id_param = GRNOC::MetaParameter->new( name => 'user_id',
                                              field =>  'user.user_id');
    @where = $id_param->process( args => \%args,
                                 where => \@where );

    my $results = $self->dbq_ro()->select( table => $from_sql,
                                           fields => $select_fields,
                                           where => [-or => \@where],
                                           );
    if (!$results) {
        $self->error( 'An unknown error occurred getting users.' );
        return;
    }

    my $num_rows = $self->dbq_ro()->num_rows();

    # if user was not found, add them to the db with user_id=name=username, and no other info.
    if ($num_rows == 0) {
        warn("LOGGED IN USER $ENV{'REMOTE_USER'} NOT FOUND. ADDING TO DB.");
        my $add_result = $self->add_user(
                           user_id => $ENV{'REMOTE_USER'},
                           name => $ENV{'REMOTE_USER'}
        );

        if (!$add_result) {
            $self->error( 'An unknown error occurred adding the user to the db.' );
            return;  
        }
        # if ok, set $results to return the same info we put in the db instead of querying.
        $results = [ {
                    "user_id" => $ENV{'REMOTE_USER'},
                    "name" => $ENV{'REMOTE_USER'}
                    } ];
        $num_rows = 1;
    } 

    my $result = GRNOC::NetSage::ResourceDB::DataService::Result->new(
        results => $results,
        total => $num_rows
    );

    return $result;
}

sub add_user {

    my ( $self, %args ) = @_;

    my $remote_user = $args{'remote_user'};
    # TODO: check remote_user, what should this be?

    my $from_sql = 'user ';

    my $fields = $self->_get_user_args( %args );

    my $results = $self->dbq_rw()->insert( table => $from_sql,
                                           fields => $fields
                                       );

    if ( !$results ) {
        $self->error( 'An unknown error occurred adding the user.' );
        return;
    }
    $self->add_events(
        message => "User $ENV{'REMOTE_USER'} was added to the database on login."
    );

    my $num_rows = $self->dbq_rw()->num_rows();

    return [{'rows_added' => $results}];
}

sub add_ip_blocks {

    my ( $self, %args ) = @_;

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
    $self->add_events(
        ip_block_id => $results,
        message => "$ENV{'REMOTE_USER'} created this resource."
    );

    my $num_rows = $self->dbq_rw()->num_rows();

    return [{'ip_block_id' => $results}];
}

sub add_projects {

    my ( $self, %args ) = @_;

    my $remote_user = $args{'remote_user'};

    my $from_sql = 'project ';

    my $fields = $self->_get_project_args( %args );

    my $results = $self->dbq_rw()->insert( table => $from_sql,
                                           fields => $fields
                                       );

    if ( !$results ) {
        $self->error( 'An unknown error occurred adding the projects.' );
        return;
    }
    $self->add_events(
        project_id => $results,
        message => "$ENV{'REMOTE_USER'} created this project."
    );

    my $num_rows = $self->dbq_rw()->num_rows();

    return [{'project_id' => $results}];
}

sub add_table_dynamically {
    my ( $self, $name, %args ) = @_;

    if ( !$self->_is_dbname_valid( $name ) ) {
        $self->error( "Invalid db name specified: $name" );
        return;
    }

    my $remote_user = $args{'remote_user'};

    my $from_sql = "$name ";

    my $name_val = $args{'name'};

    my $field_obj = $self->dynamic_fields();
    my @field_list = keys %{ $field_obj->{ $name } };
    my $fields = {};

    foreach my $field ( @field_list ) {
        # add to field list
        $fields->{ $field } = $args{ $field } if defined $args{ $field };
    }


    my $results = $self->dbq_rw()->insert( table => $from_sql,
                                           fields => $fields
                                         );
    if ( !$results ) {
        $self->error( "An unknown error occurred inserting the ${name}" );
        return;
    }

    $self->add_events(
        "${name}_id" => $results,
        message => "$ENV{'REMOTE_USER'} created this $name."
    );

    return [{ "${name}_id" => $results }];
}


sub update_ip_blocks {

    my ( $self, %args ) = @_;

    my $remote_user = $args{'remote_user'};
    # TODO: check remote_user, what should this be?

    my $from_sql = 'ip_block ';

    my $fields = $self->_get_ip_block_args( %args );

    my @where = ();

    # handle required ip_block_id param
    my $id_param = GRNOC::MetaParameter->new( name => 'ip_block_id',
                                                   field => 'ip_block.ip_block_id' );

    @where = $id_param->process( args => \%args,
                                      where => \@where );

    my $results = $self->dbq_rw()->update( table => $from_sql,
                                           fields => $fields,
                                           where => [-and => \@where],
                                       );

    if ( !$results ) {
        $self->error( 'An unknown error occurred updating the ip blocks.' );
        return;
    }
    $self->add_events(
        ip_block_id => $args{'ip_block_id'},
        message => "$ENV{'REMOTE_USER'} updated this resource."
    );

    my $num_rows = $self->dbq_rw()->num_rows();

    $results = [ {'ip_block_id' => $args{'ip_block_id'} }];
    return $results;

}

sub update_table_dynamically {

    my ( $self, $name, %args ) = @_;

    if ( !$self->_is_dbname_valid( $name ) ) {
        $self->error( "Invalid db name specified: $name" );
        return;
    }

    my $remote_user = $args{'remote_user'};

    # handle required ${name}_id param
    my $id_param = GRNOC::MetaParameter->new( name => "${name}_id",
                                              field => "${name}_id" );

    my @where = ();

    @where = $id_param->process( args => \%args,
                                      where => \@where );

    my $from_sql = "$name ";

    my $name_val = $args{'name'};

    my $field_obj = $self->dynamic_fields();
    my @field_list = keys %{ $field_obj->{ $name } };
    my $fields = {};
    foreach my $field ( @field_list ) {
        # add to field list
        $fields->{ $field } = $args{ $field } if defined $args{ $field };
    }

    my $results = $self->dbq_rw()->update( table => $from_sql,
                                           fields => $fields,
                                           where => [-and => \@where],
                                         );

    if ( !$results ) {

        $self->error( "An unknown error occurred updating the ${name}" );
        return;
    }

    if ( $results == 0 ) {
        $self->error( "No rows affected" );
        return;
    }

    $self->add_events(
        "${name}_id" => $args{"${name}_id"},
        message => "$ENV{'REMOTE_USER'} updated this $name."
    );

    return [{ "${name}_id" => $args{"${name}_id"} }];

}

sub delete_ip_blocks {

    my ( $self, %args ) = @_;

    my $remote_user = $args{'remote_user'};
    # TODO: check remote_user, what should this be?

    my $from_sql = 'ip_block ';

    my @where = ();

    # handle required ip_block_id param
    my $id_param = GRNOC::MetaParameter->new( name => 'ip_block_id',
                                                   field => 'ip_block.ip_block_id' );

    @where = $id_param->process( args => \%args,
                                      where => \@where );

    my $results = $self->dbq_rw()->delete( table => $from_sql,
                                           where => [-and => \@where],
                                       );

    if ( !$results ) {

        $self->error( 'An unknown error occurred deleting the ip blocks.' );
        return;
    }

    if ( $results == 0 ) {
        $self->error( "No rows affected" );
        return;
    }

    my $num_rows = $self->dbq_rw()->num_rows();

    $results = [ {'ip_block_id' => $args{'ip_block_id'} }];
    return $results;

}

sub delete_table_dynamically {

    my ( $self, $name, %args ) = @_;

    if ( !$self->_is_dbname_valid( $name ) ) {
        $self->error( "Invalid db name specified: $name" );
        return;
    }

    my $remote_user = $args{'remote_user'};

    # handle required ${name}_id param
    my $id_param = GRNOC::MetaParameter->new( name => "${name}_id",
                                              field => "${name}_id" );

    my @where = ();

    @where = $id_param->process( args => \%args,
                                      where => \@where );

    my $from_sql = "$name ";

    my $results = $self->dbq_rw()->delete( table => $from_sql,
                                           where => [-and => \@where],
                                         );

    if ( !$results ) {

        $self->error( "An unknown error occurred deleting the ${name}" );
        return;
    }

    if ( $results == 0 ) {
        $self->error( "No rows affected" );
        return;
    }

    return [{ "${name}_id" => $args{"${name}_id"} }];

}

sub _get_user_args {
    my ( $self, %args_in ) = @_;

    my %args = ();

    my @all_args = (
        'user_id',
        'name',
    );

    foreach my $arg( @all_args ) {
        if ( not defined $args_in{ $arg } ) {
            next;
        }
        $args{ $arg } = $args_in{ $arg };
    }

    return \%args;
}

sub _get_project_args {
    my ( $self, %args_in ) = @_;

    my %args = ();

    my @all_args = (
        'name',
        'abbr',
        'description',
        'url',
        'owner',
        'email'
    );

    foreach my $arg( @all_args ) {
        if ( not defined $args_in{ $arg } ) {
            next;
        }
        $args{ $arg } = $args_in{ $arg };
    }

    return \%args;
}

sub _get_ip_block_args {
    my ( $self, %args_in ) = @_;

    my %args = ();

    # TODO: figure out how to set these derived fields:
    #  - addr_lower
    #  - addr_upper
    #  -  mask
    my @all_args = (
        'name',
        'abbr',
        'description',
        'addr_str',
        #'addr_lower',
        #'addr_upper',
        'mask',
        'asn',
        'organization_id',
        'country_code',
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

    return \%args;

}

1;
