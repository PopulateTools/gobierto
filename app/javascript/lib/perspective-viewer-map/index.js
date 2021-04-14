import { registerPlugin } from "@finos/perspective-viewer/dist/esm/utils.js";
import L from "leaflet"

// default geoJSON column name
const geomColumn = "geometry"
// default HTML id
const idMap = "map"

function createMapNode(element, div) {
  if (document.getElementById(idMap)) {
    document.getElementById(idMap).remove()
  }
  // Attach the container div to the DOM
  const mapElement = document.createElement("div");
  mapElement.id = idMap
  div.innerHTML = ""
  div.appendChild(document.createElement("slot"))
  element.appendChild(mapElement);

  // Initialize Leaflet
  const map = L.map(idMap);
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
  }).addTo(map);

  return map;
}

// DEBUG
function getColor(d) {
  return d > 1000 ? '#800026' :
         d > 500 ? '#BD0026' :
         d > 200 ? '#E31A1C' :
         d > 100 ? '#FC4E2A' :
         d > 50 ? '#FD8D3C' :
         d > 20 ? '#FEB24C' :
         d > 10 ? '#FED976' :
                    '#FFEDA0';
}

// DEBUG
function createLegend(map) {
  var legend = L.control({ position: 'bottomright' });

  legend.onAdd = function (map) {

    console.log(map);

      var div = L.DomUtil.create('div', 'info legend'),
          grades = [0, 10, 20, 50, 100, 200, 500, 1000],
          // eslint-disable-next-line no-unused-vars
          labels = [];

      // loop through our density intervals and generate a label with a colored square for each interval
      for (var i = 0; i < grades.length; i++) {
          div.innerHTML +=
              '<i style="background:' + getColor(grades[i] + 1) + '"></i> ' +
              grades[i] + (grades[i + 1] ? '&ndash;' + grades[i + 1] + '<br>' : '+');
      }

      return div;
  };

  legend.addTo(map);
}

export class MapPlugin {
  static async create(div, view) {
    try {
      const columns = JSON.parse(this.getAttribute("columns"))

      // Enforces to have a geometry column
      if (!columns.includes(geomColumn)) {
        columns.push(geomColumn)
        this.setAttribute("columns", JSON.stringify(columns))
      }

      const map = createMapNode(this, div);
      map.eachLayer(layer => {
        // Delete all previous GeoJSON layers
        layer instanceof L.FeatureGroup ? map.removeLayer(layer) : null
      })

      // fetch the current displayed data
      const dataMap = await view.to_json() || []
      if (dataMap.some(({ [geomColumn]: geometry }) => !!geometry)) {
        const geojson = L.featureGroup(
          dataMap.map(({ [geomColumn]: geometry = "{}", ...properties }) =>
            L.geoJSON({
              type: "Feature",
              geometry: JSON.parse(geometry),
              properties
            })
          )
        ).addTo(map);

        map.fitBounds(geojson.getBounds());

        createLegend(map)
      }
    } catch (e) {
      if (e.message !== "View is not initialized") {
        throw e;
      }
    }
  }

  static update() {}

  static resize() {}

  static delete() {}

  static save() {}

  static restore() {}
}

registerPlugin("map", MapPlugin);
