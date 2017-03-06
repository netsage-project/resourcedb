package GRNOC::NetSage::ResourceDB::GWS::External;

use strict;
use warnings;

use GRNOC::Config;
use GRNOC::DatabaseQuery;
use GRNOC::WebService::Method;
use GRNOC::WebService::Regex;
use GRNOC::NetSage::ResourceDB::DataService::External;

use Data::Dumper;

our $websvc;

use base 'GRNOC::NetSage::ResourceDB::GWS';

sub new {

    my $caller = shift;

    my $class = ref( $caller );
    $class = $caller if ( !$class );

    my $self = $class->SUPER::new( @_ );

    bless( $self, $class );


    return $self;
}

sub _init_get_methods {

    my $self = shift;
    my $method_in = shift;
    my $args = shift;

    my $method;

    # get_ip_blocks
    $method = GRNOC::WebService::Method->new( name => 'get_geoip',
                                                   description => "Returns GeoIP data for an address",
                                                   expires => "-1d",
                                                   #default_order_by => ['name'],
                                                   callback => sub { $self->_get_geoip( @_ ) } );

    # add the required 'address' input param to the get_ip_blocks() method
    $method->add_input_parameter( name        => 'address',
                                  pattern     => $TEXT,
                                  required    => 0,
                                  multiple    => 0,
                                  description => 'The address/CIDR of the IP block');


    $self->websvc()->register_method( $method );

}

### callbacks ###

sub _get_geoip {

    my ( $self, $method, $args ) = @_;

    my $result = $self->external_ds()->get_geoip( $self->process_args( $args ) );

    # handle error
    if ( !$result ) {

        $method->set_error( $self->external_ds()->error() );
        return;
    }

    return {'results' => $result->results(),
            'total' => $result->total(),
            'warning' => $result->warning()};
}

1;

