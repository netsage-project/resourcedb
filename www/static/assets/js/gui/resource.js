// GlobalNOC 2017

// Renders a resource in my_resource_list on index.html.
function render_my_resource(resource) {
    var table = document.getElementById('my_resource_list');

    var row = table.insertRow(0);

    row.id = 'resource:' + resource.resource_id.toString();

    var name = row.insertCell(0);
    var addr = row.insertCell(1);

    name.innerHTML = resource.name;
    addr.innerHTML = resource.addr;
}
