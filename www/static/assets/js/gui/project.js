// GlobalNOC 2017

// Renders a project in my_project_list on index.html.
function renderMyProjectListElement(project) {
    var table = document.getElementById('my_project_list');
    var row   = table.insertRow(-1);

    var id = project.project_id.toString();

    var name = row.insertCell(0);
    var abbr = row.insertCell(1);

    name.innerHTML = project.name;
    abbr.innerHTML = project.abbr;

    row.addEventListener('click', function(e) {
        window.location.href = basePath + 'project/index.html?project_id=' + id;
    });
}

// Renders a project in linked_project_list on resource/index.html.
function renderLinkedProjectListElement(project) {
    var table = document.getElementById('project_list');
    var row   = table.insertRow(-1);

    var id = project.project_id.toString();

    var name = row.insertCell(0);
    name.innerHTML = project.name;

    var desc = row.insertCell(1);
    desc.innerHTML = project.description;

    row.addEventListener('click', function(e) {
        window.location.href = basePath + 'project/index.html?project_id=' + id;
    });
}

// Renders events as list items under project_event_list on
// project/index.html
function renderProjectEventListElement(event) {
    var eventText = document.createElement('span');
    eventText.innerHTML = '<b>' + event.date + '</b> - ' + event.message;

    var entry = document.createElement('li');
    entry.setAttribute('class', 'list-group-item');
    entry.appendChild(eventText);

    var listGroup = document.getElementById('project_event_list');
    listGroup.appendChild(entry);
}

// Given a project record, set the innerHTML of the elements
// identified by project_name and project_description.
function renderProjectHeader(project) {
    var name = document.getElementById('project_name');
    var desc = document.getElementById('project_description');

    name.innerHTML = project.name;
    desc.innerHTML = project.description;
}

// Given a project record, set the innerHTML of the elements
// identified by project_owner, and project_email, etc.
function renderProjectRecord(project) {
  var link = document.getElementById('project_edit_link');
  link.href = basePath + 'project/edit.html?project_id=' + project.project_id.toString();

  if (project.url != null) {
    var url = document.createElement('a');
    url.setAttribute('target', '_blank');
    url.setAttribute('href', project.url);
    url.innerText = project.url;
    document.getElementById('project_url').appendChild(url);
  }

  document.getElementById('project_abbr').innerHTML = project.abbr;
  document.getElementById('project_owner').innerHTML = project.owner;
  document.getElementById('project_email').innerHTML = project.email;

  var edit_link = document.getElementById('project_edit_resources');
  edit_link.href = basePath + 'project/link.html?project_id=' + project.project_id.toString();
}

// Empty my_project_list
function renderEmptyProjectList() {
    document.getElementById('my_project_list').innerHTML = '';
}

// Renders the number of projects  project_list should contain.
function renderProjectCount(count) {
    var text = document.getElementById('project_list_count');

    text.innerHTML = count.toString() + ' records found';
}

// Sets up submitCreateProject to be called when the create button on
// project/new.html is pressed.
function setupCreateProjectForm() {
    var form = document.getElementById('create_project_form');
    form.onsubmit = submitCreateOrUpdateProject;

    var cancel = document.getElementById('cancel_project_submit');
    cancel.onclick = function() {
        window.location.href = basePath + 'index.html';
    };
}

function setupProjectLinkResourceForm(project) {
    var link = document.getElementById('link_project');
    var cancel = document.getElementById('cancel_link_project');

    link.onclick = function() {
        var table = document.getElementById('selected_resource_list');
        var resourceIDs = [];

        for (var i = 0; i < table.rows.length; i++) {
            var id = table.rows[i].getAttribute('data-id');
            resourceIDs.push(id);
        }

        setProjectResourceLinks(project.project_id, resourceIDs);
    };

    cancel.onclick = function() {
        window.location.href = basePath + 'project/index.html?project_id=' + project.project_id.toString();
    };
}

// Gathers values from create_project_form on project/new.html when
// the create button is pressed. Passes the collected values to
// createProject after parameters are validated.
function submitCreateOrUpdateProject(e) {
    e.preventDefault();

    var form = document.getElementById('create_project_form');
    console.log('submitCreateProject');
    console.log(form.elements);

    var name = form.elements['project_name'].value;
    var abbr = form.elements['project_abbr'].value;
    var desc = form.elements['project_description'].value;
    var owner = form.elements['project_owner'].value;
    var email = form.elements['project_email'].value;
    var projUrl = form.elements['project_url'].value;

    // Hidden field project_id
    var project_id = parseInt(form.elements['project_id'].value);
    if (project_id === -1) {
        console.log('Creating a new project');
        createOrEditProject(null, name, abbr, desc, owner, email, projUrl);
    } else {
        console.log('Editing project ' + project_id.toString());
        createOrEditProject(project_id, name, abbr, desc, owner, email, projUrl);
    }
}

// Sets up submitEditProject to be called when a button on
// project/edit.html is pressed.
function setupEditProjectForm(project) {
    var id = document.getElementById('project_id');
    var name = document.getElementById('project_name');
    var abbr = document.getElementById('project_abbr');
    var desc = document.getElementById('project_description');
    var owner = document.getElementById('project_owner');
    var email = document.getElementById('project_email');
    var url = document.getElementById('project_url');

    id.value = project.project_id;
    name.value = project.name;
    abbr.value = project.abbr;
    desc.value = project.description;
    owner.value = project.owner;
    email.value = project.email;
    url.value = project.url;

    var form = document.getElementById('create_project_form');
    form.onsubmit = submitCreateOrUpdateProject;

    var del = document.getElementById('delete_project_submit');
    del.onclick = function(e) {
        deleteProject(project.project_id);
    };

    var cancel = document.getElementById('cancel_project_submit');
    cancel.onclick = function() {
        window.location.href = basePath + 'project/index.html?project_id=' + project.project_id;
    };
}
