
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
    } else if (url.pathname === basePath + 'resource/new.html') {
        resourceNew();
    } else if (url.pathname === basePath + 'organization/index.html') {
        organization();
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
    getProject(id, function(project) {
        renderProjectHeader(project);
    });

    getResourcesByProjectId(id, function(resources) {
        for (var i = 0; i < resources.length; i++) {
            renderResourceListElement(resources[i]);
        }
    });
}

function resource() {
    var searchParams = new URLSearchParams(window.location.search);
    var id = searchParams.get('resource_id')

    console.log('Loading the resource page for resource ' + id.toString());
    getResource(id, function(resource) {
        renderResourceHeader(resource);
        renderResourceRecord(resource);

        getProject(resource.project_id, function(project) {
            renderLinkedProjectListElement(project);
        });

        getOrganization(resource.organization_id, function(org) {
            renderLinkedOrganizationListElement(org);
        });
    });
}

function resourceNew() {
    console.log('Loading the new resource page');
    getOrganizations(function(orgs) {
        for (var i = 0; i < orgs.length; i++) {
            renderCreateResourceFormOrganizationOption(orgs[i]);
        }
    });

    getProjects(function(projects) {
        for (var i = 0; i < projects.length; i++) {
            renderCreateResourceFormProjectOption(projects[i]);
        }
    });

    setupCreateResourceForm();
}

function organization() {
    var searchParams = new URLSearchParams(window.location.search);
    var id = searchParams.get('organization_id')

    console.log('Loading the resource page for organization ' + id.toString());
    console.log('Loading the resource page for resource ' + id.toString());
    getOrganization(id, function(org) {
        console.log(org);

        renderOrganizationHeader(org);
    });

    getResourcesByOrganizationId(id, function(orgs) {
        for (var i = 0; i < orgs.length; i++) {
            renderResourceListElement(orgs[i]);
        }
    });
}
