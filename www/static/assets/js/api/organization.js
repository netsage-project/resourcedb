// GlobalNOC 2017

// Gets an organization from the backend by organizationId.
function getOrganization(organizationId, onSuccess) {
    var url = baseUrl + 'api/index.cgi?method=get_organizations' + '&organization_id=' + organizationId.toString();
    fetch(url, {
        method: 'get',
        credentials: 'include'
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
function getOrganizations(onSuccess) {
    fetch(baseUrl + 'api/index.cgi?method=get_organizations', {
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

// Creates a new organization using the backend api. On success, we
// redirect to the assoicated organization/index.html page.
function createOrganization(id, name, desc, owner, email, country_code,
                            country_name, continent_code, continent_name,
                            postal_code, latitude, longitude) {
    var url = baseUrl;
    if (id === null) {
        url += 'api/admin/index.cgi?method=add_organizations';
    } else {
        url += 'api/admin/index.cgi?method=update_organizations';
        url += '&organization_id=' + id.toString();
    }

    url += '&name=' + name;
    url += '&description=' + desc;
    url += '&owner=' + owner;
    url += '&email=' + email;
    url += '&country_code=' + country_code;
    url += '&country_name='  + country_name;
    url += '&continent_code='  + continent_code;
    url += '&continent_name='  + continent_name;
    url += '&postal_code='  + postal_code;
    url += '&latitude='  + latitude.toFixed(5);
    url += '&longitude='  + longitude.toFixed(5);

    function successCallback(organization) {
        var id = organization.organization_id;
        window.location.href = basePath + 'organization/index.html?organization_id=' + id;
    };

    console.log(url);

    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log(json);
            successCallback(json.results[0]);
        });

    }).catch(function(err) {
        console.log(err);
    });
}

function deleteOrganization(id) {
    var url = baseUrl + 'api/admin/index.cgi?method=delete_organizations';
    url += '&organization_id=' + id.toString();

    function successCallback(organization) {
        window.location.href = basePath + 'index.html';
    };

    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log(json);
            successCallback(json.results[0]);
        });

    }).catch(function(err) {
        console.log(err);
    });
}
