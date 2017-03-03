// GlobalNOC 2017

// Gets a project from the backend by projectId.
function getProject(projectId, onSuccess) {
    var url = baseUrl + 'api/index.cgi?method=get_projects' + '&project_id=' + projectId.toString();
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

// Gets a list of projects from the backend.
function getProjects(on_success) {
    fetch(baseUrl + 'api/index.cgi?method=get_projects', {
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
