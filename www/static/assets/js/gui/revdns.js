// GlobalNOC 2017

// shows info from reverse DNS in a table
function renderReverseDNSTable(revdns) {
        document.getElementById('reverse_dns_provider').innerHTML = revdns.provider;
        document.getElementById('reverse_dns_ip').innerHTML = revdns.ip;
        document.getElementById('reverse_dns_hostname').innerHTML = revdns.hostname
}

