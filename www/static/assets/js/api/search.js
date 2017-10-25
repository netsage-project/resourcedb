// GlobalNOC 2017

// Redirects to index.html with the search param set to query.
function submitSearch(query) {
    var url = basePath + 'index.html';
    url += '?search=' + query;
    window.location.href = url;
}
