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
              '<i style="background:' + getColor(grades[i]) + '"></i> ' +
              fmt(grades[i]) + (grades[i + 1] ? '&ndash;' + fmt(grades[i + 1]) + '<br>' : '+');
      }

      return div;
  };

  return legend;
}

export class MapPlugin {
  // static name = "Map"

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
        const maxCategories = 5
        // substract one to maxCategories in order to keep the max. value INSIDE the range
        const step = (max - min) / (maxCategories - 1)
        const grades = Array.from({ length: maxCategories - 1 }, (_, i) => isInteger ? Math.floor(min + (i * step)) : min + (i * step))
        grades.push(max)

        const getColor = (value) => {
          // if don't substract 1, you'll never get the first index
          const ix = grades.findIndex(x => value <= x)
          // categories begins as of 1
          return ix >= 0 ? `var(--perspective-map-category-${ix + 1})` : ''
        }

        const style = ({ properties = {} }) => ({
          fillColor: getColor(properties[numericField]),
          fillOpacity: 1,
          color: getColor(properties[numericField]),
          opacity: 1,
        })

        // creates features ONLY if they're plane strings
        const features =
          data.map(({ [geomColumn]: geometry = "{}", ...properties }) =>
            typeof geometry === "string" || geometry instanceof String
              ? L.geoJSON(
                  {
                    type: "Feature",
                    geometry: JSON.parse(geometry),
                    properties
                  },
                  { style }
                )
              : null
          ).filter(Boolean) || [];

        if (features.length) {
          const geojson = L.featureGroup(features).addTo(map);
          map.fitBounds(geojson.getBounds());
          createLegend({ grades, getColor }).addTo(map)
        } else {
          // if there's nothing to display, you must set the default view
          // TODO: parametrize
          map.setView([40.3, -3.7], 13)
        }

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
