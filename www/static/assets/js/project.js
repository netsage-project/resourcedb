// Global info about the person viewing the user interface
// Will be updated on each page load
  var viewer = { loggedin:  "false",
                 adminuser: "false",
                 username:  null,
                 userid:    null 
               };

// Called when page is ready for work. Because i'm unable to set an
// onload attribute to the body tag in our UI editor, this function
// checks what the URL's pathname is and executes Javascript based on
// that.
document.addEventListener('DOMContentLoaded', function(event) {

  var url = window.location;

  // Do a webservice call to get info about the viewer - most importantly,
  // whether they are logged in via shibboleth and whether they are also in our database (admin user);
  // Then load the page.
  getViewerInfo( function(result) {

    viewer = result['results'][0];
    console.log("viewer:"); console.log(viewer);
        
    // fix Login link in the header
    fixLoginLink(basePath, url);
 
    // load the page content depending on the url
    var page = url.pathname;
        page = page.replace('//','/');
    if (page === basePath || page === basePath + 'index.html') {
        index();
    } else if (page === basePath + 'about.html') {
        about();
    } else if (page === basePath + 'contact.html') {
        contact();
    } else if (page === basePath + 'project/index.html') {
        project();
    } else if (page === basePath + 'project/new.html') {
        projectNew();
    } else if (page === basePath + 'project/edit.html') {
        projectEdit();
    } else if (page === basePath + 'project/link.html') {
        projectLink();
    } else if (page === basePath + 'resource/index.html') {
        resource();
    } else if (page === basePath + 'resource/new.html') {
        resourceNew();
    } else if (page === basePath + 'resource/edit.html') {
        resourceEdit();
    } else if (page === basePath + 'organization/index.html') {
        organization();
    } else if (page === basePath + 'organization/new.html') {
        organizationNew();
    } else if (page === basePath + 'organization/edit.html') {
        organizationEdit();
    } else if (page === basePath + 'discipline/new.html') {
        disciplineNew();
    } else if (page === basePath + 'discipline/edit.html') {
        disciplineEdit();
    } else if (page === basePath + 'role/new.html') {
        roleNew();
    } else if (page === basePath + 'role/edit.html') {
        roleEdit();
    } else if (page === basePath + 'user/new.html') {
        userNew();
    } else if (page === basePath + 'user/edit.html') {
        userEdit();
    } else {
        console.log('There is no Javascript available for this page.');
    }

  }); // end function to execute after getViewerInfo returns

}); // end EventListener function

// ----------------------
// Depending on the page, call functions in js/api/* that use webservices to get things like organizations, 
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

    getDisciplines(function(disciplines) {
        for (var i = 0; i < disciplines.length; i++) {
            renderDisciplineListElement(disciplines[i]);
        }
        var link = document.getElementById('new-discipline');
        var href = basePath + 'discipline/new.html';
        renderPublicPrivate(link,href);
    });
    getRoles(function(roles) {
        for (var i = 0; i < roles.length; i++) {
            renderRoleListElement(roles[i]);
        }
        var link = document.getElementById('new-role');
        var href = basePath + 'role/new.html';
        renderPublicPrivate(link,href);
    });

    if (viewer.adminuser == "true") {
        // if viewer is an adminuser, add tab/list of users 
        getUsers(function(users) {
            for (var i = 0; i < users.length; i++) {
                renderUserListElement(users[i]);
            }
        });
        var tab = document.getElementById('users-tab'); 
        tab.style.visibility = "visible";
        var tabpane = document.getElementById('users-pane');
        tabpane.style.visibility = "visible";
    } 
    else {
        // if not an adminuser, don't get users and make sure users tab is hidden
        var tab = document.getElementById('users-tab'); 
        tab.style.visibility = "hidden";
        var tabpane = document.getElementById('users-pane');
        tabpane.style.visibility = "hidden";
    }

    // When a search string is entered/removed on the index page...
    // Doing all 3 getXXs after each letter is too slow. 
    // Add a delay so gets don't start until there is a pause in typing.
    var delayTimer;
    onSearchKeyUp(function(input) {

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

} // end index

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

    console.log('Loading the details page for project ' + id.toString());
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
    if(viewer.loggedin != "true") {
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
    if(viewer.loggedin != "true") {
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
    if(viewer.loggedin != "true") {
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

    console.log('Loading the details page for resource ' + id.toString());
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
    if (viewer.loggedin != "true") {
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
    if (viewer.loggedin != "true") {
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

    console.log('Loading the details page for organization ' + id.toString());
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
    if (viewer.loggedin != "true") {
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
    if (viewer.loggedin != "true") {
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
    if (viewer.adminuser != "true") {
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
    if (viewer.adminuser != "true") {
        window.location.replace(basePath + "index.html");
    } else {
        console.log('Loading the edit discipline page');
        var searchParams = new URLSearchParams(window.location.search);
        var id = searchParams.get('discipline_id');

        getDiscipline(id, function(discipline) {
            setupEditDisciplineForm(discipline);
        });

        getDisciplineEvents(id, function(events) {
            events.map(renderDisciplineEventListElement);
        });

        onSearchSubmit(function(query) {
            submitSearch(query);
        });
    }
}

function roleNew() {
    if (viewer.adminuser != "true") {
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
    if (viewer.adminuser != "true") {
        window.location.replace(basePath + "index.html");
    } else {
        console.log('Loading the edit role page');
        var searchParams = new URLSearchParams(window.location.search);
        var id = searchParams.get('role_id');

        getRole(id, function(role) {
            setupEditRoleForm(role);
        });

        getRoleEvents(id, function(events) {
            events.map(renderRoleEventListElement);
        });

        onSearchSubmit(function(query) {
            submitSearch(query);
        });
    }
}

function userNew() {
    if (viewer.adminuser != "true") {
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
    if (viewer.adminuser != "true") {
        window.location.replace(basePath + "login");
    } else {
        console.log('Loading the edit user page');
        var searchParams = new URLSearchParams(window.location.search);
        var id = searchParams.get('user_id');

        getUser(id, function(user) {
            setupEditUserForm(user);
        });

        getUserEvents(id, function(events) {
            events.map(renderUserEventListElement);
        });

        onSearchSubmit(function(query) {
            submitSearch(query);
        });
    }
}
// Hides or shows the passed document element (eg, New and Edit links) and adds the passed href (if any, relevant to <a>'s), 
// depending on whether or not the viewer is logged in
function renderPublicPrivate(item, url) {
    if (viewer.loggedin == "true") {
      if (url) item.href = url; 
      item.style.visibility = "visible";
    } else {
      item.href = "";
      item.style.visibility = "hidden";
    }
}

// Fix Login link depending on whether the viewer is logged in. Also makes the url work correctly.
function fixLoginLink(basePath, url) {
    var login_link = document.getElementById("login_link");
    if (viewer.loggedin == "true") {
        login_link.innerHTML = "You are logged in";
        login_link.href = url;
    } else {
        login_link.innerHTML = "Login";
        login_link.href = basePath + "login";
    }
}

// Used when saving desriptions that are possibly copied and pasted to mysql
// Replace unicode chars for smart quotes, etc. with dumb ones. (logstash doesn't like these in the export file)
function replace_special_chars(text) {
    var fixed = text;
    fixed = fixed.replace(/[\u2018\u2019\u201A\u201B]/g, "'"); // single quotes
    fixed = fixed.replace(/[\u201C\u201D\u201E\u201F]/g, '"');  // double quotes
    fixed = fixed.replace(/[\u2010\u2011\u2012\u2013\u2014\u2015]/g, '-'); // dashes
    fixed = fixed.replace(/[\u2022]/g, '-'); // bullet
    fixed = fixed.replace(/[\u0080]/g, ' '); // padding character
    return fixed;
} 
