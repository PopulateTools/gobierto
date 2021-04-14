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

export class MapPlugin {
  static async update() { }

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
      }
    } catch (e) {
      if (e.message !== "View is not initialized") {
        throw e;
      }
    }
  }

  static async resize() {
    // if (this.view && VIEWER_MAP.has(this._datavis)) {
    //   const datagrid = VIEWER_MAP.get(this._datavis);
    //   try {
    //     await datagrid.draw();
    //   } catch (e) {
    //     if (e.message !== "View is not initialized") {
    //       throw e;
    //     }
    //   }
    // }
  }

  static delete() {}

  static save() {}

  static restore() {}
}

registerPlugin("map", MapPlugin);
