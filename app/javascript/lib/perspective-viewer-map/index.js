import { registerPlugin } from "@finos/perspective-viewer/dist/esm/utils.js";
import L from "leaflet"
import "../../../assets/stylesheets/comp-perspective-viewer-map.css"

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

function createLegend({ grades = [], getColor = d => d, fmt = d => d.toLocaleString() }) {
  const legend = L.control({ position: 'bottomright' });

  legend.onAdd = function () {
      const div = L.DomUtil.create('div', 'info legend')

      // loop through our density intervals and generate a label with a colored square for each interval
      for (var i = 0; i < grades.length; i++) {
          div.innerHTML +=
              '<i style="background:' + getColor(grades[i] + 1) + '"></i> ' +
              fmt(grades[i]) + (grades[i + 1] ? '&ndash;' + fmt(grades[i + 1]) + '<br>' : '+');
      }

      return div;
  };

  return legend;
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
      const data = await view.to_json() || []
      if (data.some(({ [geomColumn]: geometry }) => !!geometry)) {

        // find first numeric field
        const [numericField] = (Object.entries(data[0]) || []).find(([, value]) => Number.isFinite(value))
        const mappedData = data.map(d => d[numericField])
        const isInteger = mappedData.every(x => Number.isInteger(x))

        // get range array
        const [min, max] = [Math.min(...mappedData), Math.max(...mappedData)]
        // max. categories
        const length = 5
        const step = (max - min) / length
        const grades = Array.from({ length }, (_, i) => isInteger ? Math.floor(min + (i * step)) : min + (i * step))

        const getColor = (value) => {
          // if don't substract 1, you'll never get the first index
          const ix = grades.findIndex(x => value < x) - 1
          // categories begins as of 1
          return ix >= 0 ? `var(--category-${ix + 1})` : "var(--category-1)"
        }

        const style = ({ properties = {} }) => ({
          fillColor: getColor(properties[numericField]),
          fillOpacity: 0.7,
          color: getColor(properties[numericField]),
          opacity: 1,
        })

        const geojson = L.featureGroup(
          data.map(({ [geomColumn]: geometry = "{}", ...properties }) =>
            L.geoJSON({
              type: "Feature",
              geometry: JSON.parse(geometry),
              properties
            }, { style })
          )
        ).addTo(map);

        map.fitBounds(geojson.getBounds());

        createLegend({ grades, getColor }).addTo(map)
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
