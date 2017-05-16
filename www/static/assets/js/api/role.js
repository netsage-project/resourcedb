// GlobalNOC 2017

// Gets roles from the backend.
function getRoles(onSuccess) {
  var url = baseUrl + 'api/index.cgi?method=get_roles';
  fetch(url, {
    method: 'get',
    credentials: 'include'
  }).then(function(response) {

    response.json().then(function(json) {
      console.log(json);
      onSuccess(json.results);
    });

  }).catch(function(err) {
    console.log(err);
  });
}
