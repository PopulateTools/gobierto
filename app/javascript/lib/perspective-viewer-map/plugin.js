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

const VIEWER_MAP = new Map();

/**
 * <perspective-viewer> plugin.
 *
 * @class MapPlugin
 */

/* eslint-disable */
function get_or_create_map(element, div) {
  let map;
  if (!VIEWER_MAP.has(div)) {
    const mapElement = document.createElement("div");
    mapElement.id = "map"
    element.appendChild(mapElement);

    map = L.map('map');
    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(map);
    VIEWER_MAP.set(div, map);
  } else {
    map = VIEWER_MAP.get(div);
  }

  return map;
}
/* eslint-enable */
export class MapPlugin {
  /*static name = "MapPlugin";
  static selectMode = "toggle";
  static deselectMode = "pivots";*/

  static async update() {}

  /* eslint-disable */
  static async create(div, view) {
    /* eslint-enable */
    try {
      const map = get_or_create_map(this, div);
      map.eachLayer(layer => map.removeLayer(layer))
      const dataMap = await view.to_json()
      const geojson = L.featureGroup(dataMap.map(d => L.geoJSON(JSON.parse(d.geometry)))).addTo(map)
      map.fitBounds(geojson.getBounds());
      /*geojson.properties = dataMap.map(({ geometry }) => geometry)
      /*const geojsonData = {
        type: "FeatureCollection",
        features: dataMap.map(({ geometry,...properties }) => ({
          type: "Feature",
          geometry: JSON.parse(geometry),
          properties
        }))
      };*/
      /*const geojson = L.geoJSON(geojsonData).addTo(map)*/

    } catch (e) {
      if (e.message !== "View is not initialized") {
        throw e;
      }
    }
  }

  static async resize() {
    if (this.view && VIEWER_MAP.has(this._datavis)) {
      const datagrid = VIEWER_MAP.get(this._datavis);
      try {
        await datagrid.draw();
      } catch (e) {
        if (e.message !== "View is not initialized") {
          throw e;
        }
      }
    }
  }

  static delete() {}

  static save() {}

  static restore() {}
}
/******************************************************************************
 *
 * Main
 *
 */

registerPlugin("map", MapPlugin);
