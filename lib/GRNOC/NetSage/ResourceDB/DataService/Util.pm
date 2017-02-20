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
    return $self;
}

sub install_database {
    my $self = shift;

    my $err;
    my $ok;
    my $version;

    # 1. Connect to the mysql database
    my $db = DBI->connect("DBI:mysql:;host=$self->{'host'};port=$self->{'port'}",
                              $self->{'username'},
                              $self->{'password'},
                              {PrintError => 0});
    if (!$db) {
        warn "Couldn't connect to database: " . $DBI::errstr . "\n";
        return undef;
    }

    $ok = $self->database_created($db);
    if (!$ok) {
        $err = "Couldn't validate database's existence.";
        return (undef, $err);
    }

    $ok = $db->do("use resourcedb");
    if (!$ok) {
        $err = "Couldn't use resourcedb database: " . $DBI::errstr . "\n";
        return (undef, $err);
    }

    ($version, $err) = $self->update_schema($db);
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

    my $err;
    my $ok;
    my $schema;
    my $version;


    # Initialize the database from the Schema located at $path.
    `mysql -u rdb --password=$self->{'password'} -D resourcedb < $self->{'schema'}`;

    ($version, $err) = $self->version($db);
    if (defined $err) {
        warn "Failure occurred while checking version: $err";
    }

    if (!defined $version) {
        # The version was not set by the database schema.
        $ok = $db->do("insert into version (version) values ('0.0.1')");
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

    my $version = undef;
    my $err = undef;

    ($version, $err) = $self->version($db);
    if (defined $err) {
        warn "Initializing database!";
        ($version, $err) = $self->schema_created($db);
        if (defined $err) {
            warn "Could not initialize_schema: $err";
        }
    }

    if ($version eq '0.0.1') {
        # Place upgrade script for next schema version here.
        ($version, $err) = $self->upgrade_to_0_0_2($db, $version);
    }

    return ($version, $err);
}

sub upgrade_to_0_0_2 {
    my $self    = shift;
    my $db      = shift;
    my $version = shift;

    my $err = undef;

    warn "ResourceDB's database is running the latest schema version.";
    return ($version, $err);
}

1;
