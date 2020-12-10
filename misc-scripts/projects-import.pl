#!/usr/bin/perl

use strict;
use warnings;

use Getopt::Long;
use GRNOC::Config;
use GRNOC::DatabaseQuery;
use Text::CSV;   # perl-Text-CSV
use Data::Dumper;

# This script will pull projects data out of a TSV file and put it into the Science Registry database.
# Col. 1 = resource id,  col. 2 = project name
# RUN MANUALLY

# Use same config file as resourcedb (Science Registry)
my $config_file = "/etc/grnoc/netsage/resourcedb/config.xml";
my $input_file = "/home/lensman/jens_projects_to_import.tsv";

my $help;
#-----------------------------
sub usage() {
  print "  USAGE: perl projects-import.pl [-c <config file>] [-i <input file>] [-h] 
  Without parameters, the defaults are 
    config_file = /etc/grnoc/netsage/resourcedb/config.xml 
    input_file = /home/lensman/jens_projects_to_import.tsv \n";
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

# don't think we need this for tsv
## csv parser (needed in case some fields have quotes and commas in them.
##my $csv = Text::CSV->new({ sep_char => ',' });

my @fields;
my $input_id;
my $input_proj;

my $headers = <$fh>;
while (my $line = <$fh>) {
    chomp $line;
    ##if ($csv->parse($line)) {
    ##    @fields = $csv->fields();
    @fields = split("\t", $line);
        $input_id = chomp($fields[0]);
        $input_proj = $fields[1];
    ##} else {
    ##    print ("Line could not be parsed: $line\n");
    ##    next;
    ##}
 
    # see if proj name is already in the db
    my $found = $dbq->select(
        table => 'project',
        fields => [ 'name' ],
        where => {'name' => $input_proj}
    );
    
    if (!$found) {
        print "Select query Error: ".Dumper $dbq->get_error();
        die;
    }
    if (@$found > 0) {
        print " already in db: $input_proj \n";
        next;
    } else {
        print " not in db: $input_proj \n";
        next;
        # insert into db
        my $proj_id = $dbq->insert(
            table => 'project',
            fields => { 'name' => $input_proj }
        );
        
        if (!$proj_id) {
            print "Insert query error for -$input_proj-: ".Dumper $dbq->get_error();
            die;
        }
    }

#   # insert event
#    my $event_id = $dbq->insert(
#        table => 'event',
#        fields => { 'message' => 'An org import script added this organization.',
#                    'organization_id' => $org_id }
#    );
#    if (!$event_id) {
#        print "Insert event query Error: ".Dumper $dbq->get_error();
#        die;
#    }

}

close($fh);

print "DONE\n";
