#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;
use GRNOC::Config;
use GRNOC::DatabaseQuery;
use Text::CSV;   # need to install perl-Text-CSV
use Data::Dumper;

# This script will read the resource id and a discipline string out of a CSV file and update the Science Registry database.
# Discipline strings must be in the db 'discipline' table already.
# Specify the csv file on the command line with -i or edit default location below. 
# RAN MANUALLY to do a mass update of resources Sept. 2019.  
# Will leave here to edit in case we want to make other changes using a csv file.

# spreadsheet columns
# A [0] = resource_id
# B [1] = new discipline name (changes to discipline_id in the db)
# (first row = headers)

# (if editing to do fields like resource description or name, save the spreadsheet in format "CSV UTF-8" 
# if there are any odd characters!)
#-----------------------------
sub usage() {
  print "  USAGE: perl resources-update_disciplines.pl 
                  [-c <config file>] 
                  [-i <input file>] 
                  [-h | -help] 
  Without parameters, the defaults are 
    config_file with mysql creds = /etc/grnoc/netsage/resourcedb/config.xml 
    input_file = /etc/grnoc/netsage/resourcedb/resource-update.csv) \n";
  exit;
}
#-----------------------------
# The "resource import" user's id 
my $script_user_id = 3; ###  3 = "Resource Import Script" on lensman-dev7 and scienceregistry.grnoc

#------------------------------
# command line option defaults:
# DEFAULT FILE TO IMPORT
my $input_file = "";
# Use same config file as resourcedb (Science Registry)
my $config_file = "/etc/grnoc/netsage/resourcedb/config.xml";
#------------------------------

my $help;
# Get command line parameters
GetOptions( 'config|c=s' => \$config_file,
            'input|i=s' => \$input_file,
            'help|h|?' => \$help 
          );

# Need help?
usage() if $help;

# filename without path. Will be saved in the event msg.
$input_file =~ m{.*\/(.*\.csv)$};
my $filename = $1;

# Read config file to get db connection info
if (!$config_file or ! -f $config_file) {
    die "ERROR: $config_file does not exist\n";
    }
my $config = GRNOC::Config->new(
    config_file => $config_file,
    force_array => 0
);
if (!defined $config) {
    die "ERROR: Unable to parse the config file.\n";
}
my $username = $config->get( '/config/database-readwrite-username' );
my $pw       = $config->get( '/config/database-readwrite-password' );
my $dbname   = $config->get( '/config/database-name' );
my $host     = $config->get( '/config/database-host' );
my $port     = $config->get( '/config/database-port' );

# Connect to db
my $dbq = GRNOC::DatabaseQuery->new(
                'user'      => $username,
                'pass'      => $pw,
                'name'      => $dbname,
                'srv'       => $host,
                'port'      => $port,
                'debug'     => 0
            );
my $conn_res = $dbq->connect();
if(!$conn_res){
    die "Error connecting to DB mysql.";
}
# use utf8mb4 for communication between mysql and this application
$dbq->{'dbh'}->do("SET NAMES utf8mb4");

# csv parser (use instead of just splitting on commas in case some fields have quotes and commas in them.)
# (binary =1 is needed in case there are embedded new line chars)
my $csv = Text::CSV->new({ sep_char => ',',
                           binary => 1     
                         });

# open input file    SET ENCODING TO UTF8 ?????????
open(my $fh, '<:encoding(utf8)', $input_file) or die "ERROR: Could not open input file $input_file\n";

# global variables org_id->{org_name},etc - use to avoid having to query for same names more than once
# (leaving some here for possible future uses of this script)
my $disciplines;
my $orgs;
my $countries;
my $roles;
my $headers = "yes";

# Read CSV File  (this way of reading allows for fields containing embedded newlines)
my $values;
while ( $values = $csv->getline( $fh )) {

if (!defined $values){
    print "BAD LINE\n";
    next;
    }

    # trim values
    map { s/^\s+|\s+$//g; } @$values;

    # skip the header line
    if ($headers eq "yes") {
        print ("Skipped header line\n");
        $headers = "done";
        next;
    }


    # get the discipline id. Exact match is required!
    my $discipline_name = $values->[1];
    my $discipline_id = get_discipline_id($discipline_name);
    $values->[1] = $discipline_id;

    # Update Resource
    update_resource($values);
}

# make sure it's end of the file
if (! $csv->eof) {
    print ("There was an error and the file was not completely imported\n");
    $csv->error_diag();
}

close ($fh);
print ("DONE\n");

#-------------------------------

# some of these may not be needed. Leaving in case we use this script to update something else.
sub get_org_id {
    my $org_name = shift;

    if ($orgs->{$org_name}) {
        return $orgs->{$org_name};
    }

    my $found = $dbq->select(
        table => 'organization',
        fields => [ 'name', 'organization_id' ],
        where => {'name' => $org_name}
    );
    if (!$found) {
        die "Org query error: ".Dumper $dbq->get_error();
    }
    if (@$found == 0) {
        die "ERROR: Org '".$org_name."' was not found in the Registry.";
    }

    my $id = $found->[0]->{'organization_id'}; 
    $orgs->{$org_name} = $id;
    return $id;
}

sub get_country_code {
    my $country_name = shift;

    if ($countries->{$country_name}) {
        return $countries->{$country_name};
    }

    my $found = $dbq->select(
        table => 'country',
        fields => [ 'name', 'country_code' ],
        where => {'name' => $country_name}
    );
    if (!$found) {
        die "Country query error: ".Dumper $dbq->get_error();
    }
    if (@$found == 0) {
        die "ERROR: Country '".$country_name."' was not found in the Registry.";
    }
    
    my $code = $found->[0]->{'country_code'}; 
    $countries->{$country_name} = $code;
    return $code;

}

sub get_discipline_id {
    my $discipline_name = shift;

    if ($disciplines->{$discipline_name}) {
        return $disciplines->{$discipline_name};
    }

    my $found = $dbq->select(
        table => 'discipline',
        fields => [ 'name', 'discipline_id' ],
        where => {'name' => $discipline_name}
    );
    if (!$found) {
        die "Discipline query error: ".Dumper $dbq->get_error();
    }
    if (@$found == 0) {
        die "ERROR: Discipline '".$discipline_name."' was not found in the Registry.";
    }
    
    my $id = $found->[0]->{'discipline_id'}; 
    $disciplines->{$discipline_name} = $id;
    return $id;
}

sub get_role_id {
    my $role_name = shift;

    if ($roles->{$role_name}) {
        return $roles->{$role_name};
    }

    my $found = $dbq->select(
        table => 'role',
        fields => [ 'name', 'role_id' ],
        where => {'name' => $role_name}
    );
    if (!$found) {
        die "Role query error: ".Dumper $dbq->get_error();
    }
    if (@$found == 0) {
        die "ERROR: Role '".$role_name."' was not found in the Registry.";
    }
    
    my $id = $found->[0]->{'role_id'}; 
    $roles->{$role_name} = $id;
    return $id;
}

sub update_resource {
    my $values = shift;

    my $resource_id = $values->[0];
    my $discipline_id = $values->[1];
    
    # update db
    my $res = $dbq->update(
        table => 'ip_block',
        fields => { discipline_id => $discipline_id },
        where => { ip_block_id => $resource_id }
    );
        
    if (! $res) {
        die "Update resource query error: ".Dumper $dbq->get_error();
    }

   # update event (will record current timestamp) (user can be null, but let's keep it for now)
    my $event_id = $dbq->insert(
        table => 'event',
        fields => { user => $script_user_id,
                    message => "resource-update script changed the discipline ($filename)",
                    ip_block_id => $resource_id
                  }
    );
    if (!$event_id) {
        die "Insert event query error: ".Dumper $dbq->get_error();
    }

}

