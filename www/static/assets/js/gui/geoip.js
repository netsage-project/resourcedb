// GlobalNOC 2017

// shows info from GeoIP in a table
function renderGeoIPTable(geoip) {
    document.getElementById('geoip_provider').innerHTML = 'Maxmind';
    document.getElementById('geoip_organization').innerHTML = geoip.organization;
    document.getElementById('geoip_asn').innerHTML = geoip.asn;
    document.getElementById('geoip_country').innerHTML = geoip.country_name;
    document.getElementById('geoip_city').innerHTML = geoip.city;
    document.getElementById('geoip_region').innerHTML = geoip.region;
    document.getElementById('geoip_latitude').innerHTML = geoip.latitude;
    document.getElementById('geoip_longitude').innerHTML = geoip.longitude;
}

// shows info from GeoIP in a table and
// automatically fills in some info in the new-resource form
function renderGeoIPTable_autopop(geoip) {
    renderGeoIPTable(geoip);
    document.getElementById('resource_asn').value = geoip.asn;
    document.getElementById('resource_latitude').value = geoip.latitude;
    document.getElementById('resource_longitude').value = geoip.longitude;
    var countries = document.getElementById('resource_country');
    var sel = -1;
    for (var i=0; i < countries.length; i++) {
        if (countries.options[i].text == geoip.country_name) {
            sel = i;
            break;
        }
    }
    document.getElementById('resource_country').selectedIndex = sel;
}
