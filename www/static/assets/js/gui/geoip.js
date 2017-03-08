// GlobalNOC 2017

function renderGeoIPTable(geoip) {
    document.getElementById('geoip_provider').innerHTML = 'Maxmind';
    document.getElementById('geoip_organization').innerHTML = geoip.organization;
    document.getElementById('geoip_country').innerHTML = geoip.country_name;
    document.getElementById('geoip_city').innerHTML = geoip.city;
    document.getElementById('geoip_region').innerHTML = geoip.region;
    document.getElementById('geoip_latitude').innerHTML = geoip.latitude;
    document.getElementById('geoip_longitude').innerHTML = geoip.longitude;
}
