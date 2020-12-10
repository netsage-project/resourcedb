#!/usr/bin/perl
use strict;
use warnings;

use POSIX qw/strftime/;
use Search::Elasticsearch;
use Getopt::Long;
use Data::Dumper;

# This script updates flows in ElasticSearch from the time the script is run, going back in time.
# This version will remove geoip and science registry info for src's or dst's that have one of the listed ASNs 
# and replace it with general AARNet info. 
# RUN MANUALLY   

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
my $index_names = "om-ns-netsage-";   # first part of names
print "indices : $index_names \n";

#########
    # for localhost testing
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
    if ($index =~ /2020\.03\./) { print ("QUITTING AT index 2020.03. \n"); last; }
#    if ($index =~ /copy/) { next; }
######################

    # bulk_helper for updates of this index - will use to do many updates in one request
    # ####  NOTE: THE CURRENT VERSION OF BULK_HELPER REQUIRES "type" BUT ES VER 7 DOESN'T SUPPORT IT
    # ####  UNTIL A NEW VERSION COMPATIBLE WITH ES 7 COMES OUT, I'VE MADE A LOCAL MOD IN
    # ####  /usr/share/perl5/vendor_perl/Search/Elasticsearch/Client/6_0/Role/API.pm (line 57) TO NOT REQUIRE IT
    my $bulk = $es->bulk_helper(
        index => $index,
        max_count => 500,  # max no. of actions before flushing (sending request) 
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

    # Get aussie docs (flows with endpoints having Australian ASNs in this index; they may not be IN Australia).
    #   If a doc is already privatized, the relevant meta.src_asn will be 0, so those won't come up.
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
                bool => { should => [
                    {terms => { "meta.src_asn" => \@asn_array }},
                    {terms => { "meta.dst_asn" => \@asn_array }}  
                ] } 
            } 
        } 
    );

    my $scroll_total = $scroll->total;   # not sure why this is a hash with value and 'relation' => 'eq'!
    my $ndocs = $scroll_total->{'value'};
    $total_docs += $ndocs;
    print "\n".strftime('%F %T',localtime).
        " : Docs done = $total_docs_done,  should be = $total_docs.  Starting index = $index,  num aussie docs = $ndocs, \n";
    STDOUT->autoflush(1); 

    my $n = 0;
DOCLOOP:  while (my $doc = $scroll->next) {
        $n++;
        if ($n % 500 == 0) { print "."; STDOUT->autoflush(1); }   

        my $id = $doc->{'_id'};
        my $data = $doc->{'_source'};
        my $src_asn = $data->{'meta'}->{'src_asn'};
        my $dst_asn = $data->{'meta'}->{'dst_asn'};
        my $src_ip = $data->{'meta'}->{'src_ip'};
        my $dst_ip = $data->{'meta'}->{'dst_ip'};
        my $src_country = $data->{'meta'}->{'src_country_name'};
        my $dst_country = $data->{'meta'}->{'dst_country_name'};

      ##print "fixing ID = $id   \n"; 
      ##print "  src - dst: $src_asn - $dst_asn , $src_ip - $dst_ip \n"; 
      ##print Dumper $doc;
    
        # Is src or dst the "aussie" end?
        my $aussie_end = "src";
        $aussie_end = "dst"  if ( $asn_hash{$dst_asn} );

{ # turn off uninitalized variable warnings in this {}. Have to use a block label for next to work! 
  no warnings 'uninitialized';

        # skip if the country is not Australia (resources is not physically in Australia)
        my $cntry = $data->{'meta'}->{$aussie_end.'_country_name'};
        if ( $cntry ne "Australia" ) {
            ##print "  Skipping one because country $cntry is not Australia\n";
            $total_docs_done++;
            next DOCLOOP;
        }

        # Checks.
        no warnings 'uninitialized'; 
        my $check = $asn_hash{$src_asn} + $asn_hash{$dst_asn};
        if ($check == 0) 
            { die ("ERROR: How did a doc with neither src nor dst ASN in the list get into the results !?  _id = $id\n"); }
        elsif ($check == 2)
            { print ("WARNING: There is a flow with both src and dst ASNs in the list !?  index = $index  _id = $id \n") }
}
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
            # { "[meta][src_location][lat]" => -25 }
            # { "[meta][src_location][lon]" => 135 }
            # meta.dst_preferred_location.lat => -25
            # meta.dst_preferred_location.lon => 135
        my  $to_replace = {
                $aussie_end."_asn"          => 0,
                $aussie_end."_ip"           => "xx.xx.xx.xx",
                $aussie_end."_organization" => "Australian Academic and Research Network (AARNet)",
                $aussie_end."_location" => { "lat" => -25, "lon" => 135 },
                $aussie_end."_preferred_location" => { "lat" => -25, "lon" => 135 },
                $aussie_end."_preferred_org" => "Australian Academic and Research Network (AARNet)",
            };    

        # IF SCIREG DATA, ADD THESE TO FIELDS TO BE REDACTED
            # { "[meta][scireg][src][org_name]" => "Australian Academic and Research Network (AARNet)" }
            # { "[meta][scireg][src][org_abbr]" => "AARNet.au" }
            # { "[meta][scireg][src][resource]" => "AARNet member" }
            # { "[meta][scireg][src][resource_abbr]" => "AARNet" }
            # { "[meta][scireg][src][latitude]" => "-25" }
            # { "[meta][scireg][src][longitude]" => "135" }
            # { "[meta][scireg][src][asn]" => "0" }
            # set "[meta][scireg][src][projects]" to []
        my $scireg_exists = 0;
        $scireg_exists = 1  if ( $data->{'meta'}->{'scireg'}->{$aussie_end}->{'org_name'} ); 

        if ($scireg_exists) {
                my $scireg_to_replace = {
                    org_name      => 'Australian Academic and Research Network (AARNet)', 
                    org_abbr      => 'AARNET.au',
                    resource      => 'AARNET member',
                    resource_abbr => 'AARNET',
                    latitude      => '-25',
                    longitude     => '135',
                    asn           => '0',
                    projects      => []
                }; 

                $to_replace->{"scireg"}->{$aussie_end} = $scireg_to_replace;
        }

        # REDACT    
        # Add action to $bulk if there's anything to update (updates haven't been done already!).
        # The update query will be sent when max_count is reached. (can also call flush to do it manually)
        my $to_do =  { "PRIVATE" => $private_to_add,
                          "meta"    => $to_replace };

        $bulk->add_action( update => { id => $id,
                                       doc => $to_do,
                                       doc_as_upsert => "true" }
                         );
        
    } # end doc

    # finish any updates left
    $bulk->flush;

}  # end index

print strftime('%F %T',localtime).  " : Docs done = $total_docs_done,  should be = $total_docs.  \n";


