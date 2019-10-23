#!/usr/bin/env perl

# This script can be used to view the info for an IP in the science registry mmdb file
# (or any mmdb file with appropriate edits)
# User must provide an mmdb filename/path and an IP address on the command line
# RUN MANUALLY

# based on https://blog.maxmind.com/2015/09/29/building-your-own-mmdb-database-for-fun-and-profit/

use strict;
use warnings;

#use Data::Dumper;
use MaxMind::DB::Reader;

my $file = shift @ARGV or die 'Usage: perl query_mmdb.pl <mmdb filename> <ip_address>';
if (! -e $file) { die 'File $file does not exist\n'; }

my $ip = shift @ARGV or die 'Usage: perl query_mmdb.pl <ip_address>';
print "IP: $ip\n";

my $reader = MaxMind::DB::Reader->new( file => $file );

my $record = $reader->record_for_address( $ip );
if ($record) {
    print $record->{'city'}->{'names'}->{'en'}."\n";
} else {
    print "not found\n";
}
