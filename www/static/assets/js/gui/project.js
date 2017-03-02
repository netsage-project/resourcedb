// GlobalNOC 2017

// Renders a project in my_project_list on index.html.
function render_my_project(project) {
    var table = document.getElementById('my_project_list');

    var row = table.insertRow(0);

    var name = row.insertCell(0);

    name.id = 'project:' + project.project_id.toString();
    name.innerHTML = project.name;
}
