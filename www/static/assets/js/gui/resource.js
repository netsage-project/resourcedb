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

var countries = ["Afghanistan", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Anguilla", "Antarctica", "Antigua and Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bermuda", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Bouvet Island", "Brazil", "British Indian Ocean Territory", "Brunei Darussalam", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Canada", "Cape Verde", "Cayman Islands", "Central African Republic", "Chad", "Chile", "China", "Christmas Island", "Cocos (Keeling) Islands", "Colombia", "Comoros", "Congo", "Congo", "The Democratic Republic of The", "Cook Islands", "Costa Rica", "Cote D\xe2\x80\x99ivoire", "Croatia", "Cuba", "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Falkland Islands (Malvinas)", "Faroe Islands", "Fiji", "Finland", "France", "French Guiana", "French Polynesia", "French Southern Territories", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Gibraltar", "Greece", "Greenland", "Grenada", "Guadeloupe", "Guam", "Guatemala", "Guinea", "Guinea-bissau", "Guyana", "Haiti", "Heard Island and Mcdonald Islands", "Holy See (Vatican City State)", "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Islamic Republic of", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Korea", "Democratic People\xe2\x80\x99s Republic of", "Korea", "Republic of", "Kuwait", "Kyrgyzstan", "Lao People\xe2\x80\x99s Democratic Republic", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libyan Arab Jamahiriya", "Liechtenstein", "Lithuania", "Luxembourg", "Macao", "Macedonia", "The Former Yugoslav Republic of", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Martinique", "Mauritania", "Mauritius", "Mayotte", "Mexico", "Micronesia", "Federated States of", "Moldova", "Republic of", "Monaco", "Mongolia", "Montserrat", "Morocco", "Mozambique", "Myanmar", "Namibia", "Nauru", "Nepal", "Netherlands", "Netherlands Antilles", "New Caledonia", "New Zealand", "Nicaragua", "Niger", "Nigeria", "Niue", "Norfolk Island", "Northern Mariana Islands", "Norway", "Oman", "Pakistan", "Palau", "Palestinian Territory", "Occupied", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Pitcairn", "Poland", "Portugal", "Puerto Rico", "Qatar", "Reunion", "Romania", "Russian Federation", "Rwanda", "Saint Helena", "Saint Kitts and Nevis", "Saint Lucia", "Saint Pierre and Miquelon", "Saint Vincent and The Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia and Montenegro", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Georgia and The South Sandwich Islands", "Spain", "Sri Lanka", "Sudan", "Suriname", "Svalbard and Jan Mayen", "Swaziland", "Sweden", "Switzerland", "Syrian Arab Republic", "Taiwan", "Province of China", "Tajikistan", "Tanzania", "United Republic of", "Thailand", "Timor-leste", "Togo", "Tokelau", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Turks and Caicos Islands", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "United States Minor Outlying Islands", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela", "Viet Nam", "Virgin Islands", "British", "Virgin Islands", "U.S.", "Wallis and Futuna", "Western Sahara", "Yemen", "Zambia", "Zimbabwe"];

// Sets up submitCreateResource to be called when the create button on
// resource/new.html is pressed.
function setupCreateResourceForm() {
    var id = document.getElementById('resource_id');
    id.value = -1;

    var submit = document.getElementById('create_resource_submit');
    submit.onclick = submitCreateOrUpdateResource;

    var country = document.getElementById('resource_country');
    for (var i = 0; i < countries.length; i++) {
        var opt = document.createElement('option');

        opt.innerHTML = countries[i];
        opt.setAttribute('value', countries[i]);
        country.appendChild(opt);
    }
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
    for (var i = 0; i < countries.length; i++) {
        var opt = document.createElement('option');

        opt.innerHTML = countries[i];
        opt.setAttribute('value', countries[i]);
        country.appendChild(opt);
    }

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
