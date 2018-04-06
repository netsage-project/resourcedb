// GlobalNOC 2017

// Gets a resource from the backend by resource_id.
function getResource(resourceId, onSuccess) {
    var url = baseUrl + 'api/index.cgi?method=get_ip_blocks' + '&ip_block_id=' + resourceId.toString();
    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log("getResource json: ");
            console.log(json);
            onSuccess(json.results[0]);
        });

    }).catch(function(err) {
        console.log("getResource error: " + err);
    });
}

// Gets a list of resources from the backend.
function getResources(on_success) {
    fetch(baseUrl + 'api/index.cgi?method=get_ip_blocks', {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log("getResourceS json: ");
            console.log(json);
            on_success(json.results);
        });

    }).catch(function(err) {
        console.log("getResourceS error: " + err);
    });
}

// Gets a list of resources from the backend where 
// addr_string or name or organization's name is "like" text_str
function getResourcesLike(text, on_success) {
    var url = baseUrl + 'api/index.cgi?method=get_ip_blocks';
    url += '&text_str_like=' + encodeURIComponent( text );
    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log(json);
            on_success(json.results);
        });

    }).catch(function(err) {
        console.log("getResourcesLike error: " + err);
    });
}

// Gets a list of resources from the backend where abbreviation = text.
function getResourcesWithAbbr(text, on_success) {
    var url = baseUrl + 'api/index.cgi?method=get_ip_blocks';
    url += '&abbr=' + encodeURIComponent( text );
    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log("getResourcesWithAbbr json: ");
            console.log(json);
            on_success(json.results);
        });

    }).catch(function(err) {
        console.log("getResourcesWithAbbr error: " + err);
    });
}

// Gets an resource's events from the backend by resourceId.
function getResourceEvents(resourceId, onSuccess) {
    var url = baseUrl + 'api/index.cgi?method=get_events' + '&ip_block_id=' + resourceId.toString();
    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log("getResourceEvents json:");
            console.log(json);
            onSuccess(json.results);
        });

    }).catch(function(err) {
        console.log("getResourceEvents error: " + err);
    });
}

// Gets a list of resources from the backend that are filtered by
// project_id.
function getResourcesByProjectId(projectId, onSuccess) {
    var url = baseUrl + 'api/index.cgi?method=get_ip_blocks' + '&project_id=' + projectId.toString();
    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log("getResourcesByProjectId json: ");
            console.log(json);
            onSuccess(json.results);
        });

    }).catch(function(err) {
        console.log("getResourcesByProjectId error: " + err);
    });
}

// Gets a list of resources from the backend that are filtered by
// organization_id.
function getResourcesByOrganizationId(organizationId, onSuccess) {
    var url = baseUrl + 'api/index.cgi?method=get_ip_blocks' + '&organization_id=' + organizationId.toString();
    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log("getResourcesByOrganizationId json:");
            console.log(json);
            onSuccess(json.results);
        });

    }).catch(function(err) {
        console.log("getResourcesByOrganizationId error: " + err);
    });
}

// Creates a new resouce using the backend api. On success, we
// redirect to the associated resource/index.html page.
function createOrEditResource(id, name, abbr, desc, cidr, asn, org_id, country_code,
                              lat, lon, discipline_id, role_id, resUrl, notes) {
    var url = baseUrl;
    if (id === null) {
        url += 'api/admin/index.cgi?method=add_ip_blocks';
    } else {
        url += 'api/admin/index.cgi?method=update_ip_blocks';
        url += '&ip_block_id=' + id.toString();
    }

    url += '&name=' + encodeURIComponent( name );
    url += '&abbr=' + encodeURIComponent( abbr );
    url += '&description=' + encodeURIComponent( desc );
    url += '&addr_str=' + encodeURIComponent( cidr );
    url += '&asn=' + encodeURIComponent( asn );
    url += '&organization_id=' + encodeURIComponent( org_id );
    url += '&country_code=' + encodeURIComponent( country_code );
    url += '&latitude='  + encodeURIComponent( lat.toFixed(5) );
    url += '&longitude='  + encodeURIComponent( lon.toFixed(5) );
    url += '&discipline_id='  + encodeURIComponent( discipline_id );
    url += '&role_id='  + encodeURIComponent( role_id );
    url += '&url='  + encodeURIComponent( resUrl );
    url += '&notes='  + encodeURIComponent( notes );

    function successCallback(resource) {
        var id = resource.ip_block_id;
        window.location.href = basePath + 'resource/index.html?resource_id=' + id;
    };

    console.log("createOrEditResource url: " + url);

    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log("createOrEditResource json: ");
            console.log(json);
            successCallback(json.results[0]);
        });

    }).catch(function(err) {
        console.log("createOrEditResource error: " + err);
        alert("Error or permission problem. Could not save.");
    });
}

function deleteResource(id) {
    var url = baseUrl + 'api/admin/index.cgi?method=delete_ip_blocks';
    url += '&ip_block_id=' + id.toString();

    function successCallback(resource) {
        window.location.href = basePath + 'index.html';
    };

    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log("delete_ip_blocks json: ");
            console.log(json);
            successCallback(json.results[0]);
        });

    }).catch(function(err) {
        console.log("delete_ip_blocks error: " + err);
        alert("Error or permission problem. Could not delete.");
    });
}
