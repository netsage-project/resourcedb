#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;
use GRNOC::Config;
use GRNOC::DatabaseQuery;
use NetAddr::IP;
use List::MoreUtils qw(uniq);
use JSON;
use Data::Dumper;
use Encode;

# This script will pull data out of the Science Registry database and write it to a .json file (used by resourcedb-make-mmdb.pl)
# AND to a .yaml file (for use with logstash translate filter)

# Defaults
my $help;
# Use same config file as resourcedb (Science Registry)
my $config_file = "/etc/grnoc/netsage/resourcedb/config.xml";
# Name output file with the current timestamp
my $output_file = "/etc/grnoc/netsage/resourcedb/datadump_".time().".json";

#-----------------------------
sub usage() {
  print "  USAGE: perl resourcedb-export.pl [-c <config file>] [-o <output file>] [-h] 
  Without parameters, the defaults are 
    config_file = /etc/grnoc/netsage/resourcedb/config.xml 
    output_file = /etc/grnoc/netsage/resourcedb/datadump_<timestamp>.yaml (.json file will have same name. Must run as sudo) \n";
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

# Try to open output files
#json file
$output_file =~ s/yaml$/json/; # just in case
my $fh;
if (! open($fh, '>', $output_file) ) {
    print "Could not open json output file $output_file\n";
    die;
}
#yaml file
my $output_file_yaml = $output_file; 
$output_file_yaml =~ s/json$/yaml/;  
my $fh_yaml;
if (! open($fh_yaml, '>', $output_file_yaml) ) {
    print "Could not open yaml output file $output_file_yaml\n";
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
    die ("Error connecting to mysql.");
}
# tells dbq to expect/use unicode which is what's in the db 
$dbq->{'dbh'}->do("SET NAMES utf8mb4;");

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

my @all_resources;

foreach my $res (@$resources) {
    # Get projects that the resource belongs to and add them to the resource as an array of hashes
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
    ### print Dumper($res); ###

    # For json file
    push(@all_resources, $res);

    # For yaml file
    # strip /xx's from addresses and expand any ip blocks 
    my @ip_array = split(",", $res->{'addresses_str'});
    my @final_ips;
    foreach my $ip (@ip_array) {
        my $ipblock = new NetAddr::IP($ip);
        if (! $ipblock) {
            print "ERROR: invalid IP: $ip \n";
            next;
        }
        my ($base, $slash) = split('/',$ip);
        if ($slash eq "32" or $slash eq "128") {
            # single address
            push(@final_ips, $ipblock->addr());
        } elsif ($slash < 28 or ($slash >32 and $slash < 124)) {
            # if there are too many ip's in the block, write a regular expression that matches ip's in the block
            # NetAddr::IP -> re() - Returns a Perl regular expression that will match an IP address within the given subnet. 
            # Defaults to ipV4 notation. Will return an ipV6 regex if the address in not in ipV4 space.
            push(@final_ips, $ipblock->re());
        } else {
            # list ips in the CIDR block; don't skip the first or last (possibly network address or broadcast address)
            for (my $address = $ipblock->network(); $address <= $ipblock->broadcast(); $address ++) {
                push(@final_ips, $address->addr());
                # adding 1 wraps around after the broadcast address, so need to quit to avoid infinite loop for 1 or 2 addresses.
                last if ($address == $ipblock->broadcast);
            }
        }
    }
    # remove dups and join array elements with |
    @final_ips = uniq(@final_ips); 
    my $ip_regex = join( "|", @final_ips );

    # convert resource info into a json string, then convert that (which is utf8 from the db) to perl characters 
    # with internal utf-8 tags, using decode. 
    my $res_json = decode( 'utf-8', encode_json($res) );
    # html-encode simple single quotes since we'll use them to start and end the string that holds the json and escaping them 
    # doesn't work ("s are already escaped)
    $res_json =~ s/'/&apos;/g;

    # write  ip:'data'  line to file (perl knows how to write utf8 chars)
    print $fh_yaml  "'".$ip_regex."' : '".$res_json."'\n" ;
}
close($fh_yaml);

# Add an array of IPs in addition to the addresses string (for the old pipeline scireg tagger)
foreach my $resrc (@all_resources) {
        my @array = split(",", $resrc->{'addresses_str'});
        $resrc->{'addresses'} = \@array;
}

# Write the .json output file (writes array of JSON objects)
my $json = decode( 'utf-8', encode_json(\@all_resources) );
print  $fh $json ;
close($fh);

print "Wrote $output_file and $output_file_yaml \n";

