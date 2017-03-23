// GlobalNOC 2017

function renderMap(onRender) {
    var mymap = L.map('mapid').setView([0, 0], 3);
    var url = 'https://api.mapbox.com/styles/v1/mapbox/dark-v9/tiles/256/{z}/{x}/{y}?access_token=' + mapboxAccessToken;

    L.tileLayer(url, {
        maxZoom: 18,
        id: 'netsage.resourcedb',
        accessToken: mapboxAccessToken
    }).addTo(mymap);

    onRender(mymap);
}
