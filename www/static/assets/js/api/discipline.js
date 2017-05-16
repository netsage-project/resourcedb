// GlobalNOC 2017

// Gets disciplines from the backend.
function getDisciplines(onSuccess) {
  var url = baseUrl + 'api/index.cgi?method=get_disciplines';
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
