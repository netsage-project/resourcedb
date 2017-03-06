package GRNOC::NetSage::ResourceDB::DataService::External;

use strict;
use warnings;

use Data::Validate::IP;
use GRNOC::Config;
use GRNOC::DatabaseQuery;
use Geo::IP;

use Data::Dumper;

use base 'GRNOC::NetSage::ResourceDB::DataService';

my $singleton;

my %continents = (
    'AF' => 'Africa',
    'AS' => 'Asia',
    'EU' => 'Europe',
    'NA' => 'North America',
    'OC' => 'Oceania',
    'SA' => 'South Africa'
);

### constructor ###
sub new {

    my $caller = shift;

    my $class = ref( $caller );
    $class = $caller if ( !$class );

    # if we've created this object (singleton) before, just return it
    return $singleton if ( defined( $singleton ) );

    my $self = $class->SUPER::new( @_ );

    bless( $self, $class );

    # store our newly created object as the singleton
    $singleton = $self;

    my $config = GRNOC::Config->new( config_file => $self->{'config_file'}, force_array => 0);
    $self->{'config'} = $config;

    return $self;
}

sub get_geoip {

    my ( $self, %args ) = @_;

    my $remote_user = $args{'remote_user'};

    # TODO: move geoip init to make it persistent under mod_perl
    $self->_init_geoip();
    my $geoip_city = $self->{'geoip_city'};
    my $geoip_city_ipv6 = $self->{'geoip_city_ipv6'};
    my $geoip_asn = $self->{'geoip_asn'};
    my $geoip_asn_ipv6 = $self->{'geoip_asn_ipv6'};

    my $address = $args{'address'};
    # TODO: handle CIDR input
    my $ip = $address;

    my %results = ();

    my $asn_org;
    my $record;

    if ( is_ipv4( $ip ) ) {
        $asn_org = $geoip_asn->org_by_addr( $ip );
        $record = $geoip_city->record_by_addr( $ip );
    } elsif ( is_ipv6( $ip ) ) {
        $record = $geoip_city_ipv6->record_by_addr( $ip );
        $asn_org =  $geoip_asn_ipv6->name_by_addr_v6 ( $ip );
    } else {
        $self->error("Invalid ipv4/ipv6 address supplied");
        return;
    }

    if ( $record ) {
        $results{'country_code'} = $record->country_code;
        $results{'country_name'} = $record->country_name;
        $results{'city'} = $record->city;
        $results{'region'} = $record->region;
        $results{'region_name'} = $record->region_name;
        $results{'postal_code'} = $record->postal_code;
        $results{'time_zone'} = $record->time_zone;
        $results{'latitude'} = $record->latitude;
        $results{'longitude'} = $record->longitude;
        $results{'continent_code'} = $record->continent_code;
        $results{'continent'} = $self->get_continent( $record->continent_code );

    }

    if ( $asn_org ) {
        if ( $asn_org =~ /^AS(\d+)\s+(.+)$/ ) {
            my $asn = $1;
            my $organization = $2;
            $results{'asn'} = $asn;
            $results{'organization'} = $organization;

        } else {
            #warn "\n\nASN/ORG don't match regex\n\n";
        }
    }


    if ( !%results ) {

        $self->error( 'An unknown error occurred getting the geoip information.' );
        return;
    }


    my $result = GRNOC::NetSage::ResourceDB::DataService::Result->new( results => \%results,
                                                                 #total => $num_rows,
                                                                 );

    return $result;

}

sub _init_geoip {
    my $self = shift;
    my $config = $self->{'config'};

    my $geoip_city_ipv6_file = $config->get( '/config/geoip/config_files/city_ipv6' );
    my $geoip_city_ipv6 = Geo::IP->open( $geoip_city_ipv6_file, GEOIP_MEMORY_CACHE);
    $self->{'geoip_city_ipv6'} = $geoip_city_ipv6;

    my $geoip_asn_ipv6_file = $config->get( '/config/geoip/config_files/asn_ipv6' );
    my $geoip_asn_ipv6 = Geo::IP->open( $geoip_asn_ipv6_file, GEOIP_MEMORY_CACHE);
    $self->{'geoip_asn_ipv6'} = $geoip_asn_ipv6;

    my $geoip_city_file = $config->get( '/config/geoip/config_files/city' );
    my $geoip_city = Geo::IP->open( $geoip_city_file, GEOIP_MEMORY_CACHE);
    $self->{'geoip_city'} = $geoip_city;

    my $geoip_asn_file = $config->get( '/config/geoip/config_files/asn' );
    my $geoip_asn = Geo::IP->open( $geoip_asn_file, GEOIP_MEMORY_CACHE);
    $self->{'geoip_asn'} = $geoip_asn;
}

sub get_continent {
    my ( $self, $abbr ) = @_;
    my $continent = $continents{ $abbr };

    return $continent;
}

1;
