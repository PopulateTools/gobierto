<template>
  <div class="investments-home-main--map">
    <l-map
      ref="map"
      :options="{
        scrollWheelZoom: false
      }"
    >
      <l-tile-layer
        :url="url"
        :options="tileOptions"
        :detect-retina="true"
      />
      <l-feature-group
        v-if="geojsons"
        ref="features"
      >
        <l-geo-json
          v-for="geojson in geojsons"
          :key="geojson.index"
          :geojson="geojson"
          :options="geojsonOptions"
        />
      </l-feature-group>
    </l-map>
  </div>
</template>

<script>
import { LMap, LTileLayer, LFeatureGroup, LGeoJson } from "vue2-leaflet";
import Wkt from "wicket";
import Vue from "vue";
import GalleryItem from "./GalleryItem.vue";
import { Icon } from "leaflet";
import "leaflet/dist/leaflet.css";

// leaflet bug w/ webpack - https://github.com/PaulLeCam/react-leaflet/issues/255
delete Icon.Default.prototype._getIconUrl;
Icon.Default.mergeOptions({
  iconRetinaUrl: require("leaflet/dist/images/marker-icon-2x.png"),
  iconUrl: require("leaflet/dist/images/marker-icon.png"),
  shadowUrl: require("leaflet/dist/images/marker-shadow.png")
});

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
  popupClass: "investments-home-main--map-popup",
  data() {
    return {
      url: "https://api.tiles.mapbox.com/styles/v1/{username}/{style_id}/tiles/{tilesize}/{z}/{x}/{y}?access_token={token}",
      tileOptions: {
        username: "gobierto",
        style_id: "ck18y48jg11ip1cqeu3b9wpar",
        tilesize: "256",
        token: "pk.eyJ1IjoiYmltdXgiLCJhIjoiY2swbmozcndlMDBjeDNuczNscTZzaXEwYyJ9.oMM71W-skMU6IN0XUZJzGQ",
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
      },
      geojsons: [],
      geojsonOptions: {},
      item: null
    };
  },
  watch: {
    items(items) {
      if (items.length) {
        this.setGeoJSONs(items);
      }
    }
  },
  created() {
    // https://github.com/KoRiGaN/Vue2Leaflet/blob/master/examples/src/components/GeoJSON2.vue
    const onEachFeature = (feature, layer) => {
      const PopupComponent = Vue.extend(GalleryItem);
      const popup = new PopupComponent({
        router: this.$router,
        propsData: {
          item: this.items.find(item => item.id === feature.id)
        }
      });

      const { x } = this.$refs.map.mapObject.getSize();

      layer.bindPopup(popup.$mount().$el, {
        className: this.$options.popupClass,
        closeButton: false,
        maxWidth: x / 3,
        minWidth: x / 3
      });
    };

    this.geojsonOptions = { onEachFeature };

    if (this.items.length) {
      this.setGeoJSONs(this.items);
    }
  },
  methods: {
    convertWKTtoGeoJSON(wktString) {
      const wkt = new Wkt.Wkt();
      wkt.read(wktString);
      return wkt.toJson();
    },
    setGeoJSONs(items) {
      this.geojsons = [];

      // get the Well-Known Text (WKT)
      const markerWithLocation = items.reduce((acc, i) => {
        if (i.location && i.location !== null) {
          acc.push(i);
        }
        return acc;
      }, []);

      // convert all WKT objets to GeoJSON, and add them to a feature group
      for (let index = 0; index < markerWithLocation.length; index++) {
        const { id, location } = markerWithLocation[index];
        this.geojsons.push({ ...this.convertWKTtoGeoJSON(location), id });
      }

      this.$nextTick(() => {
        // force to map size recalculation, container size might have changed
        this.$refs.map.mapObject.invalidateSize()
        // center map on the selected
        const bounds = this.$refs.features.mapObject.getBounds()
        if (Object.keys(bounds).length) {
          this.$refs.map.mapObject.fitBounds(bounds, { maxZoom: 15 });
        }
      });
    }
  }
};
</script>
