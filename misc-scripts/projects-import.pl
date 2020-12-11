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
my $script_user_id = 4;  # the "Project Import Script" user

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
my $input_res_id;
my $input_proj;

my $headers = <$fh>;
while (my $line = <$fh>) {
    chomp $line;
    ##if ($csv->parse($line)) {
    ##    @fields = $csv->fields();
    @fields = split("\t", $line);
        $input_res_id = $fields[0] + 0;  # make sure it's a number
        $input_proj = $fields[1];
        $input_proj =~ s/^\s+|\s+$//g; # replace any leading or trailing spaces with nothing
    ##} else {
    ##    print ("Line could not be parsed: $line\n");
    ##    next;
    ##}
 
    # see if proj name is already in the db
    my $proj_exists = 0;
    my $proj_id;
    my $found = $dbq->select(
        table => 'project',
        fields => [ 'name', 'project_id' ],
        where => {'name' => $input_proj}
    );
    
    if (!$found) {
        print "Select query Error: ".Dumper $dbq->get_error();
        die;
    }
    if (@$found > 0) {
        $proj_exists = 1;
        $proj_id = $found->[0]->{'project_id'};
        print " already in db: project ".$proj_id.": ".$input_proj." \n";
    } else {
        print " not in db: project ".$input_proj." \n";

        # insert project into db
        $proj_id = $dbq->insert(
            table => 'project',
            fields => { 'name' => $input_proj }
        );
        if (!$proj_id) {
            print " Insert query error for -".$input_proj."-: ".Dumper $dbq->get_error();
            die;
        } else {
            print "   Inserted project >".$input_proj."< with id ".$proj_id." \n";
            $proj_exists = 1;

           # insert event for project (will record current timestamp)
            my $event_id = $dbq->insert(
                table => 'event',
                fields => { user => $script_user_id,
                            message => "project-import script added '".$input_proj."'",
                            project_id => $proj_id
                          }
            );
            if (!$event_id) {
                die "Insert event query error: ".Dumper $dbq->get_error();
            } else {
                print "   Added event\n";
            }
        }
     }

     # add project to resource. 
     if ($proj_exists) {
            # first make sure resource exists. If not, just print a msg and go to next line.
            my $resfound = $dbq->select(
                table => 'ip_block',
                fields => [ 'name' ],
                where => {'ip_block_id' => $input_res_id}
            );
            if (!$resfound) {
                print "Select ip_block query Error: ".Dumper($dbq->get_error());
                die ("error");
            }
            my $n = @$resfound + 0;
            if ($n == 0) {
                print " **** ip_block_id $input_res_id was not found \n"; 
                next;
            }
            # also see if we already added project_id to resource. If yes, go to next line.
            my $rp_found = $dbq->select(
                table => 'ip_block_project',
                fields => [ 'id' ],
                where => {'ip_block_id' => $input_res_id,
                          'project_id' => $proj_id }
            );
            if (!$rp_found) {
                print "Select ip_block_project query Error: ".Dumper($dbq->get_error());
                die ("error");
            }
            $n = @$rp_found + 0;
            if ($n > 0) {
                print "   project $proj_id already added to resource $input_res_id \n"; 
                next;
            }


            # add project_id to resource 
            my $result = $dbq->insert(
                table => 'ip_block_project',
                fields => { project_id => $proj_id ,
                           ip_block_id => $input_res_id }
            );
            if (! $result) {
                die "Update ip_block_project query error: ".Dumper($dbq->get_error());
            } else {
                print "   Added project $proj_id to resource $input_res_id\n";
            }

           # insert event for resource (will record current timestamp) (user can be null, but let's keep it for now)
            my $event_id = $dbq->insert(
                table => 'event',
                fields => { user => $script_user_id,
                            message => "project-import script added project '".$input_proj."'",
                            ip_block_id => $input_res_id
                          }
            );
            if (!$event_id) {
                die "Insert event query error: ".Dumper $dbq->get_error();
            } else {
                print "   Added event\n";
            }

        } else {
            print "Proj doesn't exist\n";
        }
    }


close($fh);

print "DONE\n";
