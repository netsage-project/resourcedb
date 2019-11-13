#!/usr/bin/perl
use strict;
use warnings;

use POSIX qw/strftime/;
use Search::Elasticsearch;   # install perl-Search-Elasticsearch
use Getopt::Long;
use Data::Dumper;

# This script updates flows in ElasticSearch from the time the script is run, going back in time.
# This version will replace specified SCIENCE REGISTRY FIELDS in documents having any specified field value.
# EDIT BELOW and RUN MANUALLY    (with '-es dev' to update es ES, '-es prod' to update production ES)

# Get info to access elasticsearch, from command line
my $username;  # eg, netsage_service
my $pw;
my $es_ver;  

GetOptions( 'username|u=s' => \$username, 
            'password|p=s' => \$pw,
            'es=s' => \$es_ver );
if (!$es_ver or !$username or !$pw) {
            die("ERROR. On the command line, enter the elasticsearch username and password with -u, -p, \n ".
                   "       and '-es prod' to use production Elasticsearch, '-es dev' to use dev ES\n"); 
}

# elasticsearch url with username, pw, host
my $es_url;
if ($es_ver eq 'prod') {
    $es_url = 'https://'.$username.':'.$pw.'@netsage-elk1.grnoc.iu.edu/esproxy2';
    print ("UPDATING * production * NETSAGE ELASTICSEARCH INDICES\n");
} elsif ($es_ver eq 'dev') {
    $es_url = 'https://'.$username.':'.$pw.'@netsage-elk1.grnoc.iu.edu/esproxy_dev';
    print ("UPDATING * dev * NETSAGE ELASTICSEARCH INDICES\n");
} else {
    die ("ERROR: Use '-es dev' for dev ES, '-es prod' to use production ES\n"); 
}

my $index_names = "om-ns-netsage-";   # first part of names

# WHICH DOCS TO FIND AND PROCESS
# (will be an OR, ie, flows that match any of these)
#               examples:
#                    {term => { "meta.src_discipline.keyword" => "Unknown" }},   -- to match keywords (whole text field), numbers, dates 
#                    {terms => { "meta.src_asn" => \@asn_array }},       -- to match any asn in @asn_array
#                    {exists => { "field" => "meta.scireg.src.discipline" }},  -- to match docs where this field exists
my $conditions_array = [
    {term => { "meta.scireg.src.resource.keyword" => "NAOJ - WIDE Project - unknown"}},
    {term => { "meta.scireg.dst.resource.keyword" => "NAOJ - WIDE Project - unknown"}},
    {term => { "meta.scireg.src.resource.keyword" => "NOAJ - WIDE Project - unknown"}},
    {term => { "meta.scireg.dst.resource.keyword" => "NOAJ - WIDE Project - unknown"}}
]; 
print "Will find docs with ".Dumper($conditions_array)."\n";

# WHAT TO CHANGE IN meta.scireg.src and/or meta.scireg.dst. 
# Change $change_field from $old_value to $new_value 
# These are independent! If only 1 old_value matches, only it will be changed.
my @changes_array = (
    { 
      "change_field" => "resource", 
      "old_value" => "NAOJ - WIDE Project - unknown", 
      "new_value" => "NAOJ - unknown" 
    },
    { 
      "change_field" => "resource", 
      "old_value" => "NOAJ - WIDE Project - unknown", 
      "new_value" => "NAOJ - unknown" 
    },
    { 
      "change_field" => "discipline", 
      "old_value" => "Unknown", 
      "new_value" => "MPS.Astronomy" 
    }
);
#---------------------------

foreach my $ch_hash (@changes_array) {
    print "WILL CHANGE meta.scireg.src/dst.".$ch_hash->{"change_field"}." FROM ".$ch_hash->{"old_value"}.
          " TO ".$ch_hash->{"new_value"}." \n";
}
print "\n";

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
# to skip some indices or quit when reaching some index:
#if ($index =~ /2019\.10\./) { print ("SKIPPING $index\n"); next; }
#if ($index =~ /2019\.09\.2[0-8]/) { print ("SKIPPING $index\n"); next; }
#if ($index =~ /2019\.08\./) { print ("QUITTING AT AUG 2019\n"); last; }
########

    # bulk_helper for updates of this index - will use to do many updates in one request
    # !!!!  NOTE: THE CURRENT VERSION OF BULK_HELPER REQUIRES "type" BUT ES VER 7 DOESN'T SUPPORT IT
    # !!!!  UNTIL A NEW VERSION COMPATIBLE WITH ES 7 COMES OUT, I'VE MADE A LOCAL MOD IN 
    # !!!!  /usr/share/perl5/vendor_perl/Search/Elasticsearch/Client/6_0/Role/API.pm (line 57) TO NOT REQUIRE IT
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
            print "   ".$response->{"error"}->{"reason"}."\n";
            if ($response->{"error"}->{"type"} eq "cluster_block_exception") {
                print "FORBIDDEN error - quitting\n";
                exit; ###### how do you just skip to next index???
            }
        }
    );

    print "\n\n".strftime('%F %T',localtime).
        " : Docs done = $total_docs_done,  should be = $total_docs.  Starting index = $index, "; 

    # Do query to get scireg docs in this index
    # Behind the scenes, scroll_helper will send requests for batches of 'size' docs, as required.
    #   In the query, "exists" will be true for empty strings too ?!?!
    #   'bool => { should {'  makes an 'OR'
    #   size = number of docs per batch my $query = {
    #   scroll is >= time to process a batch
    #   sort = _doc to actually NOT sort
    my $scroll = $es->scroll_helper( {
        index => $index,
        size  => 3000,    
        scroll => "10m",  
        body => { 
            sort => "_doc", 
            query => {
                bool => { should =>  $conditions_array }
            } 
        } 
    } );

    my $scroll_total = $scroll->total;   # not sure why this is a hash with value and 'relation' => 'eq'!
    my $ndocs = $scroll_total->{'value'};
    print "Num docs matched = $ndocs \n";
    $total_docs += $ndocs;
    STDOUT->autoflush(1); 

    my $n = 0;
    # Loop over documents found by scroll query
    while (my $doc = $scroll->next) {
        $n++;
        if ($n % 1000 == 0) { print "."; STDOUT->autoflush(1); } # just some .'s to show things are happening

        my $id = $doc->{'_id'};
        my $data = $doc->{'_source'};
        my $scireg_src = $data->{'meta'}->{'scireg'}->{'src'};
        my $scireg_dst = $data->{'meta'}->{'scireg'}->{'dst'};
 

{ # turn off uninitalized variable warnings in this {}. 
  no warnings 'uninitialized'; 
      ###print "$n. fixing ID = $id   "; ######
      ###print " $src_discipline -> $dst_discipline.   "; #######

########
#       print "BEFORE: ".Dumper $data;
#       exit;
#
#      # Don't process, just loop through
#       $total_docs_done++; ##### goes with next 
#       next; 
########

        my $updates;
        foreach my $ch_hash (@changes_array) {
            my $change_field = $ch_hash->{"change_field"};
            my $old_value = $ch_hash->{"old_value"};
            my $new_value = $ch_hash->{"new_value"};
            # original values - either could be undef
            my $src_orig_val = $scireg_src->{$change_field};
            my $dst_orig_val = $scireg_dst->{$change_field};
            # add to $updates if orig value of $change_field exists and is what we want to change
            if ($src_orig_val && $src_orig_val eq $old_value) {
                ###print $id.' Will set {"meta"}->{"scireg"}->{"src"}->{'.$change_field.'} = '.$new_value."\n";
                $updates->{"meta"}->{"scireg"}->{"src"}->{$change_field} = $new_value;
            }
            if ($dst_orig_val && $dst_orig_val eq $old_value) {
                ###print $id.' Will set {"meta"}->{"scireg"}->{"dst"}->{'.$change_field.'} = '.$new_value."\n";
                $updates->{"meta"}->{"scireg"}->{"dst"}->{$change_field} = $new_value;
            }
        }

        # Add action to $bulk if there's anything to update (updates haven't been done already!). 
        # The update query will be sent when max_count is reached. (can also call flush to do it manually)
        if ($updates) {
            $bulk->add_action( update => { id => $id,
                                           doc => $updates,
                                           doc_as_upsert => "true" }
                             );
            ###print "\n";
        } else { 
            print "    Skipping $id. Neither src or dst values existed and also matched required old_values. \n"; 
            $total_docs = $total_docs - 1;  
        }
} # end ignoring unitialized warnings

##########
# for testing, do just a few per index
###if($n == 10) { last; } 
#########

    } # end doc

    # finish anything updates left
    $bulk->flush;

}  # end index

print strftime('%F %T',localtime).  " : FINISHED.  Docs done = $total_docs_done,  should be = $total_docs.  \n";


