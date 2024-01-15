//Create map with open streetmap background
// var map = L.map("map", {
//     center: [33.993, -6.85],
//     zoom: 13,
//   });
//   var OSM = L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
//     attribution:
//       '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
//   }).addTo(map);
//   var drawnItems = new L.FeatureGroup();


var map = L.map("map", {
  center: [33.993, -6.85],
  zoom: 13,
});
var OSM = L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
  attribution:
    '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
}).addTo(map);
var esriWorldImagery = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
attribution: '© Esri',
maxZoom: 18,
});

esriWorldImagery.addTo(map);

var baseMaps = {
"OpenStreetMap": OSM,
"Esri World Imagery": esriWorldImagery,
};

var drawnItems = new L.FeatureGroup();
  map.addLayer(drawnItems);
  
  var drawControl = new L.Control.Draw({
    draw: {
      polygon: false,
      polyline: false,
      rectangle: false,
      circle: false,
      circlemarker: false,
      marker: true,
    },
    edit: {
      featureGroup: drawnItems,
    },
  });
  map.addControl(drawControl);
  
  map.on(L.Draw.Event.CREATED, function (event) {
    var layer = event.layer;
  
    drawnItems.addLayer(layer);
  
    if (layer instanceof L.Marker) {
      var latLng = layer.getLatLng();
      window.onMarkerAdded.postMessage(JSON.stringify([latLng.lat, latLng.lng]));
    }
  });
  
  
  
  function displayLocalisations(data) {
    try {
      data.forEach((construction) => {
        if (construction.geometry && construction.geometry.coordinates) {
          var coords = construction.geometry.coordinates;
          var lat = parseFloat(coords[0]);
          var lng = parseFloat(coords[1]);
  
          if (!isNaN(lat) && !isNaN(lng)) {
            L.marker([lat, lng]).addTo(map);
          } else {
            console.error("Invalid coordinates:", coords);
          }
        } else {
          console.error("Invalid construction data:", construction);
        }
      });
    } catch (e) {
      console.error("Error adding markers to map:", e);
    }
  }
  
  
  
  function displayConstructions(geoJSONArray) {
    // Parse the received JSON array
    var jsonString = JSON.stringify(geoJSONArray);
    var geoJSONData = JSON.parse(jsonString); 

    console.log(geoJSONData);
    featureGroup.clearLayers();
    
    geoJSONData.forEach(function (feature) {
      var geojsonLayer = L.geoJSON(feature, {
        onEachFeature: function (feature, layer) {
          // Customize the content of the popup using address, contact, and type_construction
          var popupContent =
            "<p>Address: " +
            feature.address +
            "</p>" +
            "<p>Contact: " +
            feature.contact +
            "</p>" +
            "<p>Type Construction: " +
            feature.type_construction +
            "</p>";
  
          layer.bindPopup(popupContent);
        },
      }).addTo(map);
    });
  }
  var featureGroup = L.featureGroup().addTo(map);
  