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

const VIEWER_MAP = new WeakMap();

/**
 * <perspective-viewer> plugin.
 *
 * @class MapPlugin
 */

 /* eslint-disable */
 function get_or_create_datagrid(element, div) {
     let datagrid;
     if (!VIEWER_MAP.has(div)) {
         datagrid = document.createElement("regular-table");
         div.innerHTML = "";
         div.appendChild(document.createElement("slot"));
         element.appendChild(datagrid);
         VIEWER_MAP.set(div, datagrid);
     } else {
         datagrid = VIEWER_MAP.get(div);
         if (!datagrid.isConnected) {
             datagrid.clear();
             div.innerHTML = "";
             div.appendChild(document.createElement("slot"));
             element.appendChild(datagrid);
         }
     }

     return datagrid;
 }
 /* eslint-enable */
export class MapPlugin {
  constructor(data) {
    this.data = data
  }
  /*static name = "MapPlugin";
  static selectMode = "toggle";
  static deselectMode = "pivots";*/

  /* eslint-disable */
  static async update(div) {
    console.log("update");
    /* eslint-enable */
    /*try {
        const datagrid = VIEWER_MAP.get(div);
        const model = INSTALLED.get(datagrid);
        model._num_rows = await model._view.num_rows();
        await datagrid.draw();
    } catch (e) {
        if (e.message !== "View is not initialized") {
            throw e;
        }
    }*/
  }

  /* eslint-disable */
  static async create(div, view) {
  /* eslint-enable */
    try {
      const mapElement = document.createElement("div");
      mapElement.id = "map"
      this.appendChild(mapElement);
      var map = L.map('map');
      L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
      }).addTo(map);
      const testDataMap = await view.to_json()
      const geojson = L.featureGroup(testDataMap.map(d => L.geoJSON(JSON.parse(d.geometry)))).addTo(map)
      console.log("geojson", geojson);
      /*geojson.properties = testDataMap.map(({ geometry }) => geometry)
      console.log("geojson", geojson);*/
      /*const geojsonData = {
        type: "FeatureCollection",
        features: testDataMap.map(({ geometry,...properties }) => ({
          type: "Feature",
          geometry: JSON.parse(geometry),
          properties
        }))
      };*/
      /*const geojson = L.geoJSON(geojsonData).addTo(map)*/
      map.fitBounds(geojson.getBounds());

    } catch (e) {
      if (e.message !== "View is not initialized") {
        throw e;
      }
    }
  }

  static async resize() {
    console.log("resize");
    /*if (this.view && VIEWER_MAP.has(this._datavis)) {
        const datagrid = VIEWER_MAP.get(this._datavis);
        try {
            await datagrid.draw();
        } catch (e) {
            if (e.message !== "View is not initialized") {
                throw e;
            }
        }
    }*/
  }

  static delete() {
    /*if (this.view && VIEWER_MAP.has(this._datavis)) {
        const datagrid = VIEWER_MAP.get(this._datavis);
        datagrid.clear();
    }*/
  }

  static save() {}

  static restore() {}
}
/******************************************************************************
 *
 * Main
 *
 */

registerPlugin("map", MapPlugin);
