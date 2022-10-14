#!/usr/bin/env perl
# script to print out the contents of an mmdb file (MaxMind GeoIP database)
# Edit filename below then $ perl dump-mmdb.pl > output.csv

use strict;
use warnings;

use MaxMind::DB::Reader;
#use Net::Works::Address;

my $reader   = MaxMind::DB::Reader->new(
    file    => 'GeoLite2-ASN_2020Jul07.mmdb' 
);
$reader->iterate_search_tree(
    sub {
        my $ip_as_integer = shift;
        my $mask_length   = shift;
        my $data          = shift;

#        Without this, we just get integers instead of IP addresses, but I don't need the IPs for now, so skip it.
#        my $address = Net::Works::Address->new_from_integer( integer => $ip_as_integer );
#        print $address->as_ipv4_string."/".$mask_length;

    # for ASN database
    print $ip_as_integer."/".$mask_length.", ".$data->{'autonomous_system_number'}.", ".$data->{'autonomous_system_organization'}."\n";
    }
);
