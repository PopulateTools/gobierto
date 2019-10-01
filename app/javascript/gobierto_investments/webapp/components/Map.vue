<template>
  <l-map ref="map">
    <l-tile-layer :url="url" />
    <l-feature-group ref="features">
      <l-geo-json
        v-for="geojson in geojsons"
        :key="geojson.index"
        :geojson="geojson"
      />
    </l-feature-group>
  </l-map>
</template>

<script>
import { Icon } from "leaflet";
import "leaflet/dist/leaflet.css";

// leaflet bug w/ webpack - https://github.com/PaulLeCam/react-leaflet/issues/255
delete Icon.Default.prototype._getIconUrl;
Icon.Default.mergeOptions({
  iconRetinaUrl: require("leaflet/dist/images/marker-icon-2x.png"),
  iconUrl: require("leaflet/dist/images/marker-icon.png"),
  shadowUrl: require("leaflet/dist/images/marker-shadow.png")
});

import { LMap, LTileLayer, LFeatureGroup, LGeoJson } from "vue2-leaflet";
import Wkt from "wicket";

export default {
  name: "Map",
  components: {
    LMap,
    LTileLayer,
    LFeatureGroup,
    LGeoJson
  },
  props: {
    items: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      url: "http://{s}.tile.osm.org/{z}/{x}/{y}.png",
      geojsons: []
    };
  },
  watch: {
    items(items) {
      this.setGeoJSONs(items);
    }
  },
  created() {
    this.setGeoJSONs(this.items);
  },
  mounted() {
    this.$nextTick(() => {
      this.$refs.map.mapObject.fitBounds(this.$refs.features.mapObject.getBounds(), { maxZoom: 15 });
    });
  },
  methods: {
    convertWKTtoGeoJSON(wktString) {
      const wkt = new Wkt.Wkt();
      wkt.read(wktString);
      return wkt.toJson();
    },
    setGeoJSONs(items) {
      // get the Well-Known Text (WKT)
      const markerStrings = items.reduce((acc, i) => {
        if (i.location && i.location !== null) {
          acc.push(i.location);
        }
        return acc;
      }, []);

      this.geojsons = [];
      // convert all WKT objets to GeoJSON, and add them to a feature group
      for (let index = 0; index < markerStrings.length; index++) {
        this.geojsons.push({ ...this.convertWKTtoGeoJSON(markerStrings[index]), index });
      }
    }
  }
};
</script>
