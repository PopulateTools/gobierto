<template>
  <div style="height: 100vh; ">
    <div class="investments-home-main--map">
      <l-map
        ref="map"
        :center="center"
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
    <button
      class="btn-tour-virtual"
      @click="backInvestments"
      >
      {{ titleButton }}
    </button>
  </div>
</template>

<script>
import { LMap, LTileLayer, LFeatureGroup, LGeoJson } from "vue2-leaflet";
import Wkt from "wicket";
import Vue from "vue";
import { Icon } from "leaflet";
import "leaflet/dist/leaflet.css";
import axios from "axios";
import { CommonsMixin, baseUrl } from "./../mixins/common.js";

// leaflet bug w/ webpack - https://github.com/PaulLeCam/react-leaflet/issues/255
delete Icon.Default.prototype._getIconUrl;
Icon.Default.mergeOptions({
  iconRetinaUrl: require("leaflet/dist/images/marker-icon-2x.png"),
  iconUrl: require("leaflet/dist/images/marker-icon.png"),
  shadowUrl: require("leaflet/dist/images/marker-shadow.png")
});

export default {
  name: "MapTour",
  mixins: [CommonsMixin],
  components: {
    LMap,
    LTileLayer,
    LFeatureGroup,
    LGeoJson
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
        attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
        minZoom: 6,
        maxZoom: 16
      },
      geojsons: [],
      geojsonOptions: {},
      center: [40.199867, -4.0654947], // Spain center
      titleButton: 'Volver',
      items: []
    };
  },
  created() {
    this.labelSummary = I18n.t("gobierto_investments.projects.summary");

    axios.all([axios.get(baseUrl), axios.get(`${baseUrl}/meta?stats=true`)]).then(responses => {
      const [
        {
          data: { data: items = [] }
        },
        {
          data: { data: attributesDictionary = [], meta: filtersFromConfiguration }
        }
      ] = responses;

      this.dictionary = attributesDictionary;
      this.items = this.setData(items);

      if (filtersFromConfiguration) {
        // get the phases, and append what items are in that phase
        const phases = this.getPhases(filtersFromConfiguration)
        this.phases = phases.map(phase => ({
          ...phase,
          items: this.items.filter(d => (d.phases.length ? d.phases[0].id === phase.id : false))
        }));

        // Add dictionary of phases in order to fulfill project page
        this.items = this.items.map(item => ({ ...item, phasesDictionary: phases }))

        this.filters = this.getFilters(filtersFromConfiguration) || [];

        if (this.filters.length) {
          this.activeFilters = new Map();
          this.filters.forEach(f => {
            // initialize active filters
            this.activeFilters.set(f.key, undefined);

            if (f.type === "vocabulary_options") {
              // Add a counter for each option
              f.options = f.options.map(opt => ({ ...opt, counter: this.items.filter(i => i.attributes[f.key].map(g => g.id).includes(opt.id)).length }))
            }
          });
        }
      }

      this.subsetItems = this.items;
      console.log(this.items)
    })

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
        this.$refs.map.mapObject.invalidateSize();
        // center map on the selected
        const bounds = this.$refs.features.mapObject.getBounds();

        if (Object.keys(bounds).length) {
          this.$refs.map.mapObject.fitBounds(bounds);
        } else {
          // If no features, fit the map to the minimal zoom
          this.$refs.map.mapObject.panTo(this.center)
          this.$refs.map.mapObject.fitBounds(this.$refs.map.mapObject.getBounds(), { maxZoom: this.tileOptions.minZoom });
        }
      });
    },
    backInvestments() {
      this.$router.push({ name: "home" });
    }
  }
};
</script>
