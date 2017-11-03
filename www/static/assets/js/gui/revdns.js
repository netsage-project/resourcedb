// GlobalNOC 2017

// shows info from reverse DNS in a table
function renderReverseDNSTable(revdns) {
    document.getElementById('reverse_dns_provider').innerHTML = 'hackertarget.com';
    document.getElementById('reverse_dns_ip').innerHTML = "some IP";
    document.getElementById('reverse_dns_hostname').innerHTML = "some host";
    //document.getElementById('reverse_dns_ip').innerHTML = revdns.ip;
    //document.getElementById('reverse_dns_hostname').innerHTML = revdns.hostname;
}

// shows info from reverse DNS in a table and
// automatically fills in some info in the new-resource form
//function renderReverseDNSTable_autopop(revDNS) {
//    renderReverseDNSTable(revDNS);
//    document.getElementById('resource_asn').value = geoip.asn;
//    document.getElementById('resource_latitude').value = geoip.latitude;
//    document.getElementById('resource_longitude').value = geoip.longitude;
//    var countries = document.getElementById('resource_country');
//    var sel = -1;
//    for (var i=0; i < countries.length; i++) {
//        if (countries.options[i].text == geoip.country_name) {
//            sel = i;
//            break;
//        }
//    }
//    document.getElementById('resource_country').selectedIndex = sel;
//}
