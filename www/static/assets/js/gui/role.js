// GlobalNOC 2017

// Renders an role in the main list (id=role_list) on the homepage
// On row click, go to edit-role page.
function renderRoleListElement(role) {
    var table = document.getElementById('role_list');
    var row   = table.insertRow(-1);

    var id = role.role_id.toString();

    var name = row.insertCell(0);
    var description = row.insertCell(1);

    name.innerHTML = role.name;
    description.innerHTML = role.description;

    row.addEventListener('click', function(e) {
        window.location.href = basePath + 'role/edit.html?role_id=' + id;
    });
}

// Renders events as list items under role_event_list on
// role/edit.html
function renderRoleEventListElement(event) {
    var eventText = document.createElement('span');
    eventText.innerHTML = '<b>' + event.date + '</b> - ' + event.message;

    var entry = document.createElement('li');
    entry.setAttribute('class', 'list-group-item');
    entry.appendChild(eventText);

    var listGroup = document.getElementById('role_event_list');
    listGroup.appendChild(entry);
}

// Empty role_list
function renderEmptyRoleList() {
    document.getElementById('role_list').innerHTML = '';
}

// Sets up what buttons do on the new role page
function setupCreateRoleForm() {
    console.log('setupCreateRoleForm');

    var form = document.getElementById('create_role_form');
    form.onsubmit = submitCreateOrUpdateRole;

    var cancel = document.getElementById('cancel_role_submit');
    cancel.onclick = function() {
        window.location.href = basePath + 'index.html';
    };
}

// Sets up form values and what buttons do on the edit role page
function setupEditRoleForm(role) {
    document.getElementById('role_id').value = role.role_id;
    document.getElementById('role_name').value = role.name;
    document.getElementById('role_description').value = role.description;

    var form = document.getElementById('create_role_form');
    form.onsubmit = submitCreateOrUpdateRole;

    var del = document.getElementById('delete_role_submit');
    del.onclick = function(e) {
        deleteRole(role.role_id);
    };

    var cancel = document.getElementById('cancel_role_submit');
    cancel.onclick = function() {
        window.location.href = basePath + 'index.html';
    };
}

// Gathers values from form on new.html or edit.html when
// the submit button is pressed. Passes the collected values to
// createOrEditRole after parameters are validated.
function submitCreateOrUpdateRole(e) {
    e.preventDefault();

    var form = document.getElementById('create_role_form');
    console.log('submitCreateRole');

    var name = form.elements['role_name'].value;
    var desc = form.elements['role_description'].value;
    if (desc) { desc = desc.replace(/[\u2018\u2019]/g, "'"); } // replace smart quotes
    if (desc) { desc = desc.replace(/[\u201C\u201D]/g, '"'); } // replace smart quotes

    // Hidden field role_id
    var id = parseInt(form.elements['role_id'].value);

    if (id === -1) {
        console.log('Creating a new role');
        createOrEditRole(null, name, desc);
    } else {
        console.log('Editing role ' + id.toString());
        createOrEditRole(id, name, desc);
    }
}

