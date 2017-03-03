// GlobalNOC 2017

// Gets a list of resources from the backend.
function get_resources(on_success) {
    fetch(baseUrl + 'api/index.cgi?method=get_projects', {
        method: 'get'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log(json);
            on_success([
                {
                    name: 'JS DTN3',
                    addr: '127.0.0.1/32',
                    resource_id: 1
                },
                {
                    name: 'JS DTN4',
                    addr: '127.0.0.2/32',
                    resource_id: 2
                }
            ]);
        });

    }).catch(function(err) {
        console.log(err);
    });
}
