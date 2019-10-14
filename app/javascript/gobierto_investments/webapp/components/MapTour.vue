<template>
  <div style="height: 100vh; position:relative; ">
    <template>
      <MglMap ref="mglMap" :accessToken="accessToken" :mapStyle.sync="mapStyle" @load="onMapLoaded" :scrollZoom="scrollZoom" />
    </template>
    <button class="btn-tour-virtual" @click="backInvestments">
      {{ titleButton }}
    </button>
    <button class="btn-tour-virtual" @click="flyToMataro">
      FLYTO
    </button>
    <div class="container-scroll-map" style="position: absolute; top: 10px; left: 95%; height: 100%; overflow-y: scroll;">
      <div v-for="item in items"
        class="investments-home-main--gallery-item"
        @click.prevent="nav(item)"
        style="height:auto; margin-bottom: 90vh;">
        <div class="investments-home-main--photo">
          <img
            v-if="item.photo"
            :src="item.photo"
          >
        </div>
        <div class="investments-home-main--data">
          <a
            href
            class="investments-home-main--link"
            @click.stop.prevent="nav(item)"
          >{{ item.title | translate }}</a>
        </div>
      </div>
    </div>
    <ul>
      <li v-for="item in geojsons">
        <button @click="flyOnMap(item.coordinates)">{{item.coordinates}}</button>
      </li>
    </ul>
  </div>
</template>
<script>
import Mapbox from "mapbox-gl";
import {
  MglMap,
  MglMarker,
  MglPopup,
  MglAttributionControl,
  MglNavigationControl,
  MglGeolocateControl,
  MglFullscreenControl,
  MglScaleControl
} from "vue-mapbox";
import Wkt from "wicket";
import Vue from "vue";
import axios from "axios";
import { CommonsMixin, baseUrl } from "./../mixins/common.js";

export default {
  name: "MapTour",
  mixins: [CommonsMixin],
  components: {
    MglMap,
    MglMarker,
    MglPopup,
    MglAttributionControl,
    MglNavigationControl,
    MglGeolocateControl,
    MglFullscreenControl,
    MglScaleControl
  },
  data() {
    return {
      url: "https://api.tiles.mapbox.com/styles/v1/{username}/{style_id}/tiles/{tilesize}/{z}/{x}/{y}?access_token={token}",
      mapStyle: "mapbox://styles/gobierto/ck18y48jg11ip1cqeu3b9wpar", // your map style
      username: "gobierto",
      style_id: "ck18y48jg11ip1cqeu3b9wpar",
      tilesize: "256",
      accessToken: "pk.eyJ1IjoiYmltdXgiLCJhIjoiY2swbmozcndlMDBjeDNuczNscTZzaXEwYyJ9.oMM71W-skMU6IN0XUZJzGQ",
      titleButton: 'Volver',
      scrollZoom: false,
      items: [],
      geojsons: [],
      map: null,
      zoom: 16,
      mapbox: null
    };
  },
  created() {
    this.mapbox = Mapbox;

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
  computed: {
    center() {
      return this.geojsons.length !== 0 ? Object.values(this.geojsons).reverse() : [2.451, 41.552];
    },
  },
  methods: {
    onMapLoaded(event) {
      this.map = event.map;
    },
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
    },
    backInvestments() {
      this.$router.push({ name: "home" });
    },
    flyToMataro() {
      this.map.flyTo({ center: [2.451, 41.552], pitch: 40, bearing: 40, zoom: this.zoom, speed: 1 });
    },
    flyOnMap(coordinates) {
      const [lat, lng] = Object.values(coordinates)
      this.map.flyTo({ center: [lat, lng], zoom: this.zoom, speed: 1 });
    }
  }
};

</script>
