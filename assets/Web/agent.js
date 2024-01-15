let drawnShape;
let geoJsonFeatures = [];
var map = L.map('map', {
    center: [33.993, -6.85],
    zoom: 13
});
var OSM = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
    {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }
).addTo(map);


let drawItems = new L.FeatureGroup();
map.addLayer(drawItems);
let drawControl = new L.Control.Draw({
    draw: {
        polygon: true,
        polyline: false,
        rectangle: false,
        circle: false,
        marker: false
    }
    ,
    edit: {
        featureGroup: drawItems,
    },
});
map.addControl(drawControl);


map.on(L.Draw.Event.CREATED, function (e) {
    var type = e.layerType,
        layer = e.layer;
    drawnShape = layer;
    showForm();


});

function showForm() {
    document.getElementById("formContainer").style.display = "block";
}
function closeForm() {
    document.getElementById("formContainer").style.display = "none";
}


function saveForm() {
    const address = document.getElementById("address").value;
    const contact = document.getElementById("contact").value;
    const type = document.getElementById("type").value;
    const flattenedCoordinates = drawnShape.getLatLngs().flat();

    const uniqueCoordinates = [];
    for (const latlng of flattenedCoordinates) {
        const coordinateString = `${latlng.lat},${latlng.lng}`;
        if (!uniqueCoordinates.includes(coordinateString)) {
            uniqueCoordinates.push(coordinateString);
        }
    }

    const uniqueLatLngs = uniqueCoordinates.map(coordString => {
        const [lat, lng] = coordString.split(',').map(parseFloat);
        return L.latLng(lat, lng);
    });
    const actualCoordinates = [uniqueLatLngs.map(latlng => [latlng.lng, latlng.lat])];
    console.log('actual coordinates ', actualCoordinates);
    actualCoordinates[0].push(actualCoordinates[0][0]);
    const geoJSONFeature = {
        type: 'Feature',
        geometry: {
            type: 'Polygon',
            coordinates: actualCoordinates,
        },
        properties: {
            address: address,
            contact: contact,
            type: type,
        },
    };


    drawItems.addLayer(L.geoJSON(geoJSONFeature));
    geoJsonFeatures.push(geoJSONFeature);

    closeForm();
    console.log(geoJSONFeature);
    const data = JSON.stringify(geoJSONFeature)

    if (window.flutter_inappwebview) {
        window.flutter_inappwebview.callHandler('sendMessageToFlutter', data);
    } else {
        const errorMessage = 'Flutter WebView platform is not ready';

        const errorContainer = document.getElementById('errorContainer');
        if (errorContainer) {
            errorContainer.innerHTML = `<p style="color: red;">${errorMessage}</p>`;
        } else {
            console.error(errorMessage);
        }
    }

    drawnShape = null;
}
map.on('draw:edited', function (e) {
    var layers = e.layers;
    layers.eachLayer(function (layer) {

    });
});
function displayGeoJSON(geoJSONArray) {
    var jsonString = JSON.stringify(geoJSONArray);
    var geoJSONData = JSON.parse(jsonString);

    console.log(geoJSONData);
    featureGroup.clearLayers();
    
    geoJSONData.forEach(function (feature) {
        var geojsonLayer = L.geoJSON(feature, {
            onEachFeature: function (feature, layer) {
                var popupContent =
                    "<p>Address: " + feature.address + "</p>" +
                    "<p>Contact: " + feature.contact + "</p>" +
                    "<p>Type Construction: " + feature.type_construction + "</p>";

                layer.bindPopup(popupContent);
            }
        }).addTo(map);
    });

}

function displayLocalisations(data) {
    try {
        data.forEach(construction => {
            if (construction.geometry && construction.geometry.coordinates) {
                var coords = construction.geometry.coordinates;
                var lat = parseFloat(coords[0]);
                var lng = parseFloat(coords[1]);

                if (!isNaN(lat) && !isNaN(lng)) {
                    L.marker([lat, lng]).addTo(map);
                } else {
                    console.error('Invalid coordinates:', coords);
                }
            } else {
                console.error('Invalid construction data:', construction);
            }
        });
    } catch (e) {
        console.error('Error adding markers to map:', e);
    }

}

var featureGroup = L.featureGroup().addTo(map);


