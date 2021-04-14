/******************************************************************************
 *
 * Copyright (c) 2017, the Perspective Authors.
 *
 * This file is part of the Perspective library, distributed under the terms of
 * the Apache License 2.0.  The full license can be found in the LICENSE file.
 *
 */

import { registerPlugin } from "@finos/perspective-viewer/dist/esm/utils.js";
import L from "leaflet"

/*const VIEWER_MAP = new Map();*/
const geomColumn = "geometry"
const idMap = "map"

function get_or_create_map(element, div) {
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

  // if (!VIEWER_MAP.has(idMap)) {


  //   // Save the map to fetch it later
  //   VIEWER_MAP.set(idMap, map);
  // } else {
  //   // Fetch the map form the store
  //   map = VIEWER_MAP.get(idMap);

  //   // Attach the container div to the DOM
  //   const mapElement = document.createElement("div");
  //   mapElement.id = idMap
  //   div.innerHTML = ""
  //   div.appendChild(document.createElement("slot"))
  //   element.appendChild(mapElement);
  // }

  return map;
}

export class MapPlugin {
  static async update() { }

  static async create(div, view) {
    try {
      const columns = JSON.parse(this.getAttribute("columns"))
      if (!columns.includes(geomColumn)) {
        columns.push(geomColumn)
        this.setAttribute('columns', JSON.stringify(columns))
      }

      const map = get_or_create_map(this, div);
      map.eachLayer(layer => {
        // Delete all GeoJSON layers
        layer instanceof L.FeatureGroup ? map.removeLayer(layer) : null
      })

      const dataMap = await view.to_json() || []
      if (dataMap.some(x => !!x[geomColumn])) {
        const geojson = L.featureGroup(dataMap.map(({ [geomColumn]: geometry = "{}", ...properties }) => {
          return L.geoJSON({ type: "Feature", geometry: JSON.parse(geometry), properties })
        })).addTo(map)

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

  static delete() {
    console.log("map delete");
  }

  static save() {}

  static restore() {
    console.log("map restore");
  }
}

registerPlugin("map", MapPlugin);
