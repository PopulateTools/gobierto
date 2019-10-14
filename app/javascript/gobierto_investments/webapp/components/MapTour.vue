<template>
  <div style="height: 100vh; ">
    <div class="investments-home-main--map">
      <l-map ref="map" :center="center" :options="{
          scrollWheelZoom: false
        }">
        <l-tile-layer :url="url" :options="tileOptions" :detect-retina="true" />
      </l-map>
    </div>
    <button class="btn-tour-virtual" @click="backInvestments">
      {{ titleButton }}
    </button>
    <button class="btn-tour-virtual" @click="flyTo">
      FLYTO
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
      zoom: 5,
      geojsons: [],
      geojsonOptions: {},
      item: null,
      center: [40.199867, -4.0654947], // Spain center
      titleButton: 'Volver',
      items: []
    };
  },
  created() {
    this.labelSummary = I18n.t("gobierto_investments.projects.summary");

    axios.all([axios.get(baseUrl), axios.get(`${baseUrl}/meta?stats=true`)]).then(responses => {
      const [{
          data: { data: items = [] }
        },
        {
          data: { data: attributesDictionary = [], meta: filtersFromConfiguration }
        }
      ] = responses;

      this.dictionary = attributesDictionary;
      this.items = this.setData(items);

      this.subsetItems = this.items;
      console.log(this.items)
      this.$refs.map.mapObject.flyTo([41.552,2.451], 15);
    })
  },
  methods: {

    flyTo() {
      this.$refs.map.mapObject.flyTo([40.199867, -4.0654947], 15);
    },
    backInvestments() {
      this.$router.push({ name: "home" });
    }
  }
};

</script>
