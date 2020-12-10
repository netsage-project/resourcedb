#!/usr/bin/perl
use strict;
use warnings;

use POSIX qw/strftime/;
use Search::Elasticsearch;   # install perl-Search-Elasticsearch
use Getopt::Long;
use Data::Dumper;

# This script updates flows in ElasticSearch from the time the script is run, going back in time.
# This version will remove unneeded fields
# RUN MANUALLY    (with '-es dev' to update dev ES, '-es prod' to update production ES)

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

my $index_names = "om-ns-netsage-";   # first part of names

# connect to ES
# (for debugging, to see the HTTP requests and responses, add to new:  
#  trace_to => 'Stderr'  or  trace_to => ['File','/path/to/filename'].
#  $es->info - tells ES version.  $es->ping - returns 200 response, otherwise throws an error.)
my $es = Search::Elasticsearch->new( 
        nodes => $es_url, 
        request_timeout => 120
    );
if (!$es) {
    die ("Couldn't connect to ElasticSearch\n");
    }

# Get indices (gets just names with -h)
my $response = $es->cat->indices (
    index => $index_names.'*',
    h => "index"
); 
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

# Loop over indices, going from most recent into the past
my $total_docs = 0;
my $total_docs_done = 0;
foreach my $index (@sorted_indices) {

########
#if ($index =~ /2019\.10\./) { print ("SKIPPING $index\n"); next; }
#if ($index =~ /2019\.09\.1[0-9]-.*/) { print ("SKIPPING $index\n"); next; }
#if ($index =~ /2019\.09\.2[0-9]-.*/) { print ("SKIPPING $index\n"); next; }
#if ($index =~ /2019\.09\.30-.*/) { print ("SKIPPING $index\n"); next; }
if ($index =~ /2020\.01\./) { print ("QUITTING AT Jan 2020\n"); last; }
########

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

    # Do query to get docs in this index that haven't been processed yet 
    #   'bool => { should {'  makes an 'OR'
    # Behind the scenes, scroll_helper will send requests for batches of 'size' docs, as required.
    my $scroll = $es->scroll_helper(
        index => $index,
        size  => 3000,    # number of docs per batch 
        scroll => '10m',  # >= time to process a batch
        body => { 
            sort => '_doc', # to actually NOT sort
            query => {
                bool => { should => [
                    {exists => { "field" => "meta.src_ifindex" }},
                    {exists => { "field" => "meta.dst_ifindex" }},
                    {exists => { "field" => "meta.src_continent_code" }},
                    {exists => { "field" => "meta.dst_continent_code" }},
                ] } 
            } 
        } 
    );

    my $scroll_total = $scroll->total;   # not sure why this is a hash with value and 'relation' => 'eq'!
    my $ndocs = $scroll_total->{'value'};
    print "num docs = $ndocs \n";
    $total_docs += $ndocs;
    STDOUT->autoflush(1); 

    my $n = 0;
    # Loop over documents found
    while (my $doc = $scroll->next) {
        $n++;
        if ($n % 5000 == 0) { print "."; STDOUT->autoflush(1); } # just some .'s to show things are happening

        my $id = $doc->{'_id'};
        my $indx = $doc->{'_index'};

#      print "$n. fixing ID = $id   in $indx\n"; ######

########
#       print "BEFORE: ".Dumper $data;
#       exit;
#
#      # Don't process, just loop through
#       $total_docs_done++; ##### goes with next 
#       next; 
########

    # Add action to $bulk if there's anything to update (updates haven't been done already!). 
    # The update query will be sent when max_count is reached. (can also call flush to do it manually)
    $bulk->add_action( update => { id => $id,
                                   script => '
                                      ctx._source.remove("start_timestamp");
                                      ctx._source.remove("end_timestamp");
                                      ctx._source.remove("interval");
                                      ctx._source.remove("flow_num");          
                                      ctx._source.remove("no_previous");
                                      ctx._source.remove("stitching_finished");

                                      ctx._source.meta.remove("src_ifindex");
                                      ctx._source.meta.remove("dst_ifindex");
                                      ctx._source.meta.remove("src_continent_code");
                                      ctx._source.meta.remove("dst_continent_code");
                                      ctx._source.meta.remove("src_country_code");
                                      ctx._source.meta.remove("dst_country_code");
                                      ctx._source.meta.remove("src_city");
                                      ctx._source.meta.remove("dst_city");
                                      if ( ctx._source.meta.containsKey("src_location") ) {
					ctx._source.meta.remove("src_latitude");
                                        ctx._source.meta.remove("src_longitude");
				      }
                                      if ( ctx._source.meta.containsKey("dst_location") ) {
					ctx._source.meta.remove("dst_latitude"); 
                                        ctx._source.meta.remove("dst_longitude");
				      }

                                      ctx._source.values.remove("src_asn");
                                      ctx._source.values.remove("dst_asn");
                                
				      if ( ctx._source.meta.containsKey("scireg") && ctx._source.meta.scireg.containsKey("src") && ctx._source.meta.scireg.src != null ) {
                                        ctx._source.meta.scireg.src.remove("org_description");
                                        ctx._source.meta.scireg.src.remove("org_url");
                                        ctx._source.meta.scireg.src.remove("org_country_code");
                                        ctx._source.meta.scireg.src.remove("org_latitude");
                                        ctx._source.meta.scireg.src.remove("org_longitude");
                                        ctx._source.meta.scireg.src.remove("asn");
                                        ctx._source.meta.scireg.src.remove("description");
                                        ctx._source.meta.scireg.src.remove("discipline_description");
                                        ctx._source.meta.scireg.src.remove("role_description");
                                        ctx._source.meta.scireg.src.remove("country_code");
  				      }
				      if ( ctx._source.meta.containsKey("scireg") && ctx._source.meta.scireg.containsKey("dst") && ctx._source.meta.scireg.dst != null ) {
                                        ctx._source.meta.scireg.dst.remove("org_description");
                                        ctx._source.meta.scireg.dst.remove("org_url");
                                        ctx._source.meta.scireg.dst.remove("org_country_code");
                                        ctx._source.meta.scireg.dst.remove("org_latitude");
                                        ctx._source.meta.scireg.dst.remove("org_longitude");
                                        ctx._source.meta.scireg.dst.remove("asn");
                                        ctx._source.meta.scireg.dst.remove("description");
                                        ctx._source.meta.scireg.dst.remove("discipline_description");
                                        ctx._source.meta.scireg.dst.remove("role_description");
                                        ctx._source.meta.scireg.dst.remove("country_code");
  				      }
				   '
				 }
                     );

##########
# for testing, do just a few per index
#if($n == 1) { print "\n"; last; } 
#########

    } # end doc

    # finish anything updates left
    $bulk->flush;

}  # end index

print strftime('%F %T',localtime).  " : Docs done = $total_docs_done,  should be = $total_docs.  \n";


