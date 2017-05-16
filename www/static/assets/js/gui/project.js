// GlobalNOC 2017

// Renders a project in my_project_list on index.html.
function renderMyProjectListElement(project) {
    var table = document.getElementById('my_project_list');
    var row   = table.insertRow(0);

    var id = project.project_id.toString();

    var name = row.insertCell(0);

    name.innerHTML = project.name;

    row.addEventListener('click', function(e) {
        window.location.href = basePath + 'project/index.html?project_id=' + id;
    });
}

// Renders a project in linked_project_list on resource/index.html.
function renderLinkedProjectListElement(project) {
    var table = document.getElementById('linked_project_list');
    var row   = table.insertRow(0);

    var id = project.project_id.toString();

    var name = row.insertCell(0);

    name.innerHTML = project.name;

    row.addEventListener('click', function(e) {
        window.location.href = basePath + 'project/index.html?project_id=' + id;
    });
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
// identified by project_owner, and project_email.
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

  document.getElementById('project_owner').innerHTML = project.owner;
  document.getElementById('project_email').innerHTML = project.email;
}

// Sets up submitCreateProject to be called when the create button on
// project/new.html is pressed.
function setupCreateProjectForm() {
    var submit = document.getElementById('create_project_submit');
    submit.onclick = submitCreateOrUpdateProject;
}


// Gathers values from create_project_form on project/new.html when
// the create button is pressed. Passes the collected values to
// createProject after parameters are validated.
function submitCreateOrUpdateProject(e) {
    var form = document.getElementById('create_project_form');
    console.log('submitCreateProject');
    console.log(form.elements);

    var name = form.elements['project_name'].value;
    var desc = form.elements['project_description'].value;
    var owner = form.elements['project_owner'].value;
    var email = form.elements['project_email'].value;
    var projUrl = form.elements['project_url'].value;

    // Hidden field project_id
    var project_id = parseInt(form.elements['project_id'].value);
    if (project_id === -1) {
        console.log('Creating a new project');
        createOrEditProject(null, name, desc, owner, email, projUrl);
    } else {
        console.log('Editing project ' + project_id.toString());
        createOrEditProject(project_id, name, desc, owner, email, projUrl);
    }
}

// Sets up submitEditProject to be called when the edit button on
// project/edit.html is pressed.
function setupEditProjectForm(project) {
    var id = document.getElementById('project_id');
    var name = document.getElementById('project_name');
    var desc = document.getElementById('project_description');
    var owner = document.getElementById('project_owner');
    var email = document.getElementById('project_email');
    var url = document.getElementById('project_url');

    id.value = project.project_id;
    name.value = project.name;
    desc.value = project.description;
    owner.value = project.owner;
    email.value = project.email;
    url.value = project.url;

    var submit = document.getElementById('edit_project_submit');
    submit.onclick = submitCreateOrUpdateProject;

    var del = document.getElementById('delete_project_submit');
    del.onclick = function(e) {
        deleteProject(project.project_id);
    };

    var cancel = document.getElementById('cancel_project_submit');
    cancel.onclick = function() {
        window.location.href = basePath + 'project/index.html?project_id=' + project.project_id;
    };
}
