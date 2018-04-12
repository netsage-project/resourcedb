#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;
use GRNOC::Config;
use GRNOC::DatabaseQuery;
use Text::CSV;   # perl-Text-CSV
use Data::Dumper;

# This script will pull organization data out of a CSV file and put it into the Science Registry database.
# Col. 1 = org name,  col. 2 = org abbr,  col. 3 = org country code (if any)

# Use same config file as resourcedb (Science Registry)
my $config_file = "/etc/grnoc/netsage/resourcedb/config.xml";
my $input_file = "/etc/grnoc/netsage/resourcedb/org-import.csv";

my $help;
#-----------------------------
sub usage() {
  print "  USAGE: perl organization-import.pl [-c <config file>] [-i <input file>] [-h] 
  Without parameters, the defaults are 
    config_file = /etc/grnoc/netsage/resourcedb/config.xml 
    input_file = /etc/grnoc/netsage/resourcedb/org-import.csv) \n";
  exit;
}
#-----------------------------

# defaults can be overridden on command line (-c and -o)
GetOptions( 'config|c=s' => \$config_file,
            'input|i=s' => \$input_file,
            'help|h|?' => \$help 
          );

# did they ask for help?
usage() if $help;


# Read config file to get db connection info
if (! -f $config_file) {
    print "$config_file does not exist\n";
    die;
    }

my $config = GRNOC::Config->new(
    config_file => $config_file,
    force_array => 0
);

if (!defined $config) {
    print "Unable to parse the config file.\n";
    die;
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
    print "Error connecting to DB mysql.";
    die;
}

# Try to open input file
my $fh;
if (! open($fh, '<', $input_file) ) {
    print "Could not open input file $input_file\n";
    die;
}

# csv parser (needed in case some fields have quotes and commas in them.
my $csv = Text::CSV->new({ sep_char => ',' });

my @fields;
my $input_name;
my $input_abbr;
my $input_country;

while (my $line = <$fh>) {
    # read org info 
    chomp $line;
    if ($csv->parse($line)) {
        @fields = $csv->fields();
        $input_name = $fields[0];
        $input_abbr = $fields[1];
        $input_country = $fields[2]; # country code 
        if (!$input_country) { $input_country = "??"; }
    } else {
        print ("Line could not be parsed: $line\n");
        next;
    }
 
    # see if org name is already in the db
    my $found = $dbq->select(
        table => 'organization',
        fields => [ 'name' ],
        where => {'name' => $input_name}
    );
    
    if (!$found) {
        print "Select query Error: ".Dumper $dbq->get_error();
        die;
    }
    if (@$found > 0) {
        print "Already in db: $input_name \n";
        next;
    }
    
    # insert into db
    my $org_id = $dbq->insert(
        table => 'organization',
        fields => { 'name' => $input_name,
                    'abbr' => $input_abbr,
                    'country_code' => $input_country }
    );
        
    if (!$org_id) {
        print "Insert query Error: ".Dumper $dbq->get_error();
        die;
    }
}

close($fh);

print "DONE\n";
