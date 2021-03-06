// GlobalNOC 2017

/**
 * renderMap draws a map in the html elment with id 'mapid'.
 *
 * @param resources - Array of objects with params latitude, longitude, and name (resources)
 * @param [orgs] - Array of objects with params latitude, longitutde, and name (organizations)
 * @param [onRender] - Callback to be executed when the map has been drawn. Is passed the leaflet map object.
 */
function renderMap(resources, orgs, onRender) {
    var map = L.map('mapid').setView([0, 0], 3);
    var url = 'https://api.mapbox.com/styles/v1/mapbox/dark-v9/tiles/256/{z}/{x}/{y}?access_token=' + mapboxAccessToken;

    L.tileLayer(url, {
        id: 'netsage.resourcedb',
        accessToken: mapboxAccessToken
    }).addTo(map);

    var latlngPoints = [];
    var legendTxt = "";

    for (var i = 0; i < resources.length; i++) {
        var latlng = L.latLng(resources[i].latitude, resources[i].longitude);
        latlngPoints.push(latlng);

        var marker = L.circleMarker([resources[i].latitude, resources[i].longitude],{color: '#52a9f5'}).addTo(map);
        marker.bindPopup("<b>" + resources[i].name + "</b><br/>");
    }
    legendTxt = "<span style='color:#489feb;'><span style='font-size:18px'>o</span> Resources</span>";

    if (orgs != undefined) {
        for (var i = 0; i < orgs.length; i++) {
            if ( orgs[i].latitude == 0 && orgs[i].longitude == 0 ) continue;
            var latlng = L.latLng(orgs[i].latitude, orgs[i].longitude);
            latlngPoints.push(latlng);

            var marker = L.circleMarker([orgs[i].latitude, orgs[i].longitude],{color: '#ff4d4d'}).addTo(map);
            marker.bindPopup("<b>" + orgs[i].name + "</b><br/>");
        }
        legendTxt = "<span style='color:#ff5757;'><span style='font-size:18px'>o</span> Organization</span><br/>" + legendTxt;
    }

    var legend = new L.control({position:"bottomleft"});
    legend.onAdd = function() {
        var div = L.DomUtil.create( 'div', 'legend' );
        div.innerHTML = legendTxt;
        div.style = "padding: 6px 8px; font: 14px/16px Arial, Helvetica, sans-serif; background: white; background: rgba(255,255,255,0.9); box-shadow: 0 0 15px rgba(0,0,0,0.2); border-radius: 4px;";
        return div;
    };
    map.addControl(legend);

    var bounds = L.latLngBounds(latlngPoints);

    var center;
    var zoom;
    if (latlngPoints.length == 1) {
        zoom   = 5;
        center = [latlngPoints[0].lat, latlngPoints[0].lng];
    }
    else if (latlngPoints.length > 1) {
        zoom = map.getBoundsZoom(bounds);
        center = bounds.getCenter();
    }
    else {
        zoom = 3;
        center = [40, -50];
    }

    map.setView(center, zoom);
    console.log("Rendered map at " + center + " with zoom of " + zoom);

    if (onRender != undefined) {
        return onRender(map);
    }
    return true;
}
