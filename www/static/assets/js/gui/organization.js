// GlobalNOC 2017

// Renders a organization in linked_organization_list on
// resource/index.html.
function renderLinkedOrganizationListElement(org) {
    var table = document.getElementById('linked_organization_list');
    var row   = table.insertRow(0);

    var id = org.organization_id.toString();

    var name = row.insertCell(0);

    name.innerHTML = org.name;

    row.addEventListener('click', function(e) {
        window.location.href = basePath + 'organization/index.html?organization_id=' + id;
    });
}

// Renders a organization in linked_organization_list on
// resource/index.html.
function renderMyOrganizationListElement(org) {
    var table = document.getElementById('my_organization_list');
    var row   = table.insertRow(0);

    var id = org.organization_id.toString();

    var name = row.insertCell(0);

    name.innerHTML = org.name;

    row.addEventListener('click', function(e) {
        window.location.href = basePath + 'organization/index.html?organization_id=' + id;
    });
}

// Given a organization record, set the innerHTML of the elements
// identified by organization_name and organization_description.
function renderOrganizationHeader(organization) {
    var name = document.getElementById('organization_name');
    var desc = document.getElementById('organization_description');

    name.innerHTML = organization.name;
    desc.innerHTML = organization.organization_id;
}

// Sets up submitCreateOrganization to be called when the create button on
// organization/new.html is pressed.
function setupCreateOrganizationForm() {
    console.log('setupCreateOrganizationForm');

    var submit = document.getElementById('create_organization_submit');
    submit.onclick = submitCreateOrganization;
}

// Gathers values from create_organization_form on organization/new.html when
// the create button is pressed. Passes the collected values to
// createOrganization after parameters are validated.
function submitCreateOrganization(e) {
    var form = document.getElementById('create_organization_form');
    console.log('submitCreateOrganization');
    console.log(form.elements);

    var name = form.elements['organization_name'].value;
    var desc = form.elements['organization_description'].value;
    var owner = form.elements['organization_owner'].value;
    var email = form.elements['organization_email'].value;

    var country_code = 'NA';
    var country_name = form.elements['organization_country'].value;

    var continent_code = 'NA';
    var continent_name = form.elements['organization_continent'].value;

    var postal_code = form.elements['organization_postal_code'].value;

    var lat = parseFloat(form.elements['organization_latitude'].value);
    var lon = parseFloat(form.elements['organization_longitude'].value);

    createOrganization(name, desc, owner, email, country_code, country_name,
                       continent_code, continent_name, postal_code, lat, lon);
}
