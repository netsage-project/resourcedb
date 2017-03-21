// GlobalNOC 2017

// Gets GeoIP information for the CIDR address.
function getGeoIP(cidr, onSuccess) {
    var args = cidr.split("/");
    var addr = args[0];

    var url = baseUrl + 'api/external.cgi?method=get_geoip';
    url += '&address=' + addr;
    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log(json);
            onSuccess(json.results);
        });

    }).catch(function(err) {
        console.log(err);
    });
}
