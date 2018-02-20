
// Called when page is ready for work. Because i'm unable to set an
// onload attribute to the body tag in our UI editor, this function
// checks what the URL's pathname is and executes Javascript based on
// that.
document.addEventListener('DOMContentLoaded', function(event) {
    var url = window.location;

    // first get info about the logged-in user. Adds them to the db if they are not in it.
    getUserInfo(function(info) {
        console.log("Getting user info");
        console.log("username = " + info['user_id']);
        //for(key in info) {
        //    console.log(key + " " + info[key]);    
        //}
    });

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
    } else if (url.pathname === basePath + 'project/link.html') {
        projectLink();
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

// Below, call functions in js/api/* that use api/webservices to get things like organizations, 
// then on success, run the anonymous function() on the results,
// eg, getOrganizations(function to run on success) uses api/index.cgi?method=get_organizations.

var index = function() {
    console.log('Loading the index page.');
    var searchParams = new URLSearchParams(window.location.search);
    var query = searchParams.get('search');

    if (query === null || query === '') {
        // Normal full lists:
        getResources(function(resources) {
            for (var i = 0; i < resources.length; i++) {
                renderResourceListElement(resources[i]);
            }
            renderResourceCount(resources.length);
        });
        getOrganizations(function(organizations) {
            for (var i = 0; i < organizations.length; i++) {
                renderOrganizationListElement(organizations[i]);
            }
            renderOrganizationCount(organizations.length);
        });
        getProjects(function(projects) {
            for (var i = 0; i < projects.length; i++) {
                renderMyProjectListElement(projects[i]);
            }
            renderProjectCount(projects.length);
        });
    } 
    else {
        // If a search query is in the url (search was entered when on another page):
        document.getElementById("search_field").value = query;
        getResourcesLike(query, function(resources) {
            for (var i = 0; i < resources.length; i++) {
                renderResourceListElement(resources[i]);
            }
            renderResourceCount(resources.length);
        });
        getOrganizationsLike(query, function(organizations) {
            renderEmptyOrganizationList();
            for (var i = 0; i < organizations.length; i++) {
                renderOrganizationListElement(organizations[i]);
            }
            renderOrganizationCount(organizations.length);
        });
        getProjectsLike(query, function(projects) {
            renderEmptyProjectList();
            for (var i = 0; i < projects.length; i++) {
                renderMyProjectListElement(projects[i]);
            }
            renderProjectCount(projects.length);
        });
    }

    // When a search string is entered/removed on the index page:
    var delayTimer;

    onSearchKeyUp(function(input) {
      // Doing all 3 gets after each letter is too slow. 
      // Add a delay so gets don't start until there is a pause in typing.
      clearTimeout(delayTimer);
      delayTimer = setTimeout(function() {

        if (input === null || input === '') {
            getResources(function(resources) {
                renderEmptyResourceList();
                for (var i = 0; i < resources.length; i++) {
                    renderResourceListElement(resources[i]);
                }
                renderResourceCount(resources.length);
            });
            getOrganizations(function(organizations) {
                renderEmptyOrganizationList();
                for (var i = 0; i < organizations.length; i++) {
                    renderOrganizationListElement(organizations[i]);
                }
                renderOrganizationCount(organizations.length);
            });
            getProjects(function(projects) {
                renderEmptyProjectList();
                for (var i = 0; i < projects.length; i++) {
                    renderMyProjectListElement(projects[i]);
                }
                renderProjectCount(projects.length);
            });
        } 
        else {
            getResourcesLike(input, function(resources) {
                renderEmptyResourceList();
                for (var i = 0; i < resources.length; i++) {
                    renderResourceListElement(resources[i]);
                }
                renderResourceCount(resources.length);
            });
            getOrganizationsLike(input, function(organizations) {
                renderEmptyOrganizationList();
                for (var i = 0; i < organizations.length; i++) {
                    renderOrganizationListElement(organizations[i]);
                }
                renderOrganizationCount(organizations.length);
            });
            getProjectsLike(input, function(projects) {
                renderEmptyProjectList();
                for (var i = 0; i < projects.length; i++) {
                    renderMyProjectListElement(projects[i]);
                }
                renderProjectCount(projects.length);
            });
        }

      }, 500); // wait for .5 sec after typing a letter 
    });
}

function about() {
    console.log('Loading the about page.');

    onSearchSubmit(function(query) {
        submitSearch(query);
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

    getProjectEvents(id, function(events) {
        events.map(renderProjectEventListElement);
    });

    getResourcesByProjectId(id, function(resources) {
        for (var i = 0; i < resources.length; i++) {
            renderResourceListElement(resources[i]);
        }

        renderMap(resources);
    });

    onSearchSubmit(function(query) {
        submitSearch(query);
    });
}

function projectNew() {
    console.log('Loading the new project page');
    setupCreateProjectForm();

    onSearchSubmit(function(query) {
        submitSearch(query);
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

    onSearchSubmit(function(query) {
        submitSearch(query);
    });
}

function projectLink() {
    console.log('Loading the link project page');

    var searchParams = new URLSearchParams(window.location.search);
    var id = searchParams.get('project_id');

    getProject(id, function(project) {
        renderProjectHeader(project);
        setupProjectLinkResourceForm(project);
    });

    getResources(function(resources) {
        for (var i = 0; i < resources.length; i++) {
            renderResourceListSelectableElement(resources[i]);
        }
    });

    getResourcesByProjectId(id, function(resources) {
        for (var i = 0; i < resources.length; i++) {
            addResourceListSelectableElement(resources[i]);
        }
    });

    onProjectLinkResourceSearchKeyUp(function(input) {
        if (input === null || input === '') {
            getResources(function(resources) {
                renderEmptyResourceList();
                for (var i = 0; i < resources.length; i++) {
                    renderResourceListSelectableElement(resources[i]);
                }
            });
        } else {
            getResourcesLike(input, function(resources) {
                renderEmptyResourceList();
                for (var i = 0; i < resources.length; i++) {
                    renderResourceListSelectableElement(resources[i]);
                }
            });
        }
    });

    onSearchSubmit(function(query) {
        submitSearch(query);
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
        getReverseDNS(resource.addr_str, function(revdns) {
            renderReverseDNSTable(revdns);
        });

        getProjectsByResourceID(id, function(projects) {
            console.log(projects);
            for (var i = 0; i < projects.length; i++) {
                renderLinkedProjectListElement(projects[i]);
            }
        });

        getResourceEvents(id, function(events) {
            events.map(renderResourceEventListElement);
        });
    });

    onSearchSubmit(function(query) {
        submitSearch(query);
    });
}

function resourceNew() {
    console.log('Loading the new resource page');

    setupCreateResourceForm();

    onResourceCIDRChange(function(cidr) {
        checkIP(cidr);
        getGeoIP(cidr, renderGeoIPTable_autopop);
        getReverseDNS(cidr, renderReverseDNSTable);
    });

    onSearchSubmit(function(query) {
        submitSearch(query);
    });
}

function resourceEdit() {
    console.log('Loading the edit resource page');
    var searchParams = new URLSearchParams(window.location.search);
    var id = searchParams.get('resource_id');

    getResource(id, function(resource) {
        setupEditResourceForm(resource);

        getGeoIP(resource.addr_str, renderGeoIPTable);
        getReverseDNS(resource.addr_str, renderReverseDNSTable);
        renderMap([resource]);
    });

    onResourceCIDRChange(function(cidr) {
        getGeoIP(cidr, renderGeoIPTable);
        getReverseDNS(cidr, renderReverseDNSTable);
    });

    onSearchSubmit(function(query) {
        submitSearch(query);
    });
}

function organization() {
    var searchParams = new URLSearchParams(window.location.search);
    var id = searchParams.get('organization_id')

    console.log('Loading the resource page for organization ' + id.toString());
    getOrganization(id, function(org) {
        renderOrganizationHeader(org);
        renderOrganizationRecord(org);

        // put this here to be sure org exists before calling renderMap, in case getting org takes too long.
        getResourcesByOrganizationId(id, function(resources) {
            for (var i = 0; i < resources.length; i++) {
                renderResourceListElement(resources[i]);
            }
            renderMap(resources,[org]);
        });
    });

    getOrganizationEvents(id, function(events) {
        events.map(renderOrganizationEventListElement);
    });

    onSearchSubmit(function(query) {
        submitSearch(query);
    });
}

function organizationNew() {
    console.log('Loading the new organization page');
    setupCreateOrganizationForm();

    onAbbrChange(function(newAbbr) {
        checkAbbr(newAbbr);
    });

    onSearchSubmit(function(query) {
        submitSearch(query);
    });
}

function organizationEdit() {
    console.log('Loading the edit organization page');
    var searchParams = new URLSearchParams(window.location.search);
    var id = searchParams.get('organization_id');

    getOrganization(id, function(org) {
        setupEditOrganizationForm(org);

        getResourcesByOrganizationId(id, function(resources) {
            renderMap(resources, [org]);
        });
    });

    onAbbrChange(function(newAbbr) {
        checkAbbr(newAbbr);
    });

    onSearchSubmit(function(query) {
        submitSearch(query);
    });
}
