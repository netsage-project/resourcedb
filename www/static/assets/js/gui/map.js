// GlobalNOC 2017

/**
 * renderMap draws a map in the html elment with id 'mapid'.
 *
 * @param resources - Array of objects with params latitude, longitude, and name
 * @param [onRender] - Callback to be executed when the map has been drawn. Is passed the leaflet map object.
 */
function renderMap(resources, onRender) {
    var map = L.map('mapid').setView([0, 0], 3);
    var url = 'https://api.mapbox.com/styles/v1/mapbox/dark-v9/tiles/256/{z}/{x}/{y}?access_token=' + mapboxAccessToken;

    L.tileLayer(url, {
        id: 'netsage.resourcedb',
        accessToken: mapboxAccessToken
    }).addTo(map);

    var latlngPoints = [];
    for (var i = 0; i < resources.length; i++) {
        var latlng = L.latLng(resources[i].latitude, resources[i].longitude);
        latlngPoints.push(latlng);

        var marker = L.marker([resources[i].latitude, resources[i].longitude]).addTo(map);
        marker.bindPopup("<b>" + resources[i].name + "</b><br/>");
    }

    var bounds = L.latLngBounds(latlngPoints);

    var zoom   = map.getBoundsZoom(bounds);
    var center = bounds.getCenter();

    // Sets an arbitrary zoom level for a single point.
    if (latlngPoints.length <= 1) {
        zoom = 5;
    }

    map.setView(center, zoom);
    console.log("Rendered map at " + center + " with zoom of " + zoom);

    if (onRender != undefined) {
        return onRender(map);
    }
    return true;
}
