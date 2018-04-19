// GlobalNOC 2017

// Renders an discipline in the main list (id=discipline_list) on the homepage
// On row click, go to edit-discipline page.
function renderDisciplineListElement(discipline) {
    var table = document.getElementById('discipline_list');
    var row   = table.insertRow(-1);

    var id = discipline.discipline_id.toString();

    var name = row.insertCell(0);
    var description = row.insertCell(1);

    name.innerHTML = discipline.name;
    description.innerHTML = discipline.description;

    row.addEventListener('click', function(e) {
        window.location.href = basePath + 'discipline/edit.html?discipline_id=' + id;
    });
}

// Renders events as list items under discipline_event_list on
// discipline/edit.html
function renderDisciplineEventListElement(event) {
    var eventText = document.createElement('span');
    eventText.innerHTML = '<b>' + event.date + '</b> - ' + event.message;

    var entry = document.createElement('li');
    entry.setAttribute('class', 'list-group-item');
    entry.appendChild(eventText);

    var listGroup = document.getElementById('discipline_event_list');
    listGroup.appendChild(entry);
}

// Empty discipline_list
function renderEmptyDisciplineList() {
    document.getElementById('discipline_list').innerHTML = '';
}

// Sets up what buttons do on the new discipline page
function setupCreateDisciplineForm() {
    console.log('setupCreateDisciplineForm');

    var form = document.getElementById('create_discipline_form');
    form.onsubmit = submitCreateOrUpdateDiscipline;

    var cancel = document.getElementById('cancel_discipline_submit');
    cancel.onclick = function() {
        window.location.href = basePath + 'index.html';
    };
}

// Sets up form values and what buttons do on the edit discipline page
function setupEditDisciplineForm(discipline) {
    document.getElementById('discipline_id').value = discipline.discipline_id;
    document.getElementById('discipline_name').value = discipline.name;
    document.getElementById('discipline_description').value = discipline.description;

    var form = document.getElementById('create_discipline_form');
    form.onsubmit = submitCreateOrUpdateDiscipline;

    var del = document.getElementById('delete_discipline_submit');
    del.onclick = function(e) {
        deleteDiscipline(discipline.discipline_id);
    };

    var cancel = document.getElementById('cancel_discipline_submit');
    cancel.onclick = function() {
        window.location.href = basePath + 'index.html';
    };
}

// Gathers values from form on new.html or edit.html when
// the submit button is pressed. Passes the collected values to
// createOrEditDiscipline after parameters are validated.
function submitCreateOrUpdateDiscipline(e) {
    e.preventDefault();

    var form = document.getElementById('create_discipline_form');
    console.log('submitCreateDiscipline');

    var name = form.elements['discipline_name'].value;
    var desc = form.elements['discipline_description'].value;
    if (desc) { desc = desc.replace(/[\u2018\u2019]/g, "'"); } // replace smart quotes
    if (desc) { desc = desc.replace(/[\u201C\u201D]/g, '"'); } // replace smart quotes

    // Hidden field discipline_id
    var id = parseInt(form.elements['discipline_id'].value);

    if (id === -1) {
        console.log('Creating a new discipline');
        createOrEditDiscipline(null, name, desc);
    } else {
        console.log('Editing discipline ' + id.toString());
        createOrEditDiscipline(id, name, desc);
    }
}

