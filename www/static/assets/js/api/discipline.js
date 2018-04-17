// GlobalNOC 2017

// Gets a list of disciplines from the backend.
function getDisciplines(onSuccess) {
    fetch(baseUrl + 'api/index.cgi?method=get_disciplines', {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log("getDisciplineS json:");
            console.log(json);
            onSuccess(json.results);
        });

    }).catch(function(err) {
        console.log("getDisciplineS error: " + err);
    });
}

// Gets an discipline from the backend by disciplineId.
function getDiscipline(disciplineId, onSuccess) {
    var url = baseUrl + 'api/index.cgi?method=get_disciplines' + '&discipline_id=' + disciplineId.toString();
    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log("getDiscipline json:");
            console.log(json);
            if (json.error_text) {
                alert (json.error_text);
            } else {
                onSuccess(json.results[0]);
            }
        });

    }).catch(function(err) {
        console.log("getDiscipline error: " + err);
    });
}

// Gets an discipline's events from the backend by disciplineId.
function getDisciplineEvents(disciplineId, onSuccess) {
    var url = baseUrl + 'api/index.cgi?method=get_events' + '&discipline_id=' + disciplineId.toString();
    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {
        response.json().then(function(json) {
            console.log(json);
            onSuccess(json.results);
        });
    }).catch(function(err) {
        console.log("getDisciplineEvents error: " + err);
    });
}


// Gets a list of disciplines from the backend where name is like text.
function getDisciplinesLike(text, on_success) {
    var url = baseUrl + 'api/index.cgi?method=get_disciplines';
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
        console.log("getDisciplinesLike error: " + err);
    });
}

// Creates or Updates a new discipline using the backend api. On success, we
// redirect to the home page
function createOrEditDiscipline(id, name, desc) {
    var url = baseUrl;
    if (id === null) {
        url += 'api/admin/index.cgi?method=add_disciplines';
    } else {
        url += 'api/admin/index.cgi?method=update_disciplines';
        url += '&discipline_id=' + id.toString();
    }

    url += '&name=' + encodeURIComponent( name );
    url += '&description=' + encodeURIComponent( desc );

    function successCallback(discipline) {
        var id = discipline.discipline_id;
        console.log("Added Discipline " + id);
        window.location.href = basePath + 'index.html';
    };

    console.log("createOrEditDiscipline url: " + url);

    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log("createOrEditDiscipline json: "); console.log(json);
            if (json.error_text) {
                alert (json.error_text);
            } else {
                successCallback(json.results[0]);
            }
        });

    }).catch(function(err) {
        console.log("createOrEditDiscipline error: " + err);
        alert("Error or permission problem. Could not save. \n Be sure you are (still) logged in.");
    });
}

function deleteDiscipline(id) {
    var url = baseUrl + 'api/admin/index.cgi?method=delete_disciplines';
    url += '&discipline_id=' + id.toString();

    function successCallback(discipline) {
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
        console.log("deleteDiscipline Error: " + err);
        alert("Error or permission problem. Could not delete.\nBe sure you are (still) logged in.");
    });
}
