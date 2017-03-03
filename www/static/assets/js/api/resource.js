// GlobalNOC 2017

// Gets a resource from the backend by resource_id.
function getResource(resourceId, onSuccess) {
    var url = baseUrl + 'api/index.cgi?method=get_ip_blocks' + '&ip_block_id=' + resourceId.toString();
    fetch(url, {
        method: 'get'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log(json);
            onSuccess(json.results[0]);
        });

    }).catch(function(err) {
        console.log(err);
    });
}

// Gets a list of resources from the backend.
function getResources(on_success) {
    fetch(baseUrl + 'api/index.cgi?method=get_ip_blocks', {
        method: 'get'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log(json);
            on_success(json.results);
        });

    }).catch(function(err) {
        console.log(err);
    });
}
