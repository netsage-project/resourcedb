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
