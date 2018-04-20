// GlobalNOC 2017

// These functions get admin users from the resourcedb database 

// Get info about the person viewing the user interface
function getViewerInfo(on_success) {
    var url = baseUrl + 'api/index.cgi?method=get_loggedin_user'; 
    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log(json);
            on_success(json);
        });

    }).catch(function(err) {
        console.log("getViewerInfo Error: " + err);
    });
}


// Gets a list of users from the backend.
function getUsers(on_success) {
    var url = baseUrl + 'api/admin/index.cgi?method=get_users'; 
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

// Gets a user from the backend by user_id.
function getUser(user_id, on_success) {
    var url = baseUrl + 'api/admin/index.cgi?method=get_users' + '&user_id=' + user_id.toString();
    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log(json);
            on_success(json.results[0]);
        });

    }).catch(function(err) {
        console.log(err);
    });
}

// Add or Update a user using the backend api. 
function createOrEditUser(user_id, username, name) {
    var url = baseUrl;
    if (user_id === null) {
        url += 'api/admin/index.cgi?method=add_user';
    } else {
        url += 'api/admin/index.cgi?method=update_user';
        url += '&user_id=' + user_id.toString();
    }

    url += '&username=' + encodeURIComponent( username );
    url += '&name=' + encodeURIComponent( name );
    console.log("createOrEditUser url: " + url);

    function successCallback(user) {
        window.location.href = basePath + 'index.html';
    };

    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log(json);
            if (json.error || json.error_text) {
                alert ("ERROR: " + json.error_text + ".\nOne cause could be a username which is not unique.");
            } else {
                successCallback(json.results);
            }
        });

    }).catch(function(err) {
        console.log(err);
    });
}

// Delete a user
function deleteUser(user_id) {
    var url = baseUrl + 'api/admin/index.cgi?method=delete_user';
    url += '&user_id=' + user_id.toString();

    function successCallback(user) {
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

// Gets an user's events from the backend by userId.
function getUserEvents(userId, onSuccess) {
    var url = baseUrl + 'api/index.cgi?method=get_events' + '&user_id=' + userId.toString();
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
