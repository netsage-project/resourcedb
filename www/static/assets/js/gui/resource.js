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

function renderEmptyResourceList() {
    document.getElementById('resource_list').innerHTML = '';
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
    link.href = basePath + 'resource/edit.html?resource_id=' + resource.ip_block_id.toString();
}

// Sets up submitCreateResource to be called when the create button on
// resource/new.html is pressed.
function setupCreateResourceForm() {
    var id = document.getElementById('resource_id');
    id.value = -1;

    var submit = document.getElementById('create_resource_submit');
    submit.onclick = submitCreateOrUpdateResource;
}

// Sets up submitEditResource to be called when the edit button on
// resource/edit.html is pressed.
function setupEditResourceForm(resource) {
    var id = document.getElementById('resource_id');

    var name = document.getElementById('resource_name');
    var desc = document.getElementById('resource_description');
    var cidr = document.getElementById('resource_cidr');

    var asn = document.getElementById('resource_asn');

    var org = document.getElementById('resource_organization');

    var country = document.getElementById('resource_country');
    var continent = document.getElementById('resource_continent');
    var postal_code = document.getElementById('resource_postal_code');

    var lat = document.getElementById('resource_latitude');
    var lon = document.getElementById('resource_longitude');

    var project = document.getElementById('resource_project');
    var discipline = document.getElementById('resource_discipline');
    var role = document.getElementById('resource_role');

    id.value = resource.ip_block_id;
    name.value = resource.name;
    desc.value = resource.description;
    cidr.value = resource.addr_str;
    asn.value = resource.asn;
    org.value = resource.organization_id;
    country.value = resource.country_name;
    continent.value = resource.continent_name;
    postal_code.value = resource.postal_code;
    lat.value = resource.latitude;
    lon.value = resource.longitude;
    project.value = resource.project_id;
    discipline.value = resource.discipline_id;
    role = resource.role_id;

    var submit = document.getElementById('edit_resource_submit');
    submit.onclick = submitCreateOrUpdateResource;

    var del = document.getElementById('delete_resource_submit');
    del.onclick = function(e) {
        deleteResource(resource.ip_block_id);
    };

    var cancel = document.getElementById('cancel_resource_submit');
    cancel.onclick = function() {
        window.location.href = basePath + 'resource/index.html?resource_id=' + resource.ip_block_id;
    };
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
function submitCreateOrUpdateResource(e) {
    var form = document.getElementById('create_resource_form');
    console.log('submitCreateResource');
    console.log(e);
    console.log(form.elements);

    var name = form.elements['resource_name'].value;
    var desc = form.elements['resource_description'].value;
    var cidr = form.elements['resource_cidr'].value;

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

    // Hidden field resource_id
    var resource_id = parseInt(form.elements['resource_id'].value);

    if (resource_id === -1) {
        console.log('Creating a new resource');
        createOrEditResource(null, name, desc, cidr, asn, org_id, country_code,
                       country_name, continent_code, continent_name, postal_code,
                       lat, lon, project_id, discipline_id, role_id);
    } else {
        console.log('Editing resource ' + resource_id.toString());
        createOrEditResource(resource_id, name, desc, cidr, asn, org_id, country_code,
                             country_name, continent_code, continent_name, postal_code,
                             lat, lon, project_id, discipline_id, role_id);
    }
}

// Calls onChange and passes the updated value of resource_cidr as the
// first argument.
function onResourceCIDRChange(onChange) {
    var cidr = document.getElementById('resource_cidr');
    cidr.addEventListener('change', function(e) {
        onChange(e.target.value);
    });
}

// Calls onKeyUp whenever the search_field has been updated, and
// disables form submit behavior on search_form.
function onResourceSearchKeyUp(onKeyUp) {
    var search = document.getElementById('search_field');
    var form = document.getElementById('search_form');

    form.addEventListener('submit', function(e) {
        e.preventDefault();
    }, false);

    search.addEventListener('keyup', function(e) {
        onKeyUp(e.target.value);
    });
}
