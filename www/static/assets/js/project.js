// Called when page is ready for work. Because i'm unable to set an
// onload attribute to the body tag in our UI editor, this function
// checks what the URL's pathname is and executes Javascript based on
// that.
document.addEventListener('DOMContentLoaded', function(event) {
    var url = window.location;

    // If user is not logged in or the login has expired, try to get info about user. (Logins last 23 hr)
    // GetUserInfo will return result['total'] = -1 [not logged in], 0 [not in db], or 1 [in db]
    // (The user_id in our db needs to be the username they log in with via shibboleth!)
    // Saved_user (in localStorage) will be null [not logged in], a username [found in our db], or 
    // "not in db" [logged in but not in our db].
    var saved_user = localStorage.getItem('saved_user');
    var expiration = localStorage.getItem('expiration') || 955381260;
    var now = Date.now();
    var new_expiration = now + (23*3600*1000);
    console.log("ORIG SAVED USER: " + saved_user);
    if (saved_user == null || now > expiration ) {
        getUserInfo( function(result) {
            result_total = result['total'];
            if (result_total == 1) {
                user_id = result['results'][0]['user_id'];
                console.log("Found user - username: " + user_id);
                localStorage.setItem('saved_user', user_id);
                localStorage.setItem('expiration', new_expiration);
                saved_user = user_id;
            } else if (result_total == 0) {
                console.log("Did not find user in db");
                localStorage.setItem('saved_user', 'not in db');
                localStorage.setItem('expiration', new_expiration);
                saved_user = 'not in db';
            } else {
                console.log("Not logged in");
                localStorage.removeItem('saved_user');
                localStorage.removeItem('expiration', new_expiration);
                saved_user = null;
            } 
            console.log("NEW SAVED USER: " + saved_user);
            fixLoginLink(basePath, url);
        });
    }  else {
        // be sure login link is up-to-date
        fixLoginLink(basePath, url);
    }

    // load the variable page contents
    console.log("page url: " + url.href);
    console.log(url.pathname);

    if (url.pathname === basePath || url.pathname === basePath + 'index.html') {
        index();
    } else if (url.pathname === basePath + 'about.html') {
        about();
    } else if (url.pathname === basePath + 'contact.html') {
        contact();
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
    } else if (url.pathname === basePath + 'discipline/new.html') {
        disciplineNew();
    } else if (url.pathname === basePath + 'discipline/edit.html') {
        disciplineEdit();
    } else if (url.pathname === basePath + 'role/new.html') {
        roleNew();
    } else if (url.pathname === basePath + 'role/edit.html') {
        roleEdit();
    } else if (url.pathname === basePath + 'user/new.html') {
        userNew();
    } else if (url.pathname === basePath + 'user/edit.html') {
        userEdit();
    } else {
        console.log('There is no Javascript available for this page.');
    }

});

// Depending on the page, call functions in js/api/* that use api/webservices to get things like organizations, 
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

            var link = document.getElementById('new-resource');
            var href = basePath + 'resource/new.html';
            renderPublicPrivate(link,href);
        });
        getOrganizations(function(organizations) {
            for (var i = 0; i < organizations.length; i++) {
                renderOrganizationListElement(organizations[i]);
            }
            renderOrganizationCount(organizations.length);

            var link = document.getElementById('new-org');
            var href = basePath + 'organization/new.html';
            renderPublicPrivate(link,href);
        });
        getProjects(function(projects) {
            for (var i = 0; i < projects.length; i++) {
                renderMyProjectListElement(projects[i]);
            }
            renderProjectCount(projects.length);

            var link = document.getElementById('new-project');
            var href = basePath + 'project/new.html';
            renderPublicPrivate(link,href);
        });
        getDisciplines(function(disciplines) {
            for (var i = 0; i < disciplines.length; i++) {
                renderDisciplineListElement(disciplines[i]);
            }

            var link = document.getElementById('new-discipline');
            var href = basePath + 'discipline/new.html';
            renderPublicPrivate(link,href);
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

            var link = document.getElementById('new-resource');
            var href = basePath + 'resource/new.html';
            renderPublicPrivate(link,href);
        });
        getOrganizationsLike(query, function(organizations) {
            renderEmptyOrganizationList();
            for (var i = 0; i < organizations.length; i++) {
                renderOrganizationListElement(organizations[i]);
            }
            renderOrganizationCount(organizations.length);

            var link = document.getElementById('new-org');
            var href = basePath + 'organization/new.html';
            renderPublicPrivate(link,href);
        });
        getProjectsLike(query, function(projects) {
            renderEmptyProjectList();
            for (var i = 0; i < projects.length; i++) {
                renderMyProjectListElement(projects[i]);
            }
            renderProjectCount(projects.length);

            var link = document.getElementById('new-project');
            var href = basePath + 'project/new.html';
            renderPublicPrivate(link,href);
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

    // this makes it so that when you reload the home page, it shows the tab you were last on
    // (from stackoverflow)
    $('a[data-toggle="tab"]').click(function (e) {
        e.preventDefault();
        $(this).tab('show');
    });
    
    $('a[data-toggle="tab"]').on("shown.bs.tab", function (e) {
        var id = $(e.target).attr("href");
        localStorage.setItem('selectedTab', id)
    });
    
    var selectedTab = localStorage.getItem('selectedTab');
    if (selectedTab != null) {
        $('a[data-toggle="tab"][href="' + selectedTab + '"]').tab('show');
    }
}

function about() {
    console.log('Loading the about page.');

    onSearchSubmit(function(query) {
        submitSearch(query);
    });
}

function contact() {
    console.log('Loading the contact page.');
    setupContactForm();
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
            renderProjResourceListElement(resources[i]);
        }

        renderMap(resources);
    });

    onSearchSubmit(function(query) {
        submitSearch(query);
    });
}

function projectNew() {
    var saved_user = localStorage.getItem('saved_user');
    if( saved_user == null) {
        window.location.replace(basePath + "login");
    } else {
        console.log('Loading the new project page');
        setupCreateProjectForm();

        onProjAbbrChange(function(newAbbr) {
            checkProjAbbr(newAbbr);
        });
    
        onSearchSubmit(function(query) {
            submitSearch(query);
        });
    }
}

function projectEdit() {
    var saved_user = localStorage.getItem('saved_user');
    if( saved_user == null) {
        window.location.replace(basePath + "login");
    } else {
        console.log('Loading the edit project page');
        var searchParams = new URLSearchParams(window.location.search);
        var id = searchParams.get('project_id');
    
        getProject(id, function(project) {
            setupEditProjectForm(project);
        });
    
        getResourcesByProjectId(id, function(resources) {
            renderMap(resources);
        });

        onProjAbbrChange(function(newAbbr) {
            checkProjAbbr(newAbbr);
        });

        onSearchSubmit(function(query) {
            submitSearch(query);
        });
    }
}

function projectLink() {
    var saved_user = localStorage.getItem('saved_user');
    if( saved_user == null) {
        window.location.replace(basePath + "login");
    } else {
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
    var saved_user = localStorage.getItem('saved_user');
    if( saved_user == null) {
        window.location.replace(basePath + "login");
    } else {
        console.log('Loading the new resource page');

        setupCreateResourceForm();

        onResourceCIDRChange(function(cidr) {
            checkIP(cidr);
            getGeoIP(cidr, renderGeoIPTable_autopop);
            getReverseDNS(cidr, renderReverseDNSTable);
        });
    
        onResAbbrChange(function(newAbbr) {
            checkResAbbr(newAbbr);
        });

        onSearchSubmit(function(query) {
            submitSearch(query);
        });
    }
}

function resourceEdit() {
    var saved_user = localStorage.getItem('saved_user');
    if( saved_user == null) {
        window.location.replace(basePath + "login");
    } else {
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

        onResAbbrChange(function(newAbbr) {
            checkResAbbr(newAbbr);
        });
    
        onSearchSubmit(function(query) {
            submitSearch(query);
        });
    }
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
                renderOrgResourceListElement(resources[i]);
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
    var saved_user = localStorage.getItem('saved_user');
    if( saved_user == null) {
        window.location.replace(basePath + "login");
    } else {
        console.log('Loading the new organization page');
        setupCreateOrganizationForm();

        onOrgAbbrChange(function(newAbbr) {
            checkOrgAbbr(newAbbr);
        });
        onOrgNameChange(function(newName) {
            checkOrgName(newName);
        });
    
        onSearchSubmit(function(query) {
            submitSearch(query);
        });
    }
}

function organizationEdit() {
    var saved_user = localStorage.getItem('saved_user');
    if( saved_user == null) {
        window.location.replace(basePath + "login");
    } else {
        console.log('Loading the edit organization page');
        var searchParams = new URLSearchParams(window.location.search);
        var id = searchParams.get('organization_id');
    
        getOrganization(id, function(org) {
            setupEditOrganizationForm(org);
    
            getResourcesByOrganizationId(id, function(resources) {
                renderMap(resources, [org]);
            });
        });

        onOrgAbbrChange(function(newAbbr) {
            checkOrgAbbr(newAbbr);
        });
        onOrgNameChange(function(newName) {
            checkOrgName(newName);
        });

        onSearchSubmit(function(query) {
            submitSearch(query);
        });
    }
}

function disciplineNew() {
    var saved_user = localStorage.getItem('saved_user');
    if( saved_user == null) {
        window.location.replace(basePath + "login");
    } else {
        console.log('Loading the new discipline page');
        setupCreateDisciplineForm();

        onSearchSubmit(function(query) {
            submitSearch(query);
        });
    }
}

function disciplineEdit() {
    var saved_user = localStorage.getItem('saved_user');
    if( saved_user == null) {
        window.location.replace(basePath + "login");
    } else {
        console.log('Loading the edit discipline page');
        var searchParams = new URLSearchParams(window.location.search);
        var id = searchParams.get('discipline_id');

        getDiscipline(id, function(discipline) {
            setupEditDiscipline(discipline);
        });

        onSearchSubmit(function(query) {
            submitSearch(query);
        });
    }
}

function roleNew() {
    var saved_user = localStorage.getItem('saved_user');
    if( saved_user == null) {
        window.location.replace(basePath + "login");
    } else {
        console.log('Loading the new role page');
        setupCreateRoleForm();

        onSearchSubmit(function(query) {
            submitSearch(query);
        });
    }
}

function roleEdit() {
    var saved_user = localStorage.getItem('saved_user');
    if( saved_user == null) {
        window.location.replace(basePath + "login");
    } else {
        console.log('Loading the edit role page');
        var searchParams = new URLSearchParams(window.location.search);
        var id = searchParams.get('role_id');

        getRole(id, function(role) {
            setupEditRole(role);
        });

        onSearchSubmit(function(query) {
            submitSearch(query);
        });
    }
}

function userNew() {
    var saved_user = localStorage.getItem('saved_user');
    if( saved_user == null) {
        window.location.replace(basePath + "login");
    } else {
        console.log('Loading the new user page');
        setupCreateUserForm();

        onSearchSubmit(function(query) {
            submitSearch(query);
        });
    }
}

function userEdit() {
    var saved_user = localStorage.getItem('saved_user');
    if( saved_user == null) {
        window.location.replace(basePath + "login");
    } else {
        console.log('Loading the edit user page');
        var searchParams = new URLSearchParams(window.location.search);
        var id = searchParams.get('user_id');

        getUser(id, function(user) {
            setupEditUser(user);
        });

        onSearchSubmit(function(query) {
            submitSearch(query);
        });
    }
}
// Hides or shows the passed document element and adds the passed href (if any), depending on the logged-in user.
// 'saved_user' in "localStorage" will be null [not logged in], a username [found in our db],
// or "not in db" [logged in but not in our db].
// FOR NOW, ANY LOGGED IN USER CAN ADD AND EDIT
function renderPublicPrivate(item, url) {
    var saved_user = localStorage.getItem('saved_user');
    if (saved_user != null) {
      if (url) item.href = url; 
      item.style.visibility = "visible";
    } else {
      item.href = "";
      item.style.visibility = "hidden";
    }
}

// Fix Login link depending on whether user is logged in. Also makes the url work correctly.
function fixLoginLink(basePath, url) {
    var saved_user = localStorage.getItem('saved_user');
    var login_link = document.getElementById("login_link");
    if (saved_user) {
        login_link.innerHTML = "You are logged in";
        login_link.href = url;
    } else {
        login_link.innerHTML = "Login";
        login_link.href = basePath + "login";
    }
}

