#!/usr/bin/perl

#--------------------------------------------------------------------
#----- GRNOC NetSage Resource Database Frontend WebService Wrapper
#-----
#----- Copyright(C) 2017 The Trustees of Indiana University
#--------------------------------------------------------------------
#----- This script is designed to be loaded by Apache + mod_perl and
#----- is just a wrapper to the GRNOC::NetSage::ResourceDB
#----- webservice library.
#--------------------------------------------------------------------

use strict;
use warnings;

use GRNOC::NetSage::ResourceDB;

use constant DEFAULT_CONFIG_FILE => '/etc/grnoc/netsage/resourcedb/config.xml';

our $websvc;

# make sure we only instantiate it once under mod_perl
if ( !defined( $websvc ) ) {

    $websvc = GRNOC::NetSage::ResourceDB->new( config_file => DEFAULT_CONFIG_FILE );
}

$websvc->handle_request();
