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

// Given a organization record, set the innerHTML of the elements
// identified by organization_name and organization_description.
function renderOrganizationHeader(organization) {
    var name = document.getElementById('organization_name');
    var desc = document.getElementById('organization_description');

    name.innerHTML = organization.name;
    desc.innerHTML = organization.organization_id;
}
