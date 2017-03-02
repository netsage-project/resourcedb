
// Called when page is ready for work. Because i'm unable to set an
// onload attribute to the body tag in our UI editor, this function
// checks what the URL's pathname is and executes Javascript based on
// that.
document.addEventListener('DOMContentLoaded', function(event) {
    var url = window.location;

    console.log(url.pathname);

    if (url.pathname === baseUrl || url.pathname === baseUrl + 'index.html') {
        index();
    } else if (url.pathname === baseUrl + 'project/index.html') {
        project();
    } else if (url.pathname === baseUrl + 'resource/index.html') {
        resource();
    } else {
        console.log('There is no Javascript available for this page.');
    }

});

var index = function() {
    console.log('Loading the index page.');

    get_resources(function(resources) {
        for (var i = 0; i < resources.length; i++) {
            render_my_resource(resources[i]);
        }
    });

    get_projects(function(projects) {
        for (var i = 0; i < projects.length; i++) {
            render_my_project(projects[i]);
        }
    });
}

var project = function() {
    console.log('Loading the project page.');
}

var resource = function() {
    console.log('Loading the resource page.');
}
