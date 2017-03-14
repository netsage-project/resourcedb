// GlobalNOC 2017


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

// Called when enter is pressed and search_form is in focus.
function onResourceSearchSubmit(onSubmit) {
    var search = document.getElementById('search_form');

    search.addEventListener('submit', function(e) {
        // First element of the form is search_field
        onSubmit(e.target[0].value);
        e.preventDefault();
    }, false);
}
