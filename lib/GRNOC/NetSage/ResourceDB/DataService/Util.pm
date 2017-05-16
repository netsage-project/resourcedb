#--------------------------------------------------------------------
#----- GRNOC NetSage ResourceDB DataService Library
#-----
#----- Copyright(C) 2017 The Trustees of Indiana University
#--------------------------------------------------------------------
#----- This module contains the functionality to connect to and query
#----- the backend database.  It contains methods that are used as
#----- callbacks for the DataService/GWS.pm library.
#--------------------------------------------------------------------

package GRNOC::NetSage::ResourceDB::DataService::Util;

use strict;
use warnings;

use GRNOC::Log;
use GRNOC::NetSage::ResourceDB::DataService::Data;

use Data::Dumper;
use DBI;

### constructor ###

sub new {
    my $caller = shift;

    my $class = ref( $caller );
    $class = $caller if ( !$class );

    my $self = {'username' => undef,
                'password' => undef,
                'host'     => undef,
                'port'     => undef,
                'schema'   => undef,
                @_};

    bless( $self, $class );

    $self->{'logger'} = GRNOC::Log->get_logger("GRNOC.NetSage.ResourceDB.DataService.Util");

    return $self;
}

sub install_database {
    my $self = shift;

    my $err;
    my $ok;
    my $version;

    my $db = DBI->connect("DBI:mysql:;host=$self->{'host'};port=$self->{'port'}",
                              $self->{'username'},
                              $self->{'password'},
                              {PrintError => 0});
    if (!$db) {
        $self->{'logger'}->error($DBI::errstr);
        $err = "Couldn't connect to database.";
        return (undef, $err);
    }

    $ok = $self->database_created($db);
    if (!$ok) {
        $err = "Couldn't validate database's existence.";
        return (undef, $err);
    }

    my $db_exists = 0;
    if ($ok == 2 ) {
        $db_exists = 1;
    }

    $ok = $db->do("use resourcedb");
    if (!$ok) {
        $err = "Couldn't use resourcedb database: " . $DBI::errstr . "\n";
        return (undef, $err);
    }

    ($version, $err) = $self->update_schema($db, $db_exists);
    return ($version, $err);
}

sub database_created {
    my $self = shift;
    my $db = shift;

    my $err = undef;
    my $ok  = undef;

    $ok = $db->do("create database resourcedb");
    if (!$ok) {
        # An error is created if database already exists, but we can
        # ignore this case. All others should be handled.
        $err = $DBI::errstr;
        if (index($err, "database exists") != -1) {
            print "Database already exists\n";
            return 2;
        } else {
            return 0;
        }
    } else {
        print "Created database\n";
    }

    return 1;
}

sub schema_created {
    my $self = shift;
    my $db   = shift;
    my $db_exists   = shift;

    my $err;
    my $ok;
    my $schema;
    my $version;


    if ( ! $db_exists ) {
        # Initialize the database from the Schema located at $path.
        `mysql -u $self->{'username'} --password=$self->{'password'} -D resourcedb < $self->{'schema'}`;

    }

    ($version, $err) = $self->version($db);
    if (defined $err) {
        warn "Failure occurred while checking version: $err";
    }

    if (!defined $version) {
        # The version was not set by the database schema.
        $ok = $db->do("insert into version (version) values ('0.0.1')");
        warn "Inserting version in schema '0.0.0.1'";
        if (!$ok) {
            $err = "Couldn't set initial schema version: " . $DBI::errstr . "\n";
        }

        warn "Database schema version was configured.";
    }

    return $self->version($db);
}

sub version {
    my $self = shift;
    my $db   = shift;

    my $err;
    my $ok;
    my $version;

    $ok = $db->selectrow_hashref("select * from version");
    if (!$ok) {
        $err = $DBI::errstr;
        if (defined $err) {
            warn "Couldn't get version: $err";
        } else {
            warn "Database schema version is undefined.";
        }
    }

    return ($ok->{'version'}, $err);
}

sub update_schema {
    my $self = shift;
    my $db   = shift;
    my $db_exists   = shift;

    my $version = undef;
    my $err = undef;

    ($version, $err) = $self->version($db);
    if (defined $err || not defined $version) {
        warn "Initializing database!";
        ($version, $err) = $self->schema_created($db, $db_exists);
        if (defined $err) {
            warn "Could not initialize_schema: $err";
        } else {
            warn "Schema initialized";

        }
    }

    if ($version eq '0.0.1') {
        # Place upgrade script for next schema version here.
        ($version, $err) = $self->upgrade_to_0_0_2($db, $version);
    }
    if ($version eq '0.0.2') {
        ($version, $err) = $self->upgrade_to_0_0_3($db, $version);
    }
    if ($version eq '0.0.3') {
        ($version, $err) = $self->upgrade_to_0_0_3_1($db, $version);
    }
    if ($version eq '0.0.3.1') {
        ($version, $err) = $self->upgrade_to_0_0_4($db, $version);
    }

    return ($version, $err);
}

sub upgrade_to_0_0_4 {
    my $self    = shift;
    my $db      = shift;
    my $version = shift;

    my $err = undef;

    my $data = GRNOC::NetSage::ResourceDB::DataService::Data->new;

    # Create table `continent`
    my $query = "
            create table `continent` (
                `continent_id` smallint unsigned not null auto_increment,
                `name` varchar(255), continent_code char(2) not null unique,
                primary key (`continent_id`)
            ) engine=InnoDB
        ";

    my $continent_ok = $db->do( $query );
    if ($continent_ok) {
        warn "Added 'continent' table";
    } else {
        $err = $DBI::errstr;
        if (defined $err) {
            warn "Couldn't add 'continent' table: $err";
            return ($version, $err);
        } else {
            warn "Database schema version is undefined.";
        }
    }

    my $continents = $data->get_continents();

    my @values = ();
    $query = "insert into continent (name, continent_code) values (?, ?)";
    my $sth = $db->prepare($query);
    my @codes = keys %$continents;
    my @names = values %$continents;

    my ( $tuple, $rows ) = $sth->execute_array(undef, \@names, \@codes);

    if ( !$rows ) {
        $continent_ok = 0;
        $err = $err . "; error inserting continents"; 

    } else {
        warn "$rows continents inserted";
    }

    # Create table `country`
    $query = "
            create table `country` (
                `country_id` smallint unsigned not null auto_increment,
                `name` varchar(255), 
                `country_code` char(2) not null unique,
                `continent_code` char(2),
                primary key (`country_id`)
            ) engine=InnoDB
        ";

    my $country_ok = $db->do( $query );
    if ($country_ok) {
        warn "Added 'country' table";
    } else {
        $err = $DBI::errstr;
        if (defined $err) {
            warn "Couldn't add 'country' table: $err";
            return ($version, $err);
        } else {
            warn "Database schema version is undefined.";
        }
    }
    # add foreign key constraint
    $query = "
            alter table country 
                add constraint country_continent_fk 
                foreign key(continent_code) 
                references continent(continent_code) on delete set null on update cascade
            ";

    my $fk_ok = $db->do( $query );
    if ($fk_ok) {
        warn "Added foreign key to 'country' table";
    } else {
        $err = $DBI::errstr;
        if (defined $err) {
            warn "Couldn't add foreign key to 'country' table: $err";
            return ($version, $err);
        } else {
            warn "Database schema version is undefined.";
        }
    }


    my $countries = $data->get_countries();

    @values = ();
    $query = "insert into country (name, country_code) values (?, ?)";
    $sth = $db->prepare($query);
    @codes = keys %$countries;
    @names = values %$countries;

    ( $tuple, $rows ) = $sth->execute_array(undef, \@names, \@codes);

    if ( !$rows ) {
        $country_ok = 0;
        $err = $err . "; error inserting countries"; 

    } else {
        warn "$rows countries inserted";
    }


    my $country_continent_ok;
    my $codes = $data->get_country_continent_codes();

    @values = ();
    $query = "update country set continent_code=? where country_code=?";
    $sth = $db->prepare($query);
    my @countries = keys %$codes;
    my @continents = values %$codes;

    ( $tuple, $rows ) = $sth->execute_array(undef, \@continents, \@countries);

    if ( !$rows ) {
        $country_continent_ok = 0;
        $err = $err . "; error setting continents for countries"; 

    } else {
        warn "$rows country/continent codes updated";
        $country_continent_ok = 1;
    }


    my $drop_columns_ok;
    $query = "alter table ip_block
                drop column country_name,
                drop column continent_name,
                drop column continent_code";
    $drop_columns_ok = $db->do( $query );
    if ($drop_columns_ok) {
        warn "Dropped country name, continent name, continent code columns from ip_block";
    } else {
        $err = $DBI::errstr;
        if (defined $err) {
            warn "Couldn't drop country name, continent name, continent code columns from ip_block table: $err";
            return ($version, $err);
        } else {
            warn "Database schema version is undefined.";
        }
    }


    my $ok = $continent_ok && $country_ok && $country_continent_ok && $fk_ok && $drop_columns_ok;

    if ( $ok ) {
        warn "Schema successfully updated";
        $version = '0.0.4';

    }

    my $updated_ok = $self->_update_version( $db, $version );

    # in this case "$ok" is the # of affected records
    return ($version, $err);
}


sub upgrade_to_0_0_3_1 {
    my $self    = shift;
    my $db      = shift;
    my $version = shift;

    my $err = undef;

    # Add columns to `organization`
    my $query = "alter table `organization`
                 add column `url` varchar(255) after `description`
                ";
    my $org_ok = $db->do( $query );
    if ($org_ok) {
        warn "Added columns to 'organization' table";
    } else {
        $err = $DBI::errstr;
        if (defined $err) {
            warn "Couldn't add columns to 'organization' table: $err";
            return ($version, $err);
        } else {
            warn "Database schema version is undefined.";
        }
    }

    # Add columns to `project`
    $query = "alter table `project`
                 add column `url` varchar(255) after `description`
                ";
    my $project_ok = $db->do( $query );
    if ($project_ok) {
        warn "Added columns to 'project' table";
    } else {
        $err = $DBI::errstr;
        if (defined $err) {
            warn "Couldn't add columns to 'project' table: $err";
            return ($version, $err);
        } else {
            warn "Database schema version is undefined.";
        }
    }

    # Add column to `discipline`
    $query = "alter table `discipline`
                 add column `url` text after `description`
                ";
    my $discipline_ok = $db->do( $query );
    if ($discipline_ok) {
        warn "Added column to 'discipline' table";
    } else {
        $err = $DBI::errstr;
        if (defined $err) {
            warn "Couldn't add columns to 'discipline' table: $err";
            return ($version, $err);
        } else {
            warn "Database schema version is undefined.";
        }
    }

    # Add column to `role`
    $query = "alter table `role`
                 add column `url` text after `description`
                ";
    my $role_ok = $db->do( $query );
    if ($role_ok) {
        warn "Added column to 'role' table";
    } else {
        $err = $DBI::errstr;
        if (defined $err) {
            warn "Couldn't add columns to 'role' table: $err";
            return ($version, $err);
        } else {
            warn "Database schema version is undefined.";
        }
    }


    my $ok = $org_ok && $project_ok && $discipline_ok && $role_ok;

    if ( $ok ) {
        warn "Schema successfully updated";
        $version = '0.0.3.1';

    }

    my $updated_ok = $self->_update_version( $db, $version );

    # in this case "$ok" is the # of affected records
    return ($version, $err);
}

sub upgrade_to_0_0_3 {
    my $self    = shift;
    my $db      = shift;
    my $version = shift;

    my $err = undef;

    # Add columns to `organization`
    my $query = "alter table `organization`
                 add column `description` text after `name`,
                 add column `owner` varchar(255) after `description`,
                 add column `email` varchar(255) after `owner`,
                 add column `postal_code` varchar(50) after `email`,
                 add column `latitude` decimal(9,6) after `postal_code`,
                 add column `longitude` decimal(9,6) after `latitude`,
                 add column `country_name` varchar(255) after `longitude`,
                 add column `continent_name` varchar(255) after `country_name
                ";
    my $org_ok = $db->do( $query );
    if ($org_ok) {
        warn "Added columns to 'organization' table";
    } else {
        $err = $DBI::errstr;
        if (defined $err) {
            warn "Couldn't add columns to 'organization' table: $err";
            return ($version, $err);
        } else {
            warn "Database schema version is undefined.";
        }
    }

    # Add columns to `project`
    $query = "alter table `project`
                 add column `description` text after `name`,
                 add column `owner` varchar(255) after `description`,
                 add column `email` varchar(255) after `owner`
                ";
    my $project_ok = $db->do( $query );
    if ($project_ok) {
        warn "Added columns to 'project' table";
    } else {
        $err = $DBI::errstr;
        if (defined $err) {
            warn "Couldn't add columns to 'project' table: $err";
            return ($version, $err);
        } else {
            warn "Database schema version is undefined.";
        }
    }

    # Add column to `discipline`
    $query = "alter table `discipline`
                 add column `description` text after `name`
                ";
    my $discipline_ok = $db->do( $query );
    if ($discipline_ok) {
        warn "Added column to 'discipline' table";
    } else {
        $err = $DBI::errstr;
        if (defined $err) {
            warn "Couldn't add columns to 'discipline' table: $err";
            return ($version, $err);
        } else {
            warn "Database schema version is undefined.";
        }
    }

    # Add column to `role`
    $query = "alter table `role`
                 add column `description` text after `name`
                ";
    my $role_ok = $db->do( $query );
    if ($role_ok) {
        warn "Added column to 'role' table";
    } else {
        $err = $DBI::errstr;
        if (defined $err) {
            warn "Couldn't add columns to 'role' table: $err";
            return ($version, $err);
        } else {
            warn "Database schema version is undefined.";
        }
    }


    my $ok = $org_ok && $project_ok && $discipline_ok && $role_ok;

    if ( $ok ) {
        warn "Schema successfully updated";
        $version = '0.0.3';

    }

    my $updated_ok = $self->_update_version( $db, $version );

    # in this case "$ok" is the # of affected records
    return ($version, $err);

}


sub upgrade_to_0_0_2 {
    my $self    = shift;
    my $db      = shift;
    my $version = shift;

    my $err = undef;

    my $query = "alter table `ip_block` add column `description` text after `name`";
    my $ok = $db->do( $query );
    if (!$ok) {
        $err = $DBI::errstr;
        if (defined $err) {
            warn "Couldn't add column 'description': $err";
            return ($version, $err);
        } else {
            warn "Database schema version is undefined.";
        }
    } else {
        warn "Added 'description' field";
        $version = '0.0.2';

    }

    my $updated_ok = $self->_update_version( $db, $version );

    # in this case "$ok" is the # of affected records
    return ($version, $err);
}

sub _update_version {
    my ( $self, $db, $version ) = @_;
    my $err;
    my $query = "update version set version=?";
    my $updated_ok = $db->do($query, undef, $version);
    if (!$updated_ok) {
        $err = $DBI::errstr;
        if (defined $err) {
            warn "Couldn't update db version";
        } else {
            warn "Updated db version";

        }

    } else {
        warn "db version was updated to $version";
    }

    return $updated_ok;
}

1;
