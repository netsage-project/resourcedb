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
