#!/usr/bin/perl
use strict;
use warnings;

use POSIX qw/strftime/;
use Search::Elasticsearch;
use Getopt::Long;
use Data::Dumper;

# This script updates sensor names in ElasticSearch from the time the script is run, going back in time.
# Will replce sensor names as specfied
# RUN MANUALLY   eg,   $ perl fix-past-ES-flows-sensors.pl -u netsage_service -p xxx - es prod > fix-sensors-irnc.out1
# TEST BY UNCOMMENTING THINGS BELOW IN #####'s and EXITING EARLY.

#!!!! SET CORRECT INDEX NAMES HERE !!!!
my $index_names = "om-netsage-sox-*";   
print ("DOING INDICES:  $index_names \n\n");

#!!! NOTE:
# To allow writing to indices, run something like this in the kibana console:
# PUT om-ns-netsage-2019.09*/_settings 
# {
#   "index.blocks.write" : null
#  }

#!!!! SPECIFY OLD AND NEW SENSOR NAMES HERE   AND   IN QUERY BELOW
# What to change the sensor names to        (old   =>   new)
    my $new_sensor_names = {"NEAAR New York sFlow" => "NEAAR NY-London", 
                            "SANReN Netflow"       => "SANReN London to Johannesburg",
                            "rtr.sidco.sox.net"    => "SoX Nashville Sidco sFlow",
                            "rtr.365dc.sox.net"    => "SoX Nashville 365DC sFlow",
                            "rtr.56mar.sox.net"    => "SoX Atlanta Netflow",
                            "SingAREN SOE1 Singapore SFlow" => "SingAREN Singapore 1"};



# Get info to access elasticsearch, from command line
my $username;  # eg, netsage_service
my $pw;
my $esver;

GetOptions( 'username|u=s' => \$username,
            'password|p=s' => \$pw,
            'es=s' => \$esver );
if (!$esver or !$username or !$pw) {
            die("ERROR. On the command line, enter the elasticsearch username and password with -u, -p, \n ".
                   "       and '-es prod' to use production Elasticsearch, '-es dev' to use dev ES\n");
}

# elasticsearch url with username, pw, host
my $es_url;
if ($esver eq 'prod') {
    $es_url = 'https://'.$username.':'.$pw.'@netsage-elk1.grnoc.iu.edu/esproxy2';
    print ("UPDATING * production * NETSAGE ELASTICSEARCH INDICES\n");
} elsif ($esver eq 'dev') {
    $es_url = 'https://'.$username.':'.$pw.'@netsage-elk1.grnoc.iu.edu/esproxy_dev';
    print ("UPDATING * dev * NETSAGE ELASTICSEARCH INDICES\n");
} else {
    die ("ERROR: Use '-es dev' for dev ES, '-es prod' to use production ES\n");
}

# connect to ES
# (for debugging, to see the HTTP requests and responses, add to new:  
#  trace_to => 'Stderr'  or  trace_to => ['File','/path/to/filename'].
#  $es->info - tells ES version.  $es->ping - returns 200 response, otherwise throws an error.)
my $es = Search::Elasticsearch->new( 
        nodes => $es_url, 
        request_timeout => 120 );
if (!$es) {
    die ("Couldn't connect to ElasticSearch\n");
}

# Get indices (gets just names with -h)
my $response = $es->cat->indices (
    index => $index_names.'*',
    h => "index" 
); 
my @indices = split("\n",$response);

my @sorted_indices = reverse sort @indices;

#########
#print Dumper \@sorted_indices; 
#exit;
########

# Loop over indices, going back in time
my $total_docs = 0;
my $total_docs_done = 0;
foreach my $index (@sorted_indices) {

######################
#    # to skip some indices or quit when reaching some index:
#    if ($index =~ /-2021\./) { print " skipping "; next; }
#    if ($index =~ /-2020\./) { print ("QUITTING AT index 2020.08. \n"); last; }
#    if ($index =~ /copy/) { next; }
######################
# print $index. " ";
# next; 
#################

    # bulk_helper for updates of this index - will use to do many updates in one request
    # ####  NOTE: THE CURRENT VERSION OF BULK_HELPER REQUIRES "type" BUT ES VER 7 DOESN'T SUPPORT IT
    # ####  UNTIL A NEW VERSION COMPATIBLE WITH ES 7 COMES OUT, I'VE MADE A LOCAL MOD IN
    # ####  /usr/share/perl5/vendor_perl/Search/Elasticsearch/Client/6_0/Role/API.pm (line 57) TO NOT REQUIRE IT
    my $bulk = $es->bulk_helper(
        index => $index,
        max_count => 1000,  # max no. of actions before flushing (sending request) 
        verbose => 1,
        on_success => sub {
            # called for every action that has a successful response
            $total_docs_done++;
        },
        on_conflict => sub {
            # called if, eg, trying to create a document that already exists
            my ($action,$response,$i_action,$version) = @_;
            print "CONFLICT ERROR DOING UPDATE #$i_action\n";
            print Dumper $action;
        },
        on_error => sub {
            # called for errors other than conflicts. $i_action = index of the action in the request, starts at 0.
            my ($action,$response,$i_action) = @_;
            print "THERE WAS A PROBLEM DOING UPDATE #$i_action in index $index\n";
            print Dumper $action;
            print Dumper $response;
        }
    );

    print "\n\n".strftime('%F %T',localtime).
        " : Docs done = $total_docs_done,  should be = $total_docs.  Starting index = $index, "; 

# !!!! EDIT HERE
    # Get docs 
    #   In the query, use "terms" since we want an exact match and there are >1 possible values 
    #       'bool => { should {'  makes an 'OR'
    # scroll_helper will send requests for batches of 'size' docs, as required.
    my $scroll = $es->scroll_helper(
        index => $index,
        size  => 3000,    # number of docs per batch 
        scroll => '10m',  # >= time to process a batch
        body => { 
            sort => '_doc', # to actually NOT sort
            query => {
                bool => { 
                    should => [
                      {term => { "meta.sensor_id" => "NEAAR New York sFlow" }},
                      {term => { "meta.sensor_id" => "SANReN Netflow" }},
                      {term => { "meta.sensor_id" => "rtr.sidco.sox.net" }},
                      {term => { "meta.sensor_id" => "rtr.365dc.sox.net" }},
                      {term => { "meta.sensor_id" => "rtr.56mar.sox.net" }},
                      {term => { "meta.sensor_id" => "SingAREN SOE1 Singapore SFlow" }}
                    ],
                "minimum_should_match" => 1,
                } 
            } 
        } 
    );

    my $scroll_total = $scroll->total;   # not sure why this is a hash with value and 'relation' => 'eq'!
    my $ndocs = $scroll_total->{'value'};
    print "num docs = $ndocs \n";
    $total_docs += $ndocs;
    STDOUT->autoflush(1);

########
### just print no. of docs to update
#   next; 
#########

    my $n = 0;
    while (my $doc = $scroll->next) {
        $n++;
        if ($n % 5000 == 0) { print "."; STDOUT->autoflush(1); }   # just some .'s to show things are happening

        my $id = $doc->{'_id'};
        my $indx = $doc->{'_index'};
       
##        print "$n. fixing ID = $id   in $indx\n"; ######
########
##      # Don't process, just loop through
##       $total_docs_done++; 
##       next; 
#########

        # the sensor name in this doc
        my $doc_sensor = $doc->{'_source'}->{'meta'}->{'sensor_id'};
    
        # what to update
        my $to_replace;
        my $new_name = $new_sensor_names->{$doc_sensor};
        if (!$new_name) { die(" no new name for $doc_sensor \n"); }

        $to_replace->{'meta'}->{'sensor_id'} = $new_name;

        # TEST THIS:  You can replace a number of fields at once here, if needed, by having more $to_replace values
        # eg, also $to_replace->{'meta'}->{'sensor_group'} = "Group X";

        # Add action to $bulk 
        # The update query will be sent when max_count is reached. (can also call flush to do it manually)
        $bulk->add_action( update => { id => $id,
                                       doc => $to_replace,
                                       doc_as_upsert => "true" }
                         );
        
##########
## for testing, do just 1 or a few per index
#if($n == 10) { print "\n"; last; } 
##########

    } # end doc

    # finish any updates left
    $bulk->flush;

}  # end index

print strftime('%F %T',localtime).  " : Docs done = $total_docs_done,  should be = $total_docs.  \n";


