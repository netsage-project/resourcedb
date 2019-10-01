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
        $err = "Couldn't connect to mysql.";
        return (undef, $err);
    }

    # create the db, if needed, otherwise validate its existence
    $ok = $self->database_created($db);
    if (!$ok) {
        $err = "Couldn't create database.";
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

    # Add tables and/or do updates
    ($version, $err) = $self->update_schema($db, $db_exists);
    return ($version, $err);
}

sub database_created {
    my $self = shift;
    my $db = shift;

    my $err = undef;
    my $ok  = undef;

    # CREATE the resourcedb database (try to)
    $ok = $db->do("create database resourcedb");
    if (!$ok) {
        # An error is created if database already exists, but we can
        # ignore this case (return 2). All others should be handled.
        $err = $DBI::errstr;
        if (index($err, "database exists") != -1) {
            # Database already exists. Will update it.
            return 2;
        } else {
            # some other kind of error
            return 0;
        }
    } else {
        warn "Created database";
    }

    return 1;
}

sub schema_created {
    my $self = shift;
    my $db   = shift;
    my $db_exists   = shift;

    my $err;
    my $ok;
    my $version;

    if ( ! $db_exists ) {
        warn "ERROR - Couldn't add tables since no resourcedb database exists";
        return;
    }

    # Initialize the database from the Schema located at $path - file has sql to CREATE TABLES
    # Also fills in Disciplines, a demo user, etc.
    # NEW INSTALLS SHOULD USE RESOURCEDB.SQL WHICH SHOULD HAVE THE LATEST SQL WITH VERSION SET!!!!
    warn "Creating db tables";
    `mysql -u $self->{'username'} --password=$self->{'password'} -D resourcedb < $self->{'schema'}`;

    ($version, $err) = $self->version($db);
    if (defined $err) {
        warn "Failure occurred while checking version: $err";
    }

    if (!defined $version) {
        # The version was not set by the database schema.
        warn "Setting schema version to '0.0.0.1'";
        $ok = $db->do("insert into version (version) values ('0.0.1')");
        if (!$ok) {
            $err = "Couldn't set initial schema version: " . $DBI::errstr . "\n";
        }
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
        # if no version table or version number in it, create tables, etc.
        warn "Initializing database!";
        ($version, $err) = $self->schema_created($db, $db_exists);
        if (defined $err) {
            warn "Could not initialize_schema: $err";
        } else {
            warn "Schema initialized";
        }
    }

    # NEW INSTALLS SHOULD USE RESOURCEDB.SQL WHICH SHOULD HAVE THE LATEST SQL WITH VERSION SET!!!!
    # so these upgrade scripts are only historical records for fresh installs!

# we don't need upgrade scripts until we have more than 1 deployment!
# still update the version number though!
# EXAMPLE CALL
#    # upgrade from 0.1.0 to 0.1.1
#    if ($version eq '0.1.0') {
#        ($version, $err) = $self->upgrade_to_0_1_1($db, $version);
#    }


    # at this point, everything should be up-to-date
    if ($version eq '0.1.1') { 
        warn ("Schema is up-to-date - version $version"); 
    } else  { 
        warn ("Schema version is $version. Util.pm says the most recent version is 0.1.1 !"); 
        $err ="Schema version is $version. Util.pm says the most recent version is 0.1.1 !"; 
    }

    return ($version, $err);
}

    # Place upgrade script for next schema version here:

## EXAMPLE UPGRADE SCRIPT
#sub upgrade_to_0_0_14 {
#    my $self    = shift;
#    my $db      = shift;
#    my $version = shift;
##
#    my $err = undef;
#    # recreate table 'user' with a numerical key
#
#    my $query = "DROP TABLE IF EXISTS user";
#    my $ok = $db->do( $query );
#    if (!$ok) {
#        $err = $DBI::errstr;
#        if (defined $err) {
#            warn "Couldn't drop users table: $err";
#            return ($version, $err);
#        }
#        warn "Database schema version is undefined.";
#    }
#    
#    $query = "CREATE TABLE user (
#        user_id int AUTO_INCREMENT PRIMARY KEY,
#        username varchar(20) UNIQUE,
#        name varchar(50)
#    )";
#
#    $ok = $db->do( $query );
#    if (!$ok) {
#        $err = $DBI::errstr;
#        if (defined $err) {
#            warn "Couldn't create users table: $err";
#            return ($version, $err);
#        }
#        warn "Database schema version is undefined.";
#    }
#    warn "Table users created. ";
#
#    my @queries;
#    # insert demo and lensman users
#    $query = "insert into user set user_id=1, username='demo', name='old single user'";
#    push(@queries, $query);
#    $query = "insert into user set user_id=2, username='lensman', name='Lisa Ensman'";
#    push(@queries, $query);
#    # change 'user_id' field to 'user' to record the id of the person who made the change.
#    $query = "ALTER TABLE event ADD COLUMN user int AFTER date";
#    push(@queries, $query);
#    $query = "UPDATE event SET user=1 WHERE user_id='demo'";
#    push(@queries, $query);
#    $query = "UPDATE event SET user=2 WHERE user_id='lensman'";
#    push(@queries, $query);
#    $query = "ALTER TABLE event DROP COLUMN user_id";
#    push(@queries, $query);
#    # add columns to record id's of disciplines, roles, and users that were added/edited.
#    $query = "ALTER TABLE event ADD COLUMN discipline_id int, ADD COLUMN role_id int, ADD COLUMN user_id int";
#    push(@queries, $query);
#
#    foreach $query (@queries) {
#        $ok = $db->do( $query );
#        if (!$ok) {
#            $err = $DBI::errstr;
#            if (defined $err) {
#                warn "Couldn't do '".$query."'. ERROR: $err";
#                return ($version, $err);
#            }
#            warn "Database schema version is undefined.";
#        }
#        warn "Query '".$query."' DONE ";
#    }
#
#    $version = '0.0.14';
#    my $updated_ok = $self->_update_version($db, $version);
#    return ($version, $err);
#}


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
