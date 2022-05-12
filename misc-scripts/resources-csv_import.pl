#!/usr/bin/perl

# USE THIS SCRIPT TO IMPORT RESOURCES FROM A SPREADSHEET FILLED OUT BY AN ORGANIZATION
# RUN MANUALLY

use strict;
use warnings;

use Getopt::Long;
use GRNOC::Config;
use GRNOC::DatabaseQuery;   # install perl-GRNOC-DatabaseQuery
use Text::CSV;              # install perl-Text-CSV
use Data::Dumper;

# This script will pull resource data out of a CSV file and put it into the Science Registry database.
# Save the spreadsheet in format "CSV UTF-8"!  Required columns are listed below.
# The CSV file must have exact matches to existing organization, country, discipline, and role names.
# ! Check the IP blocks in the CSV file. The script will warn you if there is a string match to any of them in the registry already, 
# ! but does NOT check for, eg, a /32 belonging to an existing /24. 
# ! It will go ahead and enter it after printing a warning!
# The script will skip resources where the resource name or abbr+org_id are already in the db.
# DO BEFORE RUNNING:  Check everything over carefully.
#                     Enter all Organizations in the database
#                     Specify the csv file on the command line with -i or edit default location below. 
#                     Specify 'source' on the command line with -s using some unique descriptive text.
#                     see command line options below
# spreadsheet columns
# A [0] = org name (changed to org_id for saving to db table)
# B [1] = resource name
# C [2] = resource abbr (required for checks)
# D [3] = ip list
# E [4] = asn
# F [5] = resource url 
# G [6] = description
# H [7] = lat, long
# I [8] = country (changed to country_code)
# J [9] = discipline (changed to discipline_id)
# K [10]= role (changed to role_id)
# L [11]= notes ($source is appended)
#-----------------------------
sub usage() {
  print "  USAGE: perl resources-csv_import.pl
                  [--mode|-m <test or doit>] 
                  [--config|-c <config file>] 
                  [--input|-i <input file>] 
                  [--source|-s '<source of imported info>]'
                  [--help|-h] 
    Defaults:
    mode = test  
        Change to 'doit' when you're ready to modify the database!
    config_file = /etc/grnoc/netsage/resourcedb/config.xml 
        Change the path if necessary.
    input_file = /etc/grnoc/netsage/resourcedb/resource-import.csv 
        Change the filename to something descriptive, and the path if you like! Filename is saved to the event.
    source = 'Info imported from spreadsheet.' 
        Change this to include who or where the info came from! \n"; 
  exit;
}
#-----------------------------
# Set command line option defaults:
# 'test' will check the spreadsheet data not modify the database
my $mode = "test";
# Default file to import
my $input_file = "/etc/grnoc/netsage/resourcedb/resource-import.csv";
# Use same config file as resourcedb (Science Registry)
my $config_file = "/etc/grnoc/netsage/resourcedb/config.xml";
# Description of where the resources came from
my $source = "Info imported from spreadsheet.";
# 
my $help;

# The "resource import" user's id 
my $script_user_id = 3; ###  3 = "Resource Import Script" in the database on lensman-dev7 and scienceregistry.grnoc

# Get command line parameters
GetOptions( 'mode|m=s' => \$mode,
            'config|c=s' => \$config_file,
            'input|i=s' => \$input_file,
            'source|s=s' => \$source,
            'help|h|?' => \$help 
          );

# Need help?
usage() if $help;

print " Mode = $mode \n Config file = $config_file \n Input file = $input_file \n Source description = $source \n\n";
print "Set mode to 'doit' when you're ready to modify the database!\n\n";

# check file and get filename without path to be saved in the event msg.
if (! -f $input_file) {
    die "ERROR: $input_file does not exist\n";
    }
$input_file =~ m{.*\/(.*\.csv)$};
my $filename = $1;

# Read config file to get db connection info
if (! -f $config_file) {
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
my $orgs;    
my $countries;
my $disciplines;
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


    # get the org id (make sure org exists already). Exact match is required!
    # Will die if not found.
    my $org_name = $values->[0];
    next if ($org_name eq '');
    my $org_id = get_org_id($org_name);
    $values->[0] = $org_id;

    # remove all spaces from the IP list before saving to the db (this is important for make-mmdb.pl)
    $values->[3] =~ s/\s//g;    

    # check if the resource name is already in the registry [if yes, skip this resource]
    # or if the org + resource abbr is already in the registry [if yes, skip this resource]
    # or if any of the ips and blocks are already in [if yes, warn user] (just string matching)
    my $res_name = $values->[1];
    my $res_abbr = $values->[2];
    my $ip_list = $values->[3];
    my $skip = do_checks ($res_name, $res_abbr, $org_id, $ip_list);         
    next if ($skip);

    # get the country code. Exact match is required!
    my $country_name = $values->[8];
    my $country_code = get_country_code($country_name);
    $values->[8] = $country_code;

    # get the discipline id. Exact match is required!
    my $discipline_name = $values->[9];
    my $discipline_id = get_discipline_id($discipline_name);
    $values->[9] = $discipline_id;

    # get the role id. Exact match is required!
    my $role_name = $values->[10];
    my $role_id = get_role_id($role_name);
    $values->[10] = $role_id;

    # Add Resource
    add_resource($values);
}

# make sure it's end of the file
if (! $csv->eof) {
    print ("There was an error and the file was not completely imported\n");
    $csv->error_diag();
}

close ($fh);
print ("DONE\n");

#-------------------------------

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
        print "ERROR: Org '".$org_name."' was not found in the Registry.\n";
        exit if ($mode ne 'test');
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
        print "ERROR: Country '".$country_name."' was not found in the Registry.\n";
        exit if ($mode ne "test"); 
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
        print "ERROR: Discipline '".$discipline_name."' was not found in the Registry.\n";
        exit if ($mode ne "test"); 
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
        print "ERROR: Role '".$role_name."' was not found in the Registry.\n";
        exit if ($mode ne "test"); 
    }
    
    my $id = $found->[0]->{'role_id'}; 
    $roles->{$role_name} = $id;
    return $id;
}

sub do_checks {
    my $res_name = shift;
    my $res_abbr = shift;
    my $org_id = shift;
    my $ip_list = shift;

    # abbr can only be 50 chars
    my $abbr_length = length $res_abbr;
    if ($abbr_length > 50) {
        print "TRUNCATING short name for '$res_name' to 50 chars!\n";
        $res_abbr = substr($res_abbr, 0, 50);
    }

    # See if the resource name, or org+abbr, has been used already (eg, part of the csv file already imported)
    # If yes, just return 1 and skip this row in the csv file.
    my $found = $dbq->select(
        table => 'ip_block',
        fields => [ 'ip_block_id', 'name' ],
        where => { 'name' => $res_name }
    );
    if (!$found) {
        die "Resource query error: ".Dumper $dbq->get_error();
    }
    if (@$found > 0) {
        print "SKIPPING resource '$res_name'. This name is already in the Registry.\n";
        # to skip insert
        return 1;
    }
    
    $found = $dbq->select(
        table => 'ip_block',
        fields => [ 'ip_block_id', 'name' ],
        where => { 'organization_id' => $org_id, 'abbr' => $res_abbr }
    );
    if (!$found) {
        die "Resource query2 error: ".Dumper $dbq->get_error();
    }
    if (@$found > 0) {
        print "SKIPPING resource '$res_name'. The org+shortname is already in the Registry.\n";
        # to skip insert
        return 1;
    }

    # Make sure all IPs are in CIDR notation (have a / followed by 2-3 digits). 
    # See if any of the CIDRs in the ip list are already in the registry (exact string match)
    # If yes, print out a warning, but continue.
    my @ips = split(',', $ip_list);
    foreach my $ip (@ips) {
        if ( $ip !~ /.*\/\d{2,3}/ ) {
            print "ERROR: A '/xx' is missing in '$ip'\n";
            exit if ($mode ne "test"); 
        }
        if ( $ip =~ /.*\/.*\/.*/ ) {
            print "ERROR: Looks like a missing comma between IPs : '$ip'\n";
            exit if ($mode ne "test"); 
        }
        my $found = $dbq->select(
            table => 'ip_block',
            fields => [ 'ip_block_id', 'name' ],
            where => { 'addr_str' => {'LIKE', '%'.$ip.'%'} }
        );
        if (!$found) {
            die "IP query error: ".Dumper $dbq->get_error();
        }
        if (@$found > 0) {
            print "WARNING: $ip of resource '$res_name' is already in the Registry! \n".
                "         See existing resource '".$found->[0]->{'name'}."'.\n".
                "         Inserting the new resource with this IP anyway!\n";
        }
    } 
    # to continue with insert
    return 0;
}

sub add_resource {
    my $values = shift;

    my $org_id = $values->[0];
    my $name = $values->[1];
    my $abbr = substr($values->[2], 0, 50);
    my $ips = $values->[3];
    my $asn = $values->[4];
    my $res_url = $values->[5];
    my $desc = $values->[6];
    my $location = $values->[7];
    my $country_code = $values->[8];
    my $discipline_id = $values->[9];
    my $role_id = $values->[10];
    if ($values->[11]) { $values->[11] = $values->[11]."   "; }
    my $notes = $values->[11].$source; 
    # lat and long - keep only up to 4 decimal places
    my ($lat, $long) = split(",", $location);
    ($lat)  = $lat  =~ /(-?\d+\.\d{0,4})/; 
    ($long) = $long =~ /(-?\d+\.\d{0,4})/; 
    
# if testing, just print
if ($mode eq "test") {
    no warnings qw(uninitialized);    
    print "---WOULD INSERT:  $name, ABBR: $abbr, IPs: $ips, ORG_ID: $org_id, COUNTRY_CODE: $country_code, DISC_ID: $discipline_id, ROLE_ID: $role_id\n";
}
# if mode=doit, insert
elsif ($mode eq "doit") {

    # insert into db
    my $res_id = $dbq->insert(
        table => 'ip_block',
        fields => { name => $name,
                    abbr => $abbr,
                    description => $desc,
                    addr_str => $ips,
                    asn => $asn,
                    organization_id => $org_id,
                    country_code => $country_code,
                    latitude => $lat,
                    longitude => $long,
                    discipline_id => $discipline_id,
                    role_id => $role_id,
                    notes => $notes,
                    url => $res_url
                   }
    );
        
    if ($res_id) {
        print "Inserted resource $res_id : $name\n";
    } else {
        die "Insert resource query error: ".Dumper $dbq->get_error();
    }

   # insert event (will record current timestamp) (user can be null, but let's keep it for now)
    my $event_id = $dbq->insert(
        table => 'event',
        fields => { user => $script_user_id,
                    message => "resource import script created this resource ($filename)",
                    ip_block_id => $res_id
                  }
    );
    if (!$event_id) {
        die "Insert event query error: ".Dumper $dbq->get_error();
    }

} # end if doit
else { 
    die "Unrecognized mode"; 
}

}

