// GlobalNOC 2017

// Renders a organization in linked_organization_list //// not currently used (?) 
function renderLinkedOrganizationListElement(org) {
    var table = document.getElementById('linked_organization_list');
    var row   = table.insertRow(-1);

    var id = org.organization_id.toString();

    var name = row.insertCell(0);

    name.innerHTML = org.name;

    row.addEventListener('click', function(e) {
        window.location.href = basePath + 'organization/index.html?organization_id=' + id;
    });
}

// Renders an orgnaization in the main list (id=organization_list) on the homepage
function renderOrganizationListElement(org) {
    var table = document.getElementById('organization_list');
    var row   = table.insertRow(-1);

    var id = org.organization_id.toString();

    var abbr = row.insertCell(0);
    var name = row.insertCell(1);
    var country = row.insertCell(2);

    abbr.innerHTML = org.abbr;
    name.innerHTML = org.name;
    country.innerHTML = org.country_name;

    row.addEventListener('click', function(e) {
        window.location.href = basePath + 'organization/index.html?organization_id=' + id;
    });
}

// Renders events as list items under orgnization_event_list on
// organization/index.html
function renderOrganizationEventListElement(event) {
    var eventText = document.createElement('span');
    eventText.innerHTML = '<b>' + event.date + '</b> - ' + event.message;

    var entry = document.createElement('li');
    entry.setAttribute('class', 'list-group-item');
    entry.appendChild(eventText);

    var listGroup = document.getElementById('organization_event_list');
    listGroup.appendChild(entry);
}

// Given a organization record, set the innerHTML of the elements
// identified by organization_name and organization_description.
function renderOrganizationHeader(organization) {
    var name = document.getElementById('organization_name');
    var desc = document.getElementById('organization_description');

    name.innerHTML = organization.name;
    desc.innerHTML = organization.description;
}

// Organization details page -
// Given a organization record, set the innerHTML of the elements
function renderOrganizationRecord(organization) {

  // Show an active "edit" icon for logged-in users only
  var link = document.getElementById('organization_edit_link');
  var href = basePath + 'organization/edit.html?organization_id=' + organization.organization_id.toString();
  renderPublicPrivate(link, href);
  // Show an active "Add resource" icon for logged-in users only
  var new_res_link = document.getElementById('org_new_resource');
  var new_res_href = basePath + '/resource/new.html';
  renderPublicPrivate(new_res_link, new_res_href);

  if (organization.url != null) {
    var url = document.createElement('a');
    url.setAttribute('target', '_blank');
    url.setAttribute('href', organization.url);
    url.innerText = organization.url;
    document.getElementById('organization_url').appendChild(url);
  }

  document.getElementById('organization_abbr').innerHTML = organization.abbr;
  document.getElementById('organization_country').innerHTML = organization.country_name;
  document.getElementById('organization_owner').innerHTML = organization.owner;
  document.getElementById('organization_email').innerHTML = organization.email;
  if (organization.notes) { document.getElementById('organization_notes').innerHTML = organization.notes.replace(/ @@ /g,"<br>"); } // new-lines are @@ in db.

  geolocation = document.getElementById('organization_geolocation');
  if (organization.latitude == null || organization.longitude == null) {
        geolocation.innerHTML = 'Location unknown';
  } else {
        geolocation.innerHTML = organization.latitude.toString() + ', ' + organization.longitude.toString();
  }

    
}

// Empty organization_list
function renderEmptyOrganizationList() {
    document.getElementById('organization_list').innerHTML = '';
}

// Renders the number of organizations organization_list should contain.
function renderOrganizationCount(count) {
    var text = document.getElementById('organization_list_count');

    text.innerHTML = count.toString() + ' records found';
}

// Sets up submitCreateOrganization to be called when the create button on
// organization/new.html is pressed.
function setupCreateOrganizationForm() {
    console.log('setupCreateOrganizationForm');

    var country = document.getElementById('organization_country');
    var sel = -1;
    for (var i in countries) {
        var opt = document.createElement('option');

        opt.innerHTML = countries[i];
        opt.setAttribute('value', i);
        country.appendChild(opt);
        if (opt.innerHTML == "United States") {  // default selection
            opt.selected = true;
        }
    }
    
    var form = document.getElementById('create_organization_form');
    form.onsubmit = submitCreateOrUpdateOrganization;

    var cancel = document.getElementById('cancel_organization_submit');
    cancel.onclick = function() {
        window.location.href = basePath + 'index.html';
    };
}

// Gathers values from form on organization/new.html or edit.html when
// the submit button is pressed. Passes the collected values to
// createOrEditOrganization after parameters are validated.
function submitCreateOrUpdateOrganization(e) {
    e.preventDefault();

    var form = document.getElementById('create_organization_form');
    console.log('submitCreateOrganization');

    var name = form.elements['organization_name'].value;
    var abbr = form.elements['organization_abbr'].value;

    var desc = form.elements['organization_description'].value;
    if (desc) { desc = desc.replace(/[\u2018\u2019]/g, "'"); } // replace smart quotes
    if (desc) { desc = desc.replace(/[\u201C\u201D]/g, '"'); } // replace smart quotes

    var owner = form.elements['organization_owner'].value;
    var email = form.elements['organization_email'].value;

    var orgUrl = form.elements['organization_url'].value;

    var notes  = form.elements['organization_notes'].value;
    if (notes) { notes = notes.replace(/\n/g, " @@ "); } // encode new lines as @@ in the db
    if (notes) { notes = notes.replace(/[\u2018\u2019]/g, "'"); } // replace smart quotes
    if (notes) { notes = notes.replace(/[\u201C\u201D]/g, '"'); } // replace smart quotes

    var country_code = form.elements['organization_country'].value;

    var lat = parseFloat(form.elements['organization_latitude'].value);
    var lon = parseFloat(form.elements['organization_longitude'].value);

    // Hidden field organization_id
    var id = parseInt(form.elements['organization_id'].value);

    if (id === -1) {
        console.log('Creating a new organization');
        createOrEditOrganization(null, name, abbr, desc, owner, email, country_code,
                           lat, lon, orgUrl, notes);
    } else {
        console.log('Editing organization ' + id.toString());
        createOrEditOrganization(id, name, abbr, desc, owner, email, country_code,
                           lat, lon, orgUrl, notes);
    }
}

function setupEditOrganizationForm(org) {
    document.getElementById('organization_id').value = org.organization_id;
    document.getElementById('organization_name').value = org.name;
    document.getElementById('organization_abbr').value = org.abbr;
    document.getElementById('organization_description').value = org.description;

    document.getElementById('organization_owner').value = org.owner;
    document.getElementById('organization_email').value = org.email;
    document.getElementById('organization_url').value = org.url;
    if (org.notes) { document.getElementById('organization_notes').value = org.notes.replace(/ @@ /g, "\n"); }  // new-lines are @@ in the db

    var country = document.getElementById('organization_country');
    for (var i in countries) {
        var opt = document.createElement('option');

        opt.innerHTML = countries[i];
        opt.setAttribute('value', i);

        // select current country
        if (i == org.country_code) {
            opt.selected = "true"; 
        }

        country.appendChild(opt);
    }

    document.getElementById('organization_latitude').value = org.latitude || 0.0;
    document.getElementById('organization_longitude').value = org.longitude || 0.0;

    var form = document.getElementById('create_organization_form');
    form.onsubmit = submitCreateOrUpdateOrganization;

    var del = document.getElementById('delete_organization_submit');
    del.onclick = function(e) {
        deleteOrganization(org.organization_id);
    };

    var cancel = document.getElementById('cancel_organization_submit');
    cancel.onclick = function() {
        window.location.href = basePath + 'organization/index.html?organization_id=' + org.organization_id;
    };
}

// Calls onChange and passes the updated value of abbr as the
// first argument.
function onOrgAbbrChange(onChange) {
    var abbr = document.getElementById('organization_abbr');
    abbr.addEventListener('change', function(e) {
        onChange(e.target.value);
    });
}

// Checks to see if an Abbr is already in the db and warns the user
function checkOrgAbbr(newAbbr) {
    getOrgWithAbbr(newAbbr, function (organizations) {
        if (organizations.length > 0) {
            alert("Abbreviations must be unique but " + newAbbr + " is already in the registry! \nSee organization '" + organizations[0].name + "'");
       }
    } );
}

