// GlobalNOC 2017

// These functions are for users in the resourcedb database 
// (not the database that allows shibboleth logins)

// Get info about the logged-in user. 
function getUserInfo(onSuccess) {
    var url = baseUrl + 'api/index.cgi?method=get_loggedin_user'; 
    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {
        response.json().then(function(json) {
            console.log(json);
            onSuccess(json);
        });

    }).catch(function(err) {
        console.log("getUserInfo Error: " + err);
    });
}

/*
// Gets a user from the backend by user_id.
function getUser(userId, onSuccess) {
    var url = baseUrl + 'api/admin/index.cgi?method=get_users' + '&user_id=' + userId.toString();
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

// Gets a list of users from the backend.
function getUsers(OnSuccess) {
    fetch(baseUrl + 'api/admin/index.cgi?method=get_users', {
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

// Add a new user using the backend api. 
function add(user_id, name) {
    console.log(url);

    fetch(baseUrl + 'api/admin/index.cgi?method=add_user', {
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
} */
/*
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


function deleteUser(id) {
    var url = baseUrl + 'api/admin/index.cgi?method=delete_user';
    url += '&user_id=' + id.toString();

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
*/
