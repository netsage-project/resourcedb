#!/usr/bin/perl
use strict;
use warnings;

use POSIX qw/strftime/;
use Search::Elasticsearch;
use Data::Dumper;

# This script updates flows in ElasticSearch from the time the script is run, going back in time.
# This version will remove science registry info for src's or dst's that have one of the listed ASNs 
# and replace it with general AARNet info. 
# RUN MANUALLY   if ASN list changes or edit and run to redact other sci reg data.

###### move to config file #####
my $username = "netsage_service";
my $pw = "mow73:trucks";

# elasticsearch url with username, pw, host
my $es_url = 'https://'.$username.':'.$pw.'@netsage-elk1.grnoc.iu.edu/esproxy2';

my $index_names = "om-ns-netsage-";   # first part of names
#########
    # for testing
#   my $index_names = "om-ns-test-netsage-";   
#   my $es_url = 'localhost:9200';  ######
#   my $index_names = "test";  #######
#########

# Australian ASNs:
# 7/11/19 - ASNs from "/usr/bin/whois AS7575:AS-RNO" and "/usr/bin/whois AS7575:AS-EDGE"
# (state based networks connected to AARNet and customers on AARNet using public AS numbers):
my @asn_array = ("AS4738", "AS7569", "AS7571", "AS7570", "AS7572", "AS7573", "AS7574",    "AS1851", "AS4822", "AS6262", "AS7475", "AS7476", "AS7573", "AS7575", "AS7637", "AS7645", "AS9348", "AS4608", "AS9383", "AS9517", "AS10106", "AS10148", "AS17807", "AS20144", "AS22556", "AS23654", "AS23719", "AS23859", "AS23935", "AS24032", "AS24101", "AS24313", "AS24390", "AS24431", "AS24433", "AS24434", "AS24436", "AS24437", "AS24490", "AS24510", "AS37978", "AS38076", "AS38083", "AS38280", "AS38307", "AS38474", "AS38568", "AS38568", "AS38795", "AS38858", "AS45128", "AS45158", "AS45213", "AS45797", "AS45962", "AS55354", "AS55363", "AS55491", "AS55773", "AS55813", "AS56065", "AS56132", "AS56210", "AS56219", "AS56303", "AS58422", "AS58528", "AS58582", "AS58584", "AS58611", "AS58686", "AS58698", "AS58877", "AS59206", "AS64090", "AS131294", "AS137188", "AS132129", "AS132158", "AS132345", "AS132693", "AS132728", "AS132868", "AS133019", "AS134096", "AS134111", "AS134115", "AS134197", "AS134197", "AS134700", "AS134748", "AS137965", "AS135350", "AS135520", "AS135892", "AS135893", "AS136013", "AS136016", "AS136135", "AS136247", "AS136549", "AS136753", "AS136770", "AS136912", "AS136921", "AS136621", "AS137073", "AS137400", "AS138017", "AS137837", "AS137529", "AS138201", "AS138390", "AS138447", "AS138468", "AS138537",    "AS137429");

# get rid of "AS"s and convert to a hash
@asn_array = map { s!AS!!; $_ } @asn_array;
@asn_array = map { int($_) }    @asn_array;  # array has integers
my %asn_hash  = map { $_ => 1 } @asn_array;  # keys get converted to strings

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

# Loop over indices, going from most recent into the past
my @sorted_indices = reverse sort @indices;

my $total_docs = 0;
my $total_docs_done = 0;
foreach my $index (@sorted_indices) {

    # Get aussie docs (flows with endpoints having Australian ASNs in this index; they may not be IN Australia).
    #   If a doc is already privatized, the relevant meta.src_asn will be 0, so those won't come up.
    #   In the query, use "terms" since we want an exact match and there are >1 possible values (asn's)
    #       'bool => { should {'  makes an 'OR'
    # scroll_helper will send requests for batches of 'size' docs, as required.
    my $scroll = $es->scroll_helper(
        index => $index,
        size  => 3000,    # number of docs per batch 
        scroll => '10m',  # >= time to process a batch
        body => { 
            sort => '_doc', # to actually NOT sort
            query => {
                bool => { should => [
                    {terms => { "meta.src_asn" => \@asn_array }},
                    {terms => { "meta.dst_asn" => \@asn_array }}  
                ] } 
            } 
        } 
    );

    my $ndocs = $scroll->total;
    print "\n".strftime('%F %T',localtime).
        " : Docs done = $total_docs_done,  should be = $total_docs.  Starting index = $index,  num aussie docs = $ndocs, \n";
    STDOUT->autoflush(1); 
    $total_docs += $ndocs;

    my $n = 0;
    while (my $doc = $scroll->next) {
        $n++;
        if ($n % 1000 == 0) { print "."; STDOUT->autoflush(1); }

        my $id = $doc->{'_id'};
        my $data = $doc->{'_source'};
        my $src_asn = $data->{'meta'}->{'src_asn'};
        my $dst_asn = $data->{'meta'}->{'dst_asn'};
        my $src_ip = $data->{'meta'}->{'src_ip'};
        my $dst_ip = $data->{'meta'}->{'dst_ip'};
      ##print "fixing ID = $id   \n"; ######
      ##print "src - dst: $src_asn - $dst_asn , $src_ip - $dst_ip \n"; #######
    
        # Is src or dst the "aussie" end?
        my $aussie_end = "src";
        $aussie_end = "dst"  if ( $asn_hash{$dst_asn} );

        {
        no warnings 'uninitialized'; # turn off uninitalized variable warnings in this {}. 
        my $check = $asn_hash{$src_asn} + $asn_hash{$dst_asn};
        if ($check == 0) 
            { die ("ERROR: How did a doc with neither src nor dst ASN in the list get into the results !?  _id = $id\n"); }
        elsif ($check == 2)
            { print ("WARNING: There is a flow with both src and dst ASNs in the list !?  index = $index  _id = $id \n") }
        }
########
#       print "BEFORE: ".Dumper $data;
#       exit;
#
#      # Don't process, just loop through
#       $total_docs_done++; ##### goes with next 
#       next; 
########

        # ADD PRIVATE FIELDS
            # { "[meta][src_organization]" => "[PRIVATE][src_organization]" }
            # { "[meta][src_asn" => "[PRIVATE][src_asn]" }
            # { "[meta][src_ip]" => "[PRIVATE][src_ip]" }
            # { "[meta][scireg][src][org_name]" => "[PRIVATE][scireg_src_org_name]" }
            # { "[meta][scireg][src][resource]" => "[PRIVATE][scireg_src_resource]" }
        my $private_to_add = { $aussie_end.'_organization'       => $data->{'meta'}->{$aussie_end.'_organization'},
                               $aussie_end.'_asn'                => $data->{'meta'}->{$aussie_end.'_asn'},
                               $aussie_end.'_ip'                 => $data->{'meta'}->{$aussie_end.'_ip'},
                               'scireg_'.$aussie_end.'_org_name' => $data->{'meta'}->{'scireg'}->{$aussie_end}->{'org_name'},
                               'scireg_'.$aussie_end.'_resource' => $data->{'meta'}->{'scireg'}->{$aussie_end}->{'resource'}
                              };

        # FIELDS TO BE REDACTED (or added if there was an invalid IP or no geoip results). 
            # { "[meta][src_asn]" => 0 }
            # { "[meta][src_ip]" => "xx.xx.xx.xx" }
            # { "[meta][src_organization]" => "Australian Academic and Research Network (AARNet)" }
            # { "[meta][src_latitude]" => -25 }
            # { "[meta][src_longitude]" => 135 }
            # { "[meta][src_location][lat]" => -25 }
            # { "[meta][src_location][lon]" => 135 }
        my  $to_replace = {
                $aussie_end."_asn"          => 0,
                $aussie_end."_ip"           => "xx.xx.xx.xx",
                $aussie_end."_organization" => "Australian Academic and Research Network (AARNet)",
                $aussie_end."_latitude"     => -25,
                $aussie_end."_longitude"    => -135,
                $aussie_end."_location" => { "lat" => -25, "lon" => -135 },
            };    

        # IF SCIREG DATA, ADD THESE TO FIELDS TO BE REDACTED
            # { "[meta][scireg][src][org_name]" => "Australian Academic and Research Network (AARNet)" }
            # { "[meta][scireg][src][org_abbr]" => "AARNet.au" }
            # { "[meta][scireg][src][org_latitude]" => "-33.7985" }
            # { "[meta][scireg][src][org_longitude]" => "151.1448" }
            # { "[meta][scireg][src][org_url]" => "https://wwww.aarnet.edu.au" }
            # { "[meta][scireg][src][org_description]" => "AARNet provides high speed network and collaboration services for Australian research and education organizations" }
            # { "[meta][scireg][src][resource]" => "AARNet member" }
            # { "[meta][scireg][src][resource_abbr]" => "AARNet" }
            # { "[meta][scireg][src][description]" => "Australian host" }
            # { "[meta][scireg][src][latitude]" => "-25" }
            # { "[meta][scireg][src][longitude]" => "135" }
            # { "[meta][scireg][src][asn]" => "0" }
            # set "[meta][scireg][src][projects]" to []
        my $scireg_exists = 0;
        $scireg_exists = 1  if ( $data->{'meta'}->{'scireg'}->{$aussie_end}->{'org_name'} ); 

        if ($scireg_exists) {
        # # # #  Keeping lats, longs, asns text fields for now
                my $scireg_to_replace = {
                    org_name      => 'Australian Academic and Research Network (AARNet)', 
                    org_abbr      => 'AARNET.au',
                    org_latitude  => '-33.7985',
                    org_longitdue => '151.1448',
                    org_url       => 'https://wwww.aarnet.edu.au',
                    org_description => 'AARNet provides high speed network and collaboration services for Australian research and education organizations',
                    resource      => 'AARNET member',
                    resource_abbr => 'AARNET',
                    description   => 'Australian host',
                    latitude      => '25',
                    longitude     => '35',
                    asn           => '0',
                    projects      => []
                }; 

                $to_replace->{"scireg"}->{$aussie_end} = $scireg_to_replace;
        }

        # REDACT    
        my $to_do =  { "PRIVATE" => $private_to_add,
                          "meta"    => $to_replace };
        eval {
            $response = $es->update(
                index => $index,
                type => 'doc',
                id => $id,
                body => { doc => { PRIVATE => $private_to_add,
                                   meta => $to_replace } }
            );
            $total_docs_done++;
            1;  
        } 
        or do {
            print "THERE WAS A PROBLEM UDATING _id $id\n";
            print "  ".$@."\n";
        };
 
###########
#if ($foo and $scireg_exists) {
#        # check edited doc
#        print "BEFORE: ". Dumper($data);
#        $response = $es->get(
#            index => $index,
#            type => 'doc',
#            id => $id
#        );
#        print "AFTER: ".Dumper ($response); 
#        exit;
#}
###########

    } # end doc

}  # end index

print strftime('%F %T',localtime).  " : Docs done = $total_docs_done,  should be = $total_docs.  \n";


