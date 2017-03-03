// GlobalNOC 2017

// Gets a list of projects from the backend.
function get_projects(on_success) {
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
