#!/usr/bin/perl
use strict;
use warnings;

use POSIX qw/strftime/;
use Search::Elasticsearch;   # install perl-Search-Elasticsearch
use Getopt::Long;
use Data::Dumper;

# This script updates flows in ElasticSearch from the time the script is run, going back in time.
# This version will replace science registry disciplines (eg, Astronomy and Astrophysics) with new ones (eg, MPS.Astronomy)
# based on the given mapping.
# Uses default discipline mappings with overrides for some specific resource names.
# (Be sure the discipline descriptions hash matches what's in the resourcedb database!)
# RUN MANUALLY    (with '-es dev' to update es ES, '-es prod' to update production ES)

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

# Default mapping of old to new
my %discipline_hash = (
"Astronomy and Astrophysics" => "MPS.Astronomy", 
"Atmospheric Sciences" => "GEO.Atmospheric", 
"Bioinformatics" => "BIO.Genomics and Bioinformatics", 
"Biomedical" => "BIO.Medical", 
"Brain and Neurosciences" => "BIO.Medical", 
"Chemistry" => "MPS.Chemistry", 
"Climate Change (multi-discipline)" => "GEO.Climate", 
"Cognitive Sciences and Psychology" => "SBE.Psychology and Cognitive", 
"Computer Intelligence" => "CS.Intelligent Systems", 
"Earth Sciences" => "GEO.Earth", 
"Economics, Business" => "SBE.Social and Economics", 
"Energy" => "MPS.Physics", 
"Environmental Biology" => "BIO.Environmental", 
"GeoSpace" => "GEO.Atmospheric ", 
"Materials" => "MPS.Materials", 
"Mathematics and Statistics" => "MPS.Math", 
"Multiple" => "Multi-Science Facility", 
"Network Monitoring" => "CS.Network Testing and Monitoring", 
"Ocean Sciences" => "GEO.Ocean", 
"Other/Unspecified Biology" => "BIO.General", 
"Other/Unspecified Earth-Space" => "GEO.General", 
"Other/Unspecified IT" => "CS.General", 
"Other/Unspecified Physics" => "MPS.Physics", 
"Particle Physics" => "MPS.Physics.High Energy", 
"Remote Sensing" => "GEO.General", 
"Sociology, Politics, Culture" => "SBE.General", 
"Space Operations and Technology" => "non-science", 
"Unknown" => "Unknown", 
"VLBI (geodetic/astrometric)" => "MPS.Astronomy",
"Other" => "ENG.General" );
my %descrip_hash = (
"BIO.Environmental" => "Populations, species, ecosystems, ecological studies",
"BIO.Genomics and Bioinformatics" => "Genomes, protein sequences, *omics, statistics, computational biology",
"BIO.Medical" => "Cells, individual genes, cancer, medical research, brain research and modelling, neuroscience, biomedical databases",
"BIO.General" => "Other, unknown, or multiple types of Biology-related research",
"CS.Intelligent Systems" => "Includes computer vision and AI",
"CS.Network Testing and Monitoring" => "E.g., PerfSonar nodes",
"CS.General" => "Other, unknown, or multiple types of Computer Science and networking research",
"GEO.Atmospheric" => "Observation and modeling of atmospheric and geospace phenomena and weather, ionosphere, auroras, flares and space weather, etc. (see also Climate)",
"GEO.Climate" => "Climate change and its effects, including atmosphere and ocean modeling, multi-disciplinary studies",
"GEO.Earth" => "Geology, hydrology, tectonics, etc., Geodesy except primarily VLBI.",
"GEO.Ocean" => "The oceans and their contents (see also Climate)",
"GEO.General" => "Other, unknown, or multiple types of Earth Sciences; also general or multi-target remote sensing by satellites",
"MPS.Astronomy" => "Observational and theoretical astronony and astrophysics including cosmic rays, VLBA, VLBI for geodetic/astrometric purposes",
"MPS.Chemistry" => "Applied or theoretical chemisty",
"MPS.Materials" => "R&D related to materials including nanomaterials",
"MPS.Math" => "Mathematics and Statistics",
"MPS.Physics" => "Physics and energy research, other than high energy particle physics",
"MPS.Physics.High Energy" => "Theoretical and experimental sub-atomic particle physics; gridFTP and similar used mainly by the HEP community",
"SBE.Psychology and Cognitive" => "Research in cognition, language, social behavior, etc",
"SBE.Social and Economics" => "Economics, Political Science, and Sociology ",
"SBE.General" => "Other, unknown or multiple Social, Behavioral, and Economics areas",
"Multi-Science Facility" -> "A resource used by multiple sciences; most often a supercomputer or supercomputer center",
"ENG.General" => "Various types of Engineering",
"Unknown" => "Nothing is known about the science discipline",
"non-science" => "eg, Microsoft updates, CentOS mirror or archive, rocket and satellite systems, etc."
);
# resources with non-default new disciplines. (resource_name => new discipline)
my %nondefaults = (
"NASA - Solar and Heliospheric Observatory (SOHO)" => "MPS.Astronomy",
"Georgetown - Aspera Client" => "BIO.Genomics and Bioinformatics",
"NASA - Earth Observing System (EOS) - unknown" => "GEO.General",
"NASA - Langley Research Center" => "Unknown",
"FZ-Jülich" => "Unknown",
"Netspot - Moodle @ Monash University" => "non-science",
"NOAA - NCEP - ftp server - Boulder" => "GEO.Atmospheric",
"Glasgow - GridPP/ScotGrid" => "MPS.Physics.High Energy",
"RAL - GridPP - Ceph" => "MPS.Physics.High Energy",
"NOAA - NCEP - NOMADS Boulder" => "GEO.General",
"ESnet - unknown" => "Multi-Science Facility",
"UW - IRIS - DMC Web Services" => "GEO.Earth",
"ASTI - unknown" => "Unknown",
"NOAA - NCEI - NCDC - NOMADS" => "GEO.General",
"NOAA - NCEP - Maryland" => "GEO.Atmospheric",
"NOAA - NCEP - ftp server - Silver Spring" => "GEO.Atmospheric",
"Microsoft - Windows 10 Updates" => "non-science",
"SLAC - GridFTP server" => "MPS.Physics.High Energy",
"NOAA - NCEP - NOMADS Silver Spring" => "GEO.General",
"World Bank Group" => "non-science",
"Princeton - CentOS mirror" => "non-science",
"Johns Hopkins Univ. - Applied Physics Lab" => "MPS.Physics",
"Aerospace Corp." => "non-science",
"PolyU - Dept. of Computing" => "CS.General",
"NAOJ - WIDE Project - unknown" => "MPS.Astronomy",
"Federal Agency for Cartography and Geodes" => "GEO.Earth",
"WUSTL - XNAT" => "BIO.Genomics and Bioinformatics",
"MPCDF - GridFTP nodes" => "Multi-Science Facility",
"Edinburgh - RDF - GridPP Storage" => "MPS.Physics.High Energy",
"NICPB - HEPC - Grid FTP servers" => "MPS.Physics.High Energy",
"HKU" => "Unknown",
"NOAA - ESRL-GMD - Mauna Loa Observatory (MLO) - NOAA resources" => "GEO.Atmospheric",
"Duke - Linux Archive" => "non-science",
"CEN - I2 Connector" => "Unknown"
);
 
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
##if ($index =~ /2019\.10\./) { print ("SKIPPING $index\n"); next; }
##if ($index =~ /2019\.09\.[23-30]/) { print ("SKIPPING $index\n"); next; }
##if ($index =~ /2019\.08\./) { print ("QUITTING AT AUG 2019\n"); last; }
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

    # Do query to get scireg docs in this index
    #   In the query, "exists" will be true for empty strings too ?!?!
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
                    {exists => { "field" => "meta.scireg.src.discipline" }},
                    {exists => { "field" => "meta.scireg.dst.discipline" }}
                ] } 
            } 
        } 
    );

    my $scroll_total = $scroll->total;   # not sure why this is a hash with value and 'relation' => 'eq'!
    my $ndocs = $scroll_total->{'value'};
    print "num scireg docs = $ndocs \n";
    $total_docs += $ndocs;
    STDOUT->autoflush(1); 

    my $n = 0;
    # Loop over documents with sci reg data
    while (my $doc = $scroll->next) {
        $n++;
        if ($n % 1000 == 0) { print "."; STDOUT->autoflush(1); } # just some .'s to show things are happening

        my $id = $doc->{'_id'};
        my $data = $doc->{'_source'};
        my $src_discipline = $data->{'meta'}->{'scireg'}->{'src'}->{'discipline'};
        my $dst_discipline = $data->{'meta'}->{'scireg'}->{'dst'}->{'discipline'};
        my $src_resource = $data->{'meta'}->{'scireg'}->{'src'}->{'resource'};
        my $dst_resource = $data->{'meta'}->{'scireg'}->{'dst'}->{'resource'};
        my $src_ip = $data->{'meta'}->{'src_ip'};
        my $dst_ip = $data->{'meta'}->{'dst_ip'};

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

        # Get new disciplines from default mapping (won't find anything/reupdate if it's already a new-style discipline)
        # Revise the new default disciplines if needed using info in %nondefaults.
        my $updates;
        my $new_src_discipline = $discipline_hash{$src_discipline};
        if ( $nondefaults{$src_resource} ) {
            $new_src_discipline = $nondefaults{$src_resource};
            ###print"     resource: $src_resource ... Changed to $new_src_discipline\n"; ######
        } 
        my $new_dst_discipline = $discipline_hash{$dst_discipline};
        if ( $nondefaults{$dst_resource} ) {
            $new_dst_discipline = $nondefaults{$dst_resource};
            ###print"     resource: $dst_resource ... Changed to $new_dst_discipline\n"; ######
        } 
        ###print "===>  $new_src_discipline -> $new_dst_discipline.  \n"; #######

        # Check to be sure there is an update to do ("Unknown" is a case where old and new are the same)
        if ($src_discipline && $new_src_discipline && $src_discipline ne $new_src_discipline) {
            $updates->{"meta"}->{"scireg"}->{"src"}->{"discipline"} = $new_src_discipline;
            $updates->{"meta"}->{"scireg"}->{"src"}->{"discipline_description"} = $descrip_hash{$new_src_discipline};
        }
        if ($dst_discipline && $new_dst_discipline && $dst_discipline ne $new_dst_discipline) {
            $updates->{"meta"}->{"scireg"}->{"dst"}->{"discipline"} = $new_dst_discipline;
            $updates->{"meta"}->{"scireg"}->{"dst"}->{"discipline_description"} = $descrip_hash{$new_dst_discipline};
        }

        # Add action to $bulk if there's anything to update (updates haven't been done already!). 
        # The update query will be sent when max_count is reached. (can also call flush to do it manually)
        if ($updates) {
            $bulk->add_action( update => { id => $id,
                                           doc => $updates,
                                           doc_as_upsert => "true" }
                             );
            ###print "$src_discipline -> $dst_discipline.   "; #######
            ###print "===>  $new_src_discipline -> $new_dst_discipline.  \n"; #######
        } else { 
            ### print "    Skipping $id. Already updated. \n"; 
            $total_docs = $total_docs - 1;  
        }
} # end ignoring unitialized warnings

##########
# for testing, do just a few per index
#if($n == 10) { last; } 
#########

    } # end doc

    # finish anything updates left
    $bulk->flush;

}  # end index

print strftime('%F %T',localtime).  " : Docs done = $total_docs_done,  should be = $total_docs.  \n";


