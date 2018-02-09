#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;
use GRNOC::Config;
use GRNOC::DatabaseQuery;
use JSON;
use Data::Dumper;

# This script will pull data out of the Science Registry database and write it to a file as JSON.

# Defaults
# Use same config file as resourcedb (Science Registry)
my $config_file = "/etc/grnoc/netsage/resourcedb/config.xml";
# Name output file with the current timestamp
my $output_file = "/etc/grnoc/netsage/resourcedb/datadump_".time().".json";

# defaults can be overridden on command line (-c and -o)
GetOptions( 'config|c=s' => \$config_file,
            'output|o=s' => \$output_file
          );
#            'logging=s' => \$logging,
#            'help|h|?' => \$help 
#
## did they ask for help?
#usage() if $help;


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

# Get info about resources
my $resources = $dbq->select(
    table => 'ip_block JOIN organization ON ip_block.organization_id = organization.organization_id '.
             'JOIN discipline ON ip_block.discipline_id = discipline.discipline_id '.
             'JOIN role ON ip_block.role_id = role.role_id ',
    fields => [ 'ip_block.ip_block_id',
                'ip_block.name      as resource',
                'ip_block.abbr      as resource_abbr',
                'ip_block.description',
                'ip_block.addr_str  as addresses_str',
                'ip_block.asn',
                'ip_block.latitude',
                'ip_block.longitude',
                'ip_block.country_code',
                'discipline.name        as discipline',
                'discipline.description as discipline_description',
                'role.name          as role',
                'role.description   as role_description',
                'organization.name  as org_name',
                'organization.abbr  as org_abbr',
                'organization.description  as org_description',
                'organization.url       as org_url',
                'organization.latitude  as org_latitude',
                'organization.longitude as org_longitude',
                'organization.country_code  as org_country_code'
               ]
    );

if (!$resources) {
    print "Query Error: ".Dumper $dbq->get_error();
    die;
}

my @data;
foreach my $res (@$resources) {
    # Change addr_str from a comma-separated string to an array
    my @array = split(",",$res->{'addresses_str'});
    $res->{'addresses'} = \@array;
    # Get projects that the resource belongs to and add them as an array of hashes
    $res->{'projects'} = [];
    my $projects = $dbq->select(
        table => 'project JOIN ip_block_project ON ip_block_project.project_id = project.project_id',
        fields => [ 'project.name  as project_name',
                    'project.abbr  as project_abbr',
                    'project.description  as project_description',
                    'project.url   as project_url',
                    'project.owner as project_contact',
                    'project.email as project_email'
                  ],
        where => {'ip_block_project.ip_block_id' => $res->{'ip_block_id'}}
    );
    if (!$projects) {
        print "Query Error: ".Dumper $dbq->get_error();
        die;
    }
    foreach my $proj (@$projects) {
        push(@{$res->{'projects'}}, $proj);
    }
    print Dumper($res); ###
    push(@data, $res);
}

# Convert to JSON and write it to the output file
my $json = encode_json(\@data);
print ($fh $json);
close($fh);

print "Wrote $output_file\n";


