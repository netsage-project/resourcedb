
function setupContactForm() {
    // Sets up Contact Form 

    var form = document.getElementById('contact_form');
    // function to call when submit is clicked
    form.onsubmit = submitContactForm;

    // fill in role and discipline selectors
    getRoles(function(roles) {
        var role = document.getElementById('role_select');
        role.innerHTML = "";
        for (var i = 0; i < roles.length; i++) {
            var opt = document.createElement('option');
            opt.innerHTML = roles[i].name;
            opt.setAttribute('value', roles[i].role_id);
            if (roles[i].name == "Unknown") {
                opt.setAttribute('selected', '');
            }
            role.appendChild(opt);
        }
    });
    getDisciplines(function(disciplines) {
        var discipline = document.getElementById('discipline_select');
        discipline.innerHTML = "";
        for (var i = 0; i < disciplines.length; i++) {
            var opt = document.createElement('option');
            opt.innerHTML = disciplines[i].name;
            opt.setAttribute('value', disciplines[i].discipline_id);
            if (disciplines[i].name == "Unknown") {
                opt.setAttribute('selected', '');
            }
            discipline.appendChild(opt);
         }
    });
 
    // change Back link to go to previous page
    var backLink = document.getElementById('contact_back');
    backLink.href = 'javascript:history.go(-1)';

}

// Gathers values from contact_form when the submit button is pressed. 
// Passes the collected values to sendContactEmail() after parameters are validated.
function submitContactForm(e) {
    e.preventDefault();

    var form = document.getElementById('contact_form');

    // get input values by name (not id)
    var name = form.elements['contact_name'].value;
    var org = form.elements['contact_org'].value;
    var email = form.elements['contact_email'].value;
    var phone = form.elements['contact_phone'].value;
    var msg = form.elements['contact_message'].value;

    console.log('calling sendContactEmail');
    sendContactEmail(name, org, email, phone, msg);
}
