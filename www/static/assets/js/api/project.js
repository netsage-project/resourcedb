// GlobalNOC 2017

// Gets a project from the backend by projectId.
function getProject(projectId, onSuccess) {
    var url = baseUrl + 'api/index.cgi?method=get_projects' + '&project_id=' + projectId.toString();
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

// Gets a list of projects from the backend.
function getProjects(on_success) {
    fetch(baseUrl + 'api/index.cgi?method=get_projects', {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log(json);
            on_success(json.results);
        });

    }).catch(function(err) {
        console.log(err);
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
        console.log(err);
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
        console.log(err);
    });
}

// Adds each of resourceIDs to projectID. Redirects to the project
// page for projectID on success.
function setProjectResourceLinks(projectID, resourceIDs) {
    var url = baseUrl + 'api/index.cgi?method=set_project_ip_block_links&project_id=' + projectID.toString();
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
        console.log(err);
    });
}

// Create or edit a new project using the backend api. On success, we
// redirect to the assoicated project/index.html page.
function createOrEditProject(id, name, desc, owner, email, projUrl) {
    var url = baseUrl;
    if (id === null) {
        url += 'api/admin/index.cgi?method=add_projects';
    } else {
        url += 'api/index.cgi?method=update_project';
        url += '&project_id=' + id.toString();
    }

    url += '&name=' + name;
    url += '&description=' + desc;
    url += '&owner=' + owner;
    url += '&email=' + email;
    url += '&url=' + projUrl;

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
            successCallback(json.results[0]);
        });

    }).catch(function(err) {
        console.log(err);
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
            successCallback(json.results[0]);
        });

    }).catch(function(err) {
        console.log(err);
    });
}
