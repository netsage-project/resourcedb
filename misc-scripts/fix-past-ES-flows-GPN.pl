#!/usr/bin/perl
use strict;
use warnings;

use POSIX qw/strftime/;
use Search::Elasticsearch;
use Getopt::Long;
use Data::Dumper;

# This script updates flows in ElasticSearch FOR GPN from the time the script is run, going back in time.
# Will replce sensor "netsage.gpn.onenet.net" with "gpn-kc", and flow_type = "netflow" with "sflow".
# RUN MANUALLY   

# DIDN'T ACTUALLY USE THIS, BUT I THINK IT WOULD WORK




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

########## my $index_names = "om-ns-netsage-";   # first part of names
my $index_names = "om-ns-gpn-";   # first part of names
print "indices : $index_names \n";

#########
    # for localhost testing
#   my $index_names = "om-ns-test-netsage-";   
#   my $es_url = 'localhost:9200';  ######
#   my $index_names = "test";  #######
#########

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
    h => "index" ); 
my @indices = split("\n",$response);

# some index names start with "shrink-", some don't! There are aliases for the ones with shrink,
# we need to use those to sort right.
my @renamed_indices;
foreach my $index (@indices) {
    $index =~ s/shrink-//;
   push(@renamed_indices, $index);
}
my @sorted_indices = reverse sort @renamed_indices;
###print Dumper \@sorted_indices; exit;

my $total_docs = 0;
my $total_docs_done = 0;
foreach my $index (@sorted_indices) {

######################
#   print $index."\n";
#    # to skip some indices or quit when reaching some index:
#    if ($index =~ /2020\.08\./) { print ("QUITTING AT index 2020.08. \n"); last; }
#    if ($index =~ /copy/) { next; }
######################

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

    # Get docs 
    #   In the query, use "terms" since we want an exact match and there are >1 possible values (asn's)
    #       'bool => { should {'  makes an 'OR'
    # scroll_helper will send requests for batches of 'size' docs, as required.
    my $scroll = $es->scroll_helper(
        index => $index,
        size  => 1000,    # number of docs per batch 
        scroll => '10m',  # >= time to process a batch
        body => { 
            sort => '_doc', # to actually NOT sort
            query => {
                "term" => { "meta.sensor_id.keyword" => "netsage.gpn.onenet.net" }
            }
        }
    );
  #              bool => { should => [
  #                  {terms => { "meta.sensor_id.keyword" => "netsage.gpn.onenet.net" }},
  #              ] } 
  #          } 
  #      } 
  #  );

    my $scroll_total = $scroll->total;   # not sure why this is a hash with value and 'relation' => 'eq'!
    my $ndocs = $scroll_total->{'value'};
    $total_docs += $ndocs;
    print "\n".strftime('%F %T',localtime).
        " : Docs done = $total_docs_done,  should be = $total_docs.  Starting index = $index,  num docs = $ndocs, \n";
    STDOUT->autoflush(1); 

    my $n = 0;
DOCLOOP:  while (my $doc = $scroll->next) {
        $n++;
        if ($n % 1000 == 0) { print "."; STDOUT->autoflush(1); }   

        my $id = $doc->{'_id'};
        my  $to_replace = {
                "meta.sensor_id"          => "gpn-kc",
                "meta.flow_type"          => "sflow"
            };    

        # Add action to $bulk if there's anything to update (updates haven't been done already!).
        # The update query will be sent when max_count is reached. (can also call flush to do it manually)
        my $to_do =  { "meta"    => $to_replace };

#        $bulk->add_action( update => { id => $id,
#                                       doc => $to_do,
#                                       doc_as_upsert => "true" }
#                         );
        
    } # end doc

    # finish any updates left
    $bulk->flush;

}  # end index

print strftime('%F %T',localtime).  " : Docs done = $total_docs_done,  should be = $total_docs.  \n";


