#!/usr/bin/env perl
#
# This script can be used to view the info for an IP in any mmdb file (maxmind geoip db's, science registry fake geoip db)
# Based on https://blog.maxmind.com/2015/09/29/building-your-own-mmdb-database-for-fun-and-profit/
#
# TO use:  perl query_mmdb.pl <mmdb filename> <ip_address>
#
use strict;
use warnings;

use Data::Dumper;
use MaxMind::DB::Reader;

my $file = shift @ARGV or die 'Usage: perl query_mmdb.pl <mmdb filename> <ip_address>';
if (! -e $file) { die 'File $file does not exist\n'; }

my $ip = shift @ARGV or die 'Usage: perl query_mmdb.pl <mmdb filename> <ip_address>';
print "IP: $ip\n";

my $reader = MaxMind::DB::Reader->new( file => $file );

my $record = $reader->record_for_address( $ip );
if ($record) {
    # print $record->{'city'}->{'names'}->{'en'}."\n";     ## for science registry mmdb
    print Dumper  $record;
    print "\n";
    } else {
        print "not found\n";
    }
