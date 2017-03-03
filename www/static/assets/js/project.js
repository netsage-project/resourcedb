
// Called when page is ready for work. Because i'm unable to set an
// onload attribute to the body tag in our UI editor, this function
// checks what the URL's pathname is and executes Javascript based on
// that.
document.addEventListener('DOMContentLoaded', function(event) {
    var url = window.location;

    console.log(url.href);
    console.log(url.pathname);

    if (url.pathname === basePath || url.pathname === basePath + 'index.html') {
        index();
    } else if (url.pathname === basePath + 'project/index.html') {
        project();
    } else if (url.pathname === basePath + 'resource/index.html') {
        resource();
    } else {
        console.log('There is no Javascript available for this page.');
    }

});

var index = function() {
    console.log('Loading the index page.');

    getResources(function(resources) {
        for (var i = 0; i < resources.length; i++) {
            renderMyResourceListElement(resources[i]);
            renderResourceListElement(resources[i]);
        }

        renderResourceCount(resources.length);
    });

    getProjects(function(projects) {
        for (var i = 0; i < projects.length; i++) {
            renderMyProjectListElement(projects[i]);
        }
    });
}

function project() {
    var searchParams = new URLSearchParams(window.location.search);
    var id = searchParams.get('project_id')

    console.log('Loading the project page for project ' + id.toString());
}

function resource() {
    var searchParams = new URLSearchParams(window.location.search);
    var id = searchParams.get('resource_id')

    console.log('Loading the resource page for resource ' + id.toString());
    getResource(id, function(resource) {
        console.log(resource);
        renderResourceHeader(resource);
        renderResourceRecord(resource);
    });
}
