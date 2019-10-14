<template>
  <div style="height: 100vh; ">
    <template>
      <MglMap
          ref="map"
          :accessToken="accessToken"
          :mapStyle.sync="mapStyle"
      />
    </template>
    <button class="btn-tour-virtual" @click="backInvestments">
      {{ titleButton }}
    </button>
    <button class="btn-tour-virtual" @click="flyTo">
      FLYTO
    </button>
  </div>
</template>
<script>
import Mapbox from "mapbox-gl";
import { MglMap, MglGeojsonLayer } from "vue-mapbox";
import Wkt from "wicket";
import Vue from "vue";
import axios from "axios";
import { CommonsMixin, baseUrl } from "./../mixins/common.js";

export default {
  name: "MapTour",
  mixins: [CommonsMixin],
  components: {
   MglMap,
   MglGeojsonLayer
  },
  data() {
    return {
      url: "https://api.tiles.mapbox.com/styles/v1/{username}/{style_id}/tiles/{tilesize}/{z}/{x}/{y}?access_token={token}",
      mapStyle: "mapbox://styles/gobierto/ck18y48jg11ip1cqeu3b9wpar", // your map style
      username: "gobierto",
      style_id: "ck18y48jg11ip1cqeu3b9wpar",
      tilesize: "256",
      accessToken: "pk.eyJ1IjoiYmltdXgiLCJhIjoiY2swbmozcndlMDBjeDNuczNscTZzaXEwYyJ9.oMM71W-skMU6IN0XUZJzGQ",
      center: [40.199867, -4.0654947],
      titleButton: 'Volver',
      items: [],
      geojsons: []
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

      this.locations = this.subsetItems.map(d => d.locationOptions);
    })
  },
  watch: {
    items(items) {
      this.setGeoJSONs(items);
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
      console.log(this.geojsons)

    },
    backInvestments() {
      this.$router.push({ name: "home" });
    }

  }
};

</script>
