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
        window.location.href = basePath + 'resource/index.html?resource_id=' + id;
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
        window.location.href = basePath + 'resource/index.html?resource_id=' + id;
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
    desc.innerHTML = resource.description;
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

    if (resource.latitude == null || resource.longitude == null) {
        geolocation.innerHTML = 'Location is not available';
    } else {
        geolocation.innerHTML = resource.latitude.toString() + ' ' + resource.longitude.toString();
    }

    address.innerHTML = resource.postal_code.toString();
    organization.innerHTML = resource.organization_name;
    role.innerHTML = resource.role_name;
    link.href = '/resource/edit.html?resource_id=' + resource.ip_block_id.toString();
}

// Sets up submitCreateResource to be called when the create button on
// resource/new.html is pressed.
function setupCreateResourceForm() {
    console.log('setupCreateResourceForm');

    var submit = document.getElementById('create_resource_submit');
    submit.onclick = submitCreateResource;
}

// Appends an option to the resource_project drop down box on
// resource/new.html.
function renderCreateResourceFormProjectOption(project) {
    var dropd = document.getElementById('resource_project');
    var opt = document.createElement('option');

    opt.innerHTML = project.name;
    opt.setAttribute('value', project.project_id);

    dropd.appendChild(opt);
}

// Appends an option to the resource_organization drop down box on
// resource/new.html.
function renderCreateResourceFormOrganizationOption(org) {
    var dropd = document.getElementById('resource_organization');
    var opt = document.createElement('option');

    opt.innerHTML = org.name;
    opt.setAttribute('value', org.organization_id);

    dropd.appendChild(opt);
}

// Gathers values from create_resource_form on resource/new.html when
// the create button is pressed. Passes the collected values to
// createResource after parameters are validated.
function submitCreateResource(e) {
    var form = document.getElementById('create_resource_form');
    console.log('submitCreateResource');
    console.log(e);
    console.log(form.elements);

    var name = form.elements['resource_name'].value;
    var desc = form.elements['resource_description'].value;
    var cidr = form.elements['resource_cidr'].value;
    var args = cidr.split('/');
    var addr = args[0];
    var mask = args[1];

    var asn = form.elements['resource_asn'].value;

    var org_id = form.elements['resource_organization'].value;

    var country_code = 'NA';
    var country_name = form.elements['resource_country'].value;

    var continent_code = 'NA';
    var continent_name = form.elements['resource_continent'].value;

    var postal_code = form.elements['resource_postal_code'].value;

    var lat = parseFloat(form.elements['resource_latitude'].value);
    var lon = parseFloat(form.elements['resource_longitude'].value);

    var project_id = form.elements['resource_project'].value;

    var discipline_id = form.elements['resource_discipline'].value;
    var role_id = form.elements['resource_role'].value;

    createResource(name, desc, addr, mask, asn, org_id, country_code,
                   country_name, continent_code, continent_name, postal_code,
                   lat, lon, project_id, discipline_id, role_id);
}
