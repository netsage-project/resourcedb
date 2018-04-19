// GlobalNOC 2017

// Gets list of roles from the backend.
function getRoles(onSuccess) {
  var url = baseUrl + 'api/index.cgi?method=get_roles';
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

// Gets an role from the backend by roleId.
function getRole(roleId, onSuccess) {
    var url = baseUrl + 'api/index.cgi?method=get_roles' + '&role_id=' + roleId.toString();
    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log("getRole json:");
            console.log(json);
            if (json.error_text) {
                alert ("ERROR: " + json.error_text);
            } else {
                onSuccess(json.results[0]);
            }
        });

    }).catch(function(err) {
        console.log("getRole error: " + err);
    });
}

// Gets an role's events from the backend by roleId.
function getRoleEvents(roleId, onSuccess) {
    var url = baseUrl + 'api/index.cgi?method=get_events' + '&role_id=' + roleId.toString();
    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {
        response.json().then(function(json) {
            console.log(json);
            onSuccess(json.results);
        });
    }).catch(function(err) {
        console.log("getRoleEvents error: " + err);
    });
}


// Gets a list of roles from the backend where name is like text.
function getRolesLike(text, on_success) {
    var url = baseUrl + 'api/index.cgi?method=get_roles';
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
        console.log("getRolesLike error: " + err);
    });
}

// Creates or Updates a new role using the backend api. On success, we
// redirect to the home page
function createOrEditRole(id, name, desc) {
    var url = baseUrl;
    if (id === null) {
        url += 'api/admin/index.cgi?method=add_role';
    } else {
        url += 'api/admin/index.cgi?method=update_role';
        url += '&role_id=' + id.toString();
    }

    url += '&name=' + encodeURIComponent( name );
    url += '&description=' + encodeURIComponent( desc );

    function successCallback(role) {
        var id = role.role_id;
        console.log("Added Role " + id);
        // return to main list
        window.location.href = basePath + 'index.html';
    };

    console.log("createOrEditRole url: " + url);

    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log("createOrEditRole json: "); console.log(json);
            if (json.error_text) {
                alert ("ERROR: " + json.error_text);
            } else {
                successCallback(json.results[0]);
            }
        });

    }).catch(function(err) {
        console.log("createOrEditRole error: " + err);
        alert("Error or permission problem. Could not save. \n Be sure you are (still) logged in.");
    });
}

function deleteRole(id) {
    var url = baseUrl + 'api/admin/index.cgi?method=delete_role';
    url += '&role_id=' + id.toString();

    function successCallback(role) {
        console.log("Deleted Role");
        // return to main list
        window.location.href = basePath + 'index.html';
    };

    fetch(url, {
        method: 'get',
        credentials: 'include'
    }).then(function(response) {

        response.json().then(function(json) {
            console.log(json);
            if (json.error_text) {
                alert ("ERROR: " + json.error_text);
            } else {
                successCallback(json.results[0]);
            }
        });

    }).catch(function(err) {
        console.log("deleteRole Error: " + err);
        alert("Error or permission problem. Could not delete.\nBe sure you are (still) logged in.");
    });
}
