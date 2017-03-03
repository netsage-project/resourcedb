// GlobalNOC 2017

// Renders a resource in my_resource_list on index.html.
function renderMyResourceListElement(resource) {
    var table = document.getElementById('my_resource_list');
    var row   = table.insertRow(0);

    var id = resource.ip_block_id.toString();

    var name = row.insertCell(0);
    var addr = row.insertCell(1);

    name.innerHTML = resource.name;
    addr.innerHTML = resource.addr_str;

    row.addEventListener('click', function(e) {
        window.location.href = '/resource/index.html?resource_id=' + id;
    });
}

// Renders a resource in resource_list on index.html.
function renderResourceListElement(resource) {
    var table = document.getElementById('resource_list');
    var row   = table.insertRow(0);

    var id = resource.ip_block_id.toString();

    var type = row.insertCell(0);
    var name = row.insertCell(1);
    var addr = row.insertCell(2);
    var ownr = row.insertCell(3);
    var location = row.insertCell(4);

    type.innerHTML = resource.role_name;
    name.innerHTML = resource.name;
    addr.innerHTML = resource.addr_str;
    ownr.innerHTML = resource.organization_name;
    location.innerHTML = resource.country_name;

    row.addEventListener('click', function(e) {
        window.location.href = '/resource/index.html?resource_id=' + id;
    });
}

// Renders the number of resources resource_list should contain.
function renderResourceCount(count) {
    var text = document.getElementById('resource_list_count');

    text.innerHTML = count.toString() + ' records found';
}

// Given a resource record, set the innerHTML of the elements
// identified by resource_name and resource_description.
function renderResourceHeader(resource) {
    var name = document.getElementById('resource_name');
    var desc = document.getElementById('resource_description');

    name.innerHTML = resource.name;
    desc.innerHTML = resource.addr_str;
}

// Given a resouce record, set the innerHTML of the elements
// identified by resource_cidr, resource_country,
// resource_geolocation, resource_address, resource_organization, and
// resource_role.
function renderResourceRecord(resource) {
    var cidr = document.getElementById('resource_cidr');
    var country = document.getElementById('resource_country');
    var geolocation = document.getElementById('resource_geolocation');
    var address = document.getElementById('resource_address');
    var organization = document.getElementById('resource_organization');
    var role = document.getElementById('resource_role');
    var link = document.getElementById('resource_edit_link');

    cidr.innerHTML = resource.addr_str;
    country.innerHTML = resource.country_name;
    geolocation.innerHTML = resource.latitude.toString() + ' ' + resource.longitude.toString();
    address.innerHTML = resource.postal_code.toString();
    organization.innerHTML = resource.organization_name;
    role.innerHTML = resource.role_name;
    link.href = '/resource/edit.html?resource_id=' + resource.ip_block_id.toString();
}
