// GlobalNOC 2017

// Gets an organization from the backend by organizationId.
function getOrganization(organizationId, onSuccess) {
    var url = baseUrl + 'api/index.cgi?method=get_organizations' + '&organization_id=' + organizationId.toString();
    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log("getOrganization json:");
            console.log(json);
            if (json.error_text) {
                alert (json.error_text);
            } else {
                onSuccess(json.results[0]);
            }
        });

    }).catch(function(err) {
        console.log("getOrganization error: " + err);
    });
}

// Gets an organization's events from the backend by organizationId.
function getOrganizationEvents(organizationId, onSuccess) {
    var url = baseUrl + 'api/index.cgi?method=get_events' + '&organization_id=' + organizationId.toString();
    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {
        response.json().then(function(json) {
            console.log(json);
            onSuccess(json.results);
        });
    }).catch(function(err) {
        console.log("getOrganizationEvents error: " + err);
    });
}

// Gets a list of organizations from the backend.
function getOrganizations(onSuccess) {
    fetch(baseUrl + 'api/index.cgi?method=get_organizations', {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log("getOrganizationS json:");
            console.log(json);
            onSuccess(json.results);
        });

    }).catch(function(err) {
        console.log("getOrganizationS error: " + err);
    });
}

// Gets a list of organizations from the backend where name is like text.
function getOrganizationsLike(text, on_success) {
    var url = baseUrl + 'api/index.cgi?method=get_organizations';
    url += '&name_like=' + encodeURIComponent( text );
    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log(json);
            on_success(json.results);
        });

    }).catch(function(err) {
        console.log("getOrganizationsLike error: " + err);
    });
}

// Gets a list of organizations from the backend where abbreviation = text.
function getOrgsByAbbr(text, on_success) {
    var url = baseUrl + 'api/index.cgi?method=get_organizations';
    url += '&abbr=' + encodeURIComponent( text );
    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log(json);
            on_success(json.results);
        });

    }).catch(function(err) {
        console.log("getOrgsByAbbr Error: " + err);
    });
}

// Creates or Updates a new organization using the backend api. On success, we
// redirect to the associated organization/index.html page.
function createOrEditOrganization(id, name, abbr, desc, owner, email, country_code, lat, lon, orgUrl, notes) {
    var url = baseUrl;
    if (id === null) {
        url += 'api/admin/index.cgi?method=add_organization';
    } else {
        url += 'api/admin/index.cgi?method=update_organization';
        url += '&organization_id=' + id.toString();
    }

    url += '&name=' + encodeURIComponent( name );
    url += '&abbr=' + encodeURIComponent( abbr );
    url += '&description=' + encodeURIComponent( desc );
    url += '&owner=' + encodeURIComponent( owner );
    url += '&email=' + encodeURIComponent( email );
    url += '&country_code=' + encodeURIComponent( country_code );
    url += '&latitude='  + encodeURIComponent( lat.toFixed(5) );
    url += '&longitude='  + encodeURIComponent( lon.toFixed(5) );
    url += '&url='  + encodeURIComponent( orgUrl );
    url += '&notes='  + encodeURIComponent( notes );

    function successCallback(organization) {
        var id = organization.organization_id;
        window.location.href = basePath + 'organization/index.html?organization_id=' + id;
    };

    console.log("createOrEditOrganization url: " + url);

    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log("createOrEditOrganization json: "); console.log(json);
            if (json.error_text) {
                alert (json.error_text + ".\nOne cause could be an org. name which is not unique.");
            } else {
                successCallback(json.results[0]);
            }
        });

    }).catch(function(err) {
        console.log("createOrEditOrganization error: " + err);
        alert("Error or permission problem. Could not save. \n Be sure you are (still) logged in.");
    });
}

function deleteOrganization(id) {
    var url = baseUrl + 'api/admin/index.cgi?method=delete_organization';
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
            if (json.error_text) {
                alert (json.error_text);
            } else {
                successCallback(json.results[0]);
            }
        });

    }).catch(function(err) {
        console.log("deleteOrganization Error: " + err);
        alert("Error or permission problem. Could not delete.\nBe sure you are (still) logged in.");
    });
}
