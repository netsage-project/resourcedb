// GlobalNOC 2017

// Gets an organization from the backend by organizationId.
function getOrganization(organizationId, onSuccess) {
    var url = baseUrl + 'api/index.cgi?method=get_organizations' + '&organization_id=' + organizationId.toString();
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

// Gets a list of organizations from the backend.
function getOrganizations(on_success) {
    fetch(baseUrl + 'api/index.cgi?method=get_organizations', {
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
