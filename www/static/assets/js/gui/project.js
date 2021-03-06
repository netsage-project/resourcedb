// GlobalNOC 2017

// Renders a project in the main list (id=my_project_list) on the homepage
function renderMyProjectListElement(project) {
    var table = document.getElementById('my_project_list');
    var row   = table.insertRow(-1);

    var id = project.project_id.toString();

    var abbr = row.insertCell(0);
    var name = row.insertCell(1);

    abbr.innerHTML = project.abbr;
    name.innerHTML = project.name;

    row.addEventListener('click', function(e) {
        window.location.href = basePath + 'project/index.html?project_id=' + id;
    });
}

// Renders a project in linked_project_list on resource details page
function renderLinkedProjectListElement(project) {
    var table = document.getElementById('project_list');
    var row   = table.insertRow(-1);

    var id = project.project_id.toString();

    var name = row.insertCell(0);
    name.innerHTML = project.name;

    var desc = row.insertCell(1);
    desc.innerHTML = project.description;

    row.setAttribute("role", "button");
    row.addEventListener('click', function(e) {
        window.location.href = basePath + 'project/index.html?project_id=' + id;
    });
}

// Renders events as list items under project_event_list on project details page
function renderProjectEventListElement(event) {
    var eventText = document.createElement('span');
    eventText.innerHTML = '<b>' + event.date + '</b> - ' + event.message;

    var entry = document.createElement('li');
    entry.setAttribute('class', 'list-group-item');
    entry.appendChild(eventText);

    var listGroup = document.getElementById('project_event_list');
    listGroup.appendChild(entry);
}

// Given a project record, set the innerHTML of the elements
// identified by project_name and project_description.
function renderProjectHeader(project) {
    var name = document.getElementById('project_name');
    var desc = document.getElementById('project_description');

    name.innerHTML = project.name;
    desc.innerHTML = project.description;
}

// Project Details Page - 
// Given a project record, set the innerHTML of the elements
function renderProjectRecord(project) {

  // Show an active "edit" icon for logged-in users only
  var link = document.getElementById('project_edit_link');
  var href = basePath + 'project/edit.html?project_id=' + project.project_id.toString();
  renderPublicPrivate(link, href);
  // Show Edit Resources link for logged-in users only
  var edit_res_link = document.getElementById('project_edit_resources');
  var edit_res_href = basePath + 'project/link.html?project_id=' + project.project_id.toString();
  renderPublicPrivate(edit_res_link, edit_res_href);

  if (project.url != null) {
    var url = document.createElement('a');
    url.setAttribute('target', '_blank');
    url.setAttribute('href', project.url);
    url.innerText = project.url;
    document.getElementById('project_url').appendChild(url);
  }

  document.getElementById('project_abbr').innerHTML = project.abbr;
  document.getElementById('project_owner').innerHTML = project.owner;
  document.getElementById('project_email').innerHTML = project.email;
  if (project.notes) { document.getElementById('project_notes').innerHTML = project.notes.replace(/ @@ /g,"<br>"); } // new-lines are @@ in db.

}

// Empty my_project_list
function renderEmptyProjectList() {
    document.getElementById('my_project_list').innerHTML = '';
}

// Renders the number of projects  project_list should contain.
function renderProjectCount(count) {
    var text = document.getElementById('project_list_count');

    text.innerHTML = count.toString() + ' records found';
}

// Sets up submitCreateProject to be called when the create button on
// project/new.html is pressed.
function setupCreateProjectForm() {
    var form = document.getElementById('create_project_form');
    form.onsubmit = submitCreateOrUpdateProject;

    var cancel = document.getElementById('cancel_project_submit');
    cancel.onclick = function() {
        window.location.href = basePath + 'index.html';
    };
}

function setupProjectLinkResourceForm(project) {
    var link = document.getElementById('link_project');
    var cancel = document.getElementById('cancel_link_project');

    link.onclick = function() {
        var table = document.getElementById('selected_resource_list');
        var resourceIDs = [];

        for (var i = 0; i < table.rows.length; i++) {
            var id = table.rows[i].getAttribute('data-id');
            resourceIDs.push(id);
        }

        setProjectResourceLinks(project.project_id, resourceIDs);
    };

    cancel.onclick = function() {
        window.location.href = basePath + 'project/index.html?project_id=' + project.project_id.toString();
    };
}

// Gathers values from create_project_form on project/new.html when
// the create button is pressed. Passes the collected values to
// createProject after parameters are validated.
function submitCreateOrUpdateProject(e) {
    e.preventDefault();

    var form = document.getElementById('create_project_form');
    console.log('submitCreateProject');
    console.log(form.elements);

    var name = form.elements['project_name'].value;
    var abbr = form.elements['project_abbr'].value;

    var desc = form.elements['project_description'].value;
    if (desc) { desc = replace_special_chars(desc); } // replace smart quotes, etc.

    var owner = form.elements['project_owner'].value;
    var email = form.elements['project_email'].value;

    var notes = form.elements['project_notes'].value;
    if (notes) { notes = notes.replace(/\n/g," @@ "); }  // encode new-lines as @@ in the db
    if (notes) { notes = replace_special_chars(notes); } // replace smart quotes, etc.

    var projUrl = form.elements['project_url'].value;

    // Hidden field project_id
    var project_id = parseInt(form.elements['project_id'].value);
    if (project_id === -1) {
        console.log('Creating a new project');
        createOrEditProject(null, name, abbr, desc, owner, email, projUrl, notes);
    } else {
        console.log('Editing project ' + project_id.toString());
        createOrEditProject(project_id, name, abbr, desc, owner, email, projUrl, notes);
    }
}

// Sets up submitEditProject to be called when a button on
// project/edit.html is pressed.
function setupEditProjectForm(project) {
    var id = document.getElementById('project_id');
    var name = document.getElementById('project_name');
    var abbr = document.getElementById('project_abbr');
    var desc = document.getElementById('project_description');
    var owner = document.getElementById('project_owner');
    var email = document.getElementById('project_email');
    var url = document.getElementById('project_url');
    var notes = document.getElementById('project_notes');

    id.value = project.project_id;
    name.value = project.name;
    abbr.value = project.abbr;
    desc.value = project.description;
    owner.value = project.owner;
    email.value = project.email;
    url.value = project.url;
    if (project.notes) { notes.value = project.notes.replace(/ @@ /g, "\n"); } // new-lines are @@ in the db

    var form = document.getElementById('create_project_form');
    form.onsubmit = submitCreateOrUpdateProject;

    var del = document.getElementById('delete_project_submit');
    del.onclick = function(e) {
        deleteProject(project.project_id);
    };

    var cancel = document.getElementById('cancel_project_submit');
    cancel.onclick = function() {
        window.location.href = basePath + 'project/index.html?project_id=' + project.project_id;
    };
}

// Calls onChange and passes the updated value of abbr as the
// first argument.
function onProjAbbrChange(onChange) {
    var abbr = document.getElementById('project_abbr');
    abbr.addEventListener('change', function(e) {
        onChange(e.target.value);
    });
}

// Checks to see if an Abbr is already in the db and warns the user
function checkProjAbbr(newAbbr) {
    getProjectsWithAbbr(newAbbr, function (projects) {
        if (projects.length > 0) {
            alert("Abbreviations must be unique but " + newAbbr + " is already in the registry! \nSee project '" + projects[0].name + "'");
       }
    } );
}
