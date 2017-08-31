
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
    } else if (url.pathname === basePath + 'about.html') {
        about();
    } else if (url.pathname === basePath + 'project/index.html') {
        project();
    } else if (url.pathname === basePath + 'project/new.html') {
        projectNew();
    } else if (url.pathname === basePath + 'project/edit.html') {
        projectEdit();
    } else if (url.pathname === basePath + 'resource/index.html') {
        resource();
    } else if (url.pathname === basePath + 'resource/new.html') {
        resourceNew();
    } else if (url.pathname === basePath + 'resource/edit.html') {
        resourceEdit();
    } else if (url.pathname === basePath + 'organization/index.html') {
        organization();
    } else if (url.pathname === basePath + 'organization/new.html') {
        organizationNew();
    } else if (url.pathname === basePath + 'organization/edit.html') {
        organizationEdit();
    } else {
        console.log('There is no Javascript available for this page.');
    }

});

var index = function() {
    console.log('Loading the index page.');
    var searchParams = new URLSearchParams(window.location.search);
    var query = searchParams.get('search');

    if (query === null || query === '') {
        getResources(function(resources) {
            for (var i = 0; i < resources.length; i++) {
                renderResourceListElement(resources[i]);
            }
            renderResourceCount(resources.length);
        });
    } else {
        getResourcesLike(query, function(resources) {
            for (var i = 0; i < resources.length; i++) {
                renderResourceListElement(resources[i]);
            }
            renderResourceCount(resources.length);
        });
    }

    getOrganizations(function(orgs) {
        for (var i = 0; i < orgs.length; i++) {
            renderMyOrganizationListElement(orgs[i]);
        }
     });

    getProjects(function(projects) {
        for (var i = 0; i < projects.length; i++) {
            renderMyProjectListElement(projects[i]);
        }
    });

    onResourceSearchKeyUp(function(input) {
        if (input === null || input === '') {
            getResources(function(resources) {
                renderEmptyResourceList();

                for (var i = 0; i < resources.length; i++) {
                    renderResourceListElement(resources[i]);
                }
                renderResourceCount(resources.length);
            });
        } else {
            getResourcesLike(input, function(resources) {
                renderEmptyResourceList();

                for (var i = 0; i < resources.length; i++) {
                    renderResourceListElement(resources[i]);
                }
                renderResourceCount(resources.length);
            });
        }
    });
}

function about() {
    console.log('Loading the about page.');

    onResourceSearchSubmit(function(query) {
        submitResourceSearch(query);
    });
}

function project() {
    var searchParams = new URLSearchParams(window.location.search);
    var id = searchParams.get('project_id')

    console.log('Loading the project page for project ' + id.toString());
    getProject(id, function(project) {
        renderProjectHeader(project);
        renderProjectRecord(project);
    });

    getResourcesByProjectId(id, function(resources) {
        for (var i = 0; i < resources.length; i++) {
            renderResourceListElement(resources[i]);
        }

        renderMap(resources);
    });

    onResourceSearchSubmit(function(query) {
        submitResourceSearch(query);
    });
}

function projectNew() {
    console.log('Loading the new project page');
    setupCreateProjectForm();

    onResourceSearchSubmit(function(query) {
        submitResourceSearch(query);
    });
}

function projectEdit() {
    console.log('Loading the edit project page');
    var searchParams = new URLSearchParams(window.location.search);
    var id = searchParams.get('project_id');

    getProject(id, function(project) {
        setupEditProjectForm(project);
    });

    getResourcesByProjectId(id, function(resources) {
        renderMap(resources);
    });

    onResourceSearchSubmit(function(query) {
        submitResourceSearch(query);
    });
}

function resource() {
    var searchParams = new URLSearchParams(window.location.search);
    var id = searchParams.get('resource_id')

    console.log('Loading the resource page for resource ' + id.toString());
    getResource(id, function(resource) {
        renderResourceHeader(resource);
        renderResourceRecord(resource);

        renderMap([resource]);

        getGeoIP(resource.addr_str, function(geoip) {
            renderGeoIPTable(geoip);
        });

        getProjectsByResourceID(id, function(projects) {
            for (var i = 0; i < projects.length; i++) {
                renderLinkedProjectListElement(projects[i]);
            }
        });

        if (resource.organization_id != null) {
            getOrganization(resource.organization_id, function(org) {
                renderLinkedOrganizationListElement(org);
            });
        }
    });

    onResourceSearchSubmit(function(query) {
        submitResourceSearch(query);
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

    onResourceCIDRChange(function(cidr) {
        getGeoIP(cidr, renderGeoIPTable);
    });

    onResourceSearchSubmit(function(query) {
        submitResourceSearch(query);
    });
}

function resourceEdit() {
    console.log('Loading the edit resource page');
    var searchParams = new URLSearchParams(window.location.search);
    var id = searchParams.get('resource_id');

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

    getResource(id, function(resource) {
        setupEditResourceForm(resource);
        getGeoIP(resource.addr_str, renderGeoIPTable);

        renderMap([resource]);
    });

    onResourceCIDRChange(function(cidr) {
        getGeoIP(cidr, renderGeoIPTable);
    });

    onResourceSearchSubmit(function(query) {
        submitResourceSearch(query);
    });
}

function organization() {
    var searchParams = new URLSearchParams(window.location.search);
    var id = searchParams.get('organization_id')

    console.log('Loading the resource page for organization ' + id.toString());
    getOrganization(id, function(org) {
        renderOrganizationHeader(org);
        renderOrganizationRecord(org);
    });

    getResourcesByOrganizationId(id, function(resources) {
        for (var i = 0; i < resources.length; i++) {
            renderResourceListElement(resources[i]);
        }

        renderMap(resources);
    });

    onResourceSearchSubmit(function(query) {
        submitResourceSearch(query);
    });
}

function organizationNew() {
    console.log('Loading the new organization page');
    setupCreateOrganizationForm();

    onResourceSearchSubmit(function(query) {
        submitResourceSearch(query);
    });
}

function organizationEdit() {
    console.log('Loading the edit organization page');
    var searchParams = new URLSearchParams(window.location.search);
    var id = searchParams.get('organization_id');

    getOrganization(id, function(org) {
        setupEditOrganizationForm(org);
    });

    getResourcesByOrganizationId(id, function(resources) {
        renderMap(resources);
    });

    onResourceSearchSubmit(function(query) {
        submitResourceSearch(query);
    });
}
