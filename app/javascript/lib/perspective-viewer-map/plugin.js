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

/**
 * <perspective-viewer> plugin.
 *
 * @class MapPlugin
 */
class MapPlugin {
    /*static name = "MapPlugin";
    static selectMode = "toggle";
    static deselectMode = "pivots";*/

    /* eslint-disable */
    static async update(div) {
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
            var map = L.map('map').setView([51.505, -0.09], 13);
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            }).addTo(map);
        } catch (e) {
            if (e.message !== "View is not initialized") {
                throw e;
            }
        }
    }

    static async resize() {
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
