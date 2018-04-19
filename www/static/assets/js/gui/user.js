// GlobalNOC 2017

// Renders an user in the main list (id=user_list) on the homepage
// On row click, go to edit-user page.
function renderUserListElement(user) {
    var table = document.getElementById('user_list');
    var row   = table.insertRow(-1);

    var username = row.insertCell(0);
    var name = row.insertCell(1);
    username.innerHTML = user.username;
    name.innerHTML = user.name;

    row.addEventListener('click', function(e) {
        window.location.href = basePath + 'user/edit.html?user_id=' + user.user_id;
    });
}

// Renders events as list items under user_event_list on
// user/edit.html
function renderUserEventListElement(event) {
    var eventText = document.createElement('span');
    eventText.innerHTML = '<b>' + event.date + '</b> - ' + event.message;

    var entry = document.createElement('li');
    entry.setAttribute('class', 'list-group-item');
    entry.appendChild(eventText);

    var listGroup = document.getElementById('user_event_list');
    listGroup.appendChild(entry);
}

// Empty user_list
function renderEmptyUserList() {
    document.getElementById('user_list').innerHTML = '';
}

// Sets up what buttons do on the new user page
function setupCreateUserForm() {
    console.log('setupCreateUserForm');

    var form = document.getElementById('create_user_form');
    form.onsubmit = submitCreateOrUpdateUser;

    var cancel = document.getElementById('cancel_user_submit');
    cancel.onclick = function() {
        window.location.href = basePath + 'index.html';
    };
}

// Sets up form values and what buttons do on the edit user page
function setupEditUserForm(user) {
    document.getElementById('user_id').value = user.user_id; 
    document.getElementById('user_username').value = user.username;
    document.getElementById('user_name').value = user.name;  

    var form = document.getElementById('create_user_form');
    form.onsubmit = submitCreateOrUpdateUser;

    var del = document.getElementById('delete_user_submit');
    del.onclick = function(e) {
        deleteUser(user.user_id);
    };

    var cancel = document.getElementById('cancel_user_submit');
    cancel.onclick = function() {
        window.location.href = basePath + 'index.html';
    };
}

// Gathers values from form on new.html or edit.html when
// the submit button is pressed. Passes the collected values to
// createOrEditUser after parameters are validated.
function submitCreateOrUpdateUser(e) {
    e.preventDefault();

    var form = document.getElementById('create_user_form');
    console.log('submitCreateUser');

    var name = form.elements['user_name'].value;

    // Hidden field user_id 
    var user_id = form.elements['user_id'].value;

    if (user_id === -1) {
        console.log('Creating a new user');
        createOrEditUser(null, username, name);
    } else {
        console.log('Editing user ' + user_id);
        createOrEditUser(user_id, username, name);
    }
}

