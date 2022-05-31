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
# The script will skip resources where the resource name is already in the db (so you can run the same csv again)
# DO BEFORE RUNNING:  Check everything over carefully.
#                     Enter all Organizations and Projects in the database
#                     Specify the csv file on the command line with -i or edit default location below. 
#                     Specify 'source' on the command line with -s using some unique descriptive text.
#                     Run in test mode.
#                     see command line options below
# spreadsheet is assumed to have 1 row of headers
# spreadsheet columns:
#  A [0] = notes (will NOT import)
# *B [1] = ip list
#  C [2] = ASN
# *D [3] = organization name (changes to org_id)
#  E [4] = organization abbreviation (normally used to make full resource name)
#  F [5] = sub-org (optional)
# *G [6] = resource base name (name without org or sub-org)
#  H [7] = resource short name (optional)
# *I [8] = discipline (changes to discipline_id)
#  J [9] = resource description
#  K [10] = resource url
#  L [11] = resource's lat, long
# *M [12] = country (changes to country_code)
# *N [13] = role (changes to role_id)
# *O [14] = project (changes to project_id)
# * required (E,F, and or G is required)
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
my $projects;
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

    # IP list - remove all spaces before saving to the db (this is important for make-mmdb.pl)
    $values->[1] =~ s/\s//g;    
    if (! $values->[1] or $values->[1] eq ""){
        print "?-?-?-?-? NO IPs ????? Skipping.\n-------------\n";
        next;
    }
    my $ip_list = $values->[1];

    # Construct full resource name
    my @parts;
    #my $org_abbr = "";
    push(@parts, $values->[4]) if ($values->[4] ne "");
    #my $sub_org = ""; 
    push(@parts, $values->[5]) if ($values->[5] ne "");
    #my $res_base_name = "";
    push(@parts, $values->[6]) if ($values->[6] ne "");;
    my $full_res_name = join(" - ",@parts);
    if (! $full_res_name) {
        print "?-?-?-?-? NO RESOURCE NAME (org abbr, sub org, or base name) ????? Skipping.\n-------------\n";
        next;
    }

    # Get the org id (make sure org exists already). Exact match is required!
    # Will die in the sub if not found.
    my $org_name = $values->[3];
    my $org_id = get_org_id($org_name);
    $values->[3] = $org_id;

    # Check if the resource name is already in the registry [if yes, skip this resource]
    # Check if any of the ips are already in the registry [if yes, just warn user] (This is just string matching!)
    my $skip = do_checks ($full_res_name, $ip_list);         
    next if ($skip);

    # Get the country code. Exact match is required!
    # Will die in the sub if not found.
    my $country_name = $values->[12];
    my $country_code = get_country_code($country_name);
    $values->[12] = $country_code;

    # Get the discipline id. Exact match is required!
    # Will die in the sub if not found.
    my $discipline_name = $values->[8];
    my $discipline_id = get_discipline_id($discipline_name);
    $values->[8] = $discipline_id;

    # Get the role id. Exact match is required!
    # Will die in the sub if not found.
    my $role_name = $values->[13];
    my $role_id = get_role_id($role_name);
    $values->[13] = $role_id;

    # Get the project id. Exact match is required!
    # Will die in the sub if not found.
    my $project_name = $values->[14];
    my $project_id = get_project_id($project_name);
    $values->[14] = $project_id;

    # Add Resource 
    # (if testing, just print something instead)
    add_resource($full_res_name, $values);
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

sub get_project_id {
    my $project_name = shift;

    if ($projects->{$project_name}) {
        return $projects->{$project_name};
    }

    my $found = $dbq->select(
        table => 'project',
        fields => [ 'name', 'project_id' ],
        where => {'name' => $project_name}
    );
    if (!$found) {
        die "Project query error: ".Dumper $dbq->get_error();
    }
    if (@$found == 0) {
        print "ERROR: Project '".$project_name."' was not found in the Registry.\n";
        exit if ($mode ne "test"); 
    }
    
    my $id = $found->[0]->{'project_id'}; 
    $projects->{$project_name} = $id;
    return $id;
}

sub do_checks {
    my $full_res_name = shift;
    my $ip_list = shift;

    # See if the resource name has been used already (eg, part of the csv file already imported)
    # If yes, just return 1 and skip this row in the csv file.
    my $found = $dbq->select(
        table => 'ip_block',
        fields => [ 'ip_block_id', 'name' ],
        where => { 'name' => $full_res_name }
    );
    if (!$found) {
        die "Resource query error: ".Dumper $dbq->get_error();
    }
    if (@$found > 0) {
        print "SKIPPING resource '$full_res_name'. This name is already in the Registry.\n-------------\n";
        # to skip insert
        return 1;
    }
    
    # Make sure all IPs are in CIDR notation (have a / followed by 2-3 digits). 
    # See if any of the CIDRs in the ip list are already in the registry (exact string match)
    # If yes, print out a warning, but continue.
    my @ips = split(',', $ip_list);
    foreach my $ip (@ips) {
        if ( $ip !~ /.*\/\d{2,3}$/ ) {
            print "ERROR: A '/xx' is missing in '$ip'\n";
            exit if ($mode ne "test"); 
        }
        if ( $ip =~ /.*\/.*\/.*/ ) {
            print "ERROR: Looks like a typo or missing comma between IPs : '$ip'\n";
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
            print "WARNING: $ip of resource '$full_res_name' is already in the Registry! \n".
                "         See existing resource '".$found->[0]->{'name'}."'.\n".
                "         Will insert the new resource with this IP anyway!\n";
        }
    } 
    # return 0 to continue with insert
    return 0;
}

sub add_resource {
    my $full_res_name = shift;
    my $values = shift;

    my $ips = $values->[1];
    my $asn = $values->[2];
    my $org_id = $values->[3];
    my $res_abbr = substr($values->[7], 0, 50);
    $res_abbr = undef if ($res_abbr eq "");  # so a null will be inserted (so it won't complain about not being unique)
    my $discipline_id = $values->[8];
    my $desc = $values->[9];
    my $res_url = $values->[10];
    my $location = $values->[11];
    my $country_code = $values->[12];
    my $role_id = $values->[13];
    my $proj_id = $values->[14];
    my $notes = $source; 

    # lat and long - keep only up to 4 decimal places
    my ($lat, $long);
    if ($location eq "") { 
        $lat = undef; # so a null will be inserted (even with this, UI doesn't not show Project or Event on resource page !?!) 
        $long = undef;
    }
    else {
        ($lat, $long) = split(",", $location);
        ($lat)  = $lat  =~ /(-?\d+\.\d{0,4})/; 
        ($long) = $long =~ /(-?\d+\.\d{0,4})/; 
   }
 
# if testing, just print (skip warnings about concatenating unset values)
if ($mode eq "test") {
    no warnings qw(uninitialized);    
    print "WOULD INSERT:  $full_res_name, ABBR: $res_abbr, IPs: $ips, ASN: $asn, ORG_ID: $org_id, COUNTRY_CODE: $country_code, \n";
    print "                DISCIPLINE_ID: $discipline_id, ROLE_ID: $role_id,  LAT: $lat, LONG: $long, PROJECT_ID: $proj_id, NOTES: $notes\n";
    print "-------------\n";
}
# if mode=doit, insert
elsif ($mode eq "doit") {

    # Insert into db
    my $res_id = $dbq->insert(
        table => 'ip_block',
        fields => { name => $full_res_name,
                    abbr => $res_abbr,
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
        print "Inserted resource id $res_id : $full_res_name\n-------------\n";
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

   # Link project
   my $link_id = $dbq->insert(
        table => 'ip_block_project',
        fields => { ip_block_id => $res_id,
                    project_id => $proj_id
                  }
   );
    if (!$link_id) {
        die "Link project query error: ".Dumper $dbq->get_error();
    }


} # end if doit
else { 
    die "Unrecognized mode"; 
}

}

