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
    desc.innerHTML = project.project_id;
}

// Sets up submitCreateProject to be called when the create button on
// project/new.html is pressed.
function setupCreateProjectForm() {
    var submit = document.getElementById('create_project_submit');
    submit.onclick = submitCreateProject;
}


// Gathers values from create_project_form on project/new.html when
// the create button is pressed. Passes the collected values to
// createProject after parameters are validated.
function submitCreateProject(e) {
    var form = document.getElementById('create_project_form');
    console.log('submitCreateProject');
    console.log(form.elements);

    var name = form.elements['project_name'].value;
    var desc = form.elements['project_description'].value;
    var owner = form.elements['project_owner'].value;
    var email = form.elements['project_email'].value;

    createProject(name, desc, owner, email);
}
