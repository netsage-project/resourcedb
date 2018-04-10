// GlobalNOC 2017

// Gets a project from the backend by projectId.
function getProject(projectId, onSuccess) {
    var url = baseUrl + 'api/index.cgi?method=get_projects' + '&project_id=' + projectId.toString();
    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log("getProject json: ");
            console.log(json);
            if (json.error_text) {
                alert (json.error_text);
            } else {
                onSuccess(json.results[0]);
            }
        });

    }).catch(function(err) {
        console.log("getProject error: " + err);
    });
}

// Gets a list of projects from the backend.
function getProjects(on_success) {
    fetch(baseUrl + 'api/index.cgi?method=get_projects', {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log("getProjectS json:");
            console.log(json);
            on_success(json.results);
        });

    }).catch(function(err) {
        console.log("getProjectS error: " + err);
    });
}

// Gets a list of projects from the backend where name is like text.
function getProjectsLike(text, on_success) {
    var url = baseUrl + 'api/index.cgi?method=get_projects';
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
        console.log("getProjectsLike Error: " + err);
    });
}

// Gets a list of projects from the backend where abbreviation = text.
function getProjectsWithAbbr(text, on_success) {
    var url = baseUrl + 'api/index.cgi?method=get_projects';
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
        console.log("getProjectsWithAbbr Error: " + err);
    });
}

// Gets a list of projects from the backend filtered by resourceID.
function getProjectsByResourceID(resourceID, on_success) {
    var url = baseUrl + 'api/index.cgi?method=get_projects' + '&ip_block_id=' + resourceID.toString();
    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log(json);
            on_success(json.results);
        });

    }).catch(function(err) {
        console.log("getProjectsByResourceID Error: " + err);
    });
}


// Gets an project's events from the backend by projectId.
function getProjectEvents(projectId, onSuccess) {
    var url = baseUrl + 'api/index.cgi?method=get_events' + '&project_id=' + projectId.toString();
    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {
        response.json().then(function(json) {
            console.log(json);
            onSuccess(json.results);
        });
    }).catch(function(err) {
        console.log("getProjectEvents Error: " + err);
    });
}

// Adds each of resourceIDs to projectID. Redirects to the project
// page for projectID on success.
function setProjectResourceLinks(projectID, resourceIDs) {
    var url = baseUrl + 'api/admin/index.cgi?method=set_project_ip_block_links&project_id=' + projectID.toString();
    for (var i = 0; i < resourceIDs.length; i++) {
        url += '&ip_block_id=' + resourceIDs[i];
    }

    fetch(url, {
        credentials: 'include',
        method:      'get'
    }).then(function(response) {
        response.json().then(function(json) {
            window.location.href = basePath + 'project/index.html?project_id=' + projectID;
        });
    }).catch(function(err) {
        console.log("setProjectResourceLinks Error: " + err);
        alert("Error or permission problem. Could not save.\nBe sure you are (still) logged in.");
    });
}

// Create or edit a new project using the backend api. On success, we
// redirect to the associated project/index.html page.
function createOrEditProject(id, name, abbr, desc, owner, email, projUrl, notes) {
    var url = baseUrl;
    if (id === null) {
        url += 'api/admin/index.cgi?method=add_projects';
    } else {
        url += 'api/admin/index.cgi?method=update_project';
        url += '&project_id=' + id.toString();
    }

    url += '&name=' + encodeURIComponent( name );
    url += '&abbr=' + encodeURIComponent( abbr );
    url += '&description=' + encodeURIComponent( desc );
    url += '&owner=' + encodeURIComponent( owner );
    url += '&email=' + encodeURIComponent( email );
    url += '&url=' + encodeURIComponent( projUrl );
    url += '&notes=' + encodeURIComponent( notes );

    function successCallback(project) {
        var id = project.project_id;
        window.location.href = basePath + 'project/index.html?project_id=' + id;
    };

    console.log(url);

    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log(json);
            if (json.error_text) {
                alert (json.error_text + ".\nOne cause could be a short name which is not unique.");
            } else {
                successCallback(json.results[0]);
            }
        });

    }).catch(function(err) {
        console.log("createdOrEdit Project Error: " + err);
        alert("Error or permission problem. Could not save.\nBe sure you are (still) logged in.");
    });
}

function deleteProject(id) {
    var url = baseUrl + 'api/admin/index.cgi?method=delete_projects';
    url += '&project_id=' + id.toString();

    function successCallback(resource) {
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
        console.log("deleteProject Error: " + err);
        alert("Error or permission problem. Could not delete.\nBe sure you are (still) logged in.");
    });
}
