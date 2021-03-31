#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;
use GRNOC::Config;
use GRNOC::DatabaseQuery;
use JSON;
use Data::Dumper;

# This script will pull only organizations (name/abbr/country_code) out of the Science Registry 
# database and write it to a file as JSON.
# RUN MANUALLY

# Defaults
my $help;
# Use same config file as resourcedb (Science Registry)
my $config_file = "/etc/grnoc/netsage/resourcedb/config.xml";
# Name output file with the current timestamp
my $output_file = "/etc/grnoc/netsage/resourcedb/orgdump_".time().".json";

#-----------------------------
sub usage() {
  print "  USAGE: perl organization-export.pl [-c <config file>] [-o <output file>] [-h] 
  Without parameters, the defaults are 
    config_file = /etc/grnoc/netsage/resourcedb/config.xml 
    output_file = /etc/grnoc/netsage/resourcedb/orgdump_<timestamp>.json (must run as sudo) \n";
  exit;
}
#-----------------------------

# defaults can be overridden on command line (-c and -o)
GetOptions( 'config|c=s' => \$config_file,
            'output|o=s' => \$output_file,
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

my $username = $config->get( '/config/database-readonly-username' );
my $pw       = $config->get( '/config/database-readonly-password' );
my $dbname   = $config->get( '/config/database-name' );
my $host     = $config->get( '/config/database-host' );
my $port     = $config->get( '/config/database-port' );

# Try to open output file
my $fh;
if (! open($fh, '>', $output_file) ) {
    print "Could not open output file $output_file\n";
    die;
}

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

# Get info about organizations
my $organizations = $dbq->select(
    table => 'organization',
    fields => [ 'name  as org_name',
                'abbr  as org_abbr',
                'country_code  as org_country_code'
               ]
    );

if (!$organizations) {
    print "Query Error: ".Dumper $dbq->get_error();
    die;
}

# Convert to JSON and write it to the output file
my $json = encode_json($organizations);
print ($fh $json);
close($fh);

print "Wrote $output_file\n";
