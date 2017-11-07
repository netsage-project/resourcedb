// GlobalNOC 2017

// Gets reverse DNS information for the CIDR address.
function getReverseDNS(cidr, onSuccess) {
    console.log ("in getReverseDNS");

    // JUST FIRST IP NUMBER IN THE LIST
    var args = cidr.split("/");
    var addr = args[0];

    var url = baseUrl + 'api/external.cgi?method=get_revdns';
    url += '&address=' + addr;
    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log(json);
            // execute the onSuccess function (render table), passing in the response.
            onSuccess(json.results);
        });

    }).catch(function(err) {
        console.log(err);
    });
}
