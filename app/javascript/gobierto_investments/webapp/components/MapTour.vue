<template>
  <div class="map-flyto-container">
    <div class="map-flyto-header">
      <div class="site_header_image">
        <a :href="homeUrl">
          <img
            :alt="siteName"
            :src="logoUrl"
          >
        </a>
      </div>
      <div class="map-flyto-header-btns">
        <button
          class="btn-reload-tour-virtual"
          @click="reloadTour"
        >
          <i class="fas icon fa-redo-alt" />{{ buttonReload }}
        </button>
        <button
          class="btn-back-tour-virtual"
          @click="backInvestments"
        >
          {{ buttonExit }}<i class="fas icon fa-sign-out-alt" />
        </button>
      </div>
    </div>
    <template>
      <MglMap
        :access-token="accessToken"
        :map-style.sync="mapStyle"
        :scroll-zoom="scrollZoom"
        @load="onMapLoaded"
      >
        <MglMarker :coordinates="coordinatesMarker">
          <img
            slot="marker"
            src="/packs/media/images/marker-icon-2273e3d8.png"
          >
        </MglMarker>
      </MglMap>
      <div class="container-card">
        <div
          class="container-card-element"
          @click.stop.prevent="navTo(item)"
        >
          <div class="investments-home-main--photo">
            <img
              v-if="photoCard"
              :src="photoCard"
            >
          </div>
          <div class="investments-home-main--data">
            <a
              href
              class="investments-home-main--link"
              @click.stop.prevent="navTo(item)"
            >{{ titleCard }}
            </a>
          </div>
        </div>
      </div>
      <div class="container-counter-elements">
        <div class="container-counter-elements-circle">
          <span class="counter-elements-text">
            {{ activeCardId }}
          </span>
        </div>
      </div>
    </template>
  </div>
</template>
<script>
import {
  MglMap,
  MglMarker
} from "vue-mapbox";
import "mapbox-gl/src/css/mapbox-gl.css"
import Wkt from "wicket";
import axios from "axios";
import { Middleware } from "lib/shared";
import { CommonsMixin, baseUrl } from "./../mixins/common.js";

export default {
  name: "MapTour",
  components: {
    MglMap,
    MglMarker
  },
  mixins: [CommonsMixin],
  data() {
    return {
      url: "https://api.tiles.mapbox.com/styles/v1/{username}/{style_id}/tiles/{tilesize}/{z}/{x}/{y}?access_token={token}",
      mapStyle: "mapbox://styles/gobierto/ck18y48jg11ip1cqeu3b9wpar", // your map style
      username: "gobierto",
      style_id: "ck18y48jg11ip1cqeu3b9wpar",
      tilesize: "256",
      accessToken: "pk.eyJ1IjoiYmltdXgiLCJhIjoiY2swbmozcndlMDBjeDNuczNscTZzaXEwYyJ9.oMM71W-skMU6IN0XUZJzGQ",
      buttonExit: I18n.t("gobierto_investments.projects.exit"),
      buttonReload: I18n.t("gobierto_investments.projects.see"),
      scrollZoom: false,
      geojsons: [],
      mapbox: null,
      activeCardId: 0,
      titleCard: null,
      photoCard: null,
      item: null,
      coordinatesMarker: [2.445,41.542],
      homeUrl: this.$root.$data.homeUrl,
      logoUrl: this.$root.$data.logoUrl,
      siteName: this.$root.$data.siteName,
      loadData: false,
      loadMap: false
    };
  },
  computed: {
    combinedMapData(){
      return this.loadData && this.loadMap
    }
  },
  watch: {
    combinedMapData(value){
      if (value === true) {
        this.cardsOnScreen(this.activeCardId)
      }
    }
  },
  created() {
    axios.all([axios.get(baseUrl), axios.get(`${baseUrl}/meta?stats=true`)]).then(responses => {
      const [{
          data: { data: items = [] }
        },
        {
          data: { data: attributesDictionary = [] }
        }
      ] = responses;

      this.dictionary = attributesDictionary;
      this.middleware = new Middleware({
        dictionary: attributesDictionary
      });

      this.items = this.setData(items);

      this.subsetItems = this.items;

      this.setGeoJSONs(this.items);

      this.loadData = true
    })
  },
  methods: {
    onMapLoaded(event) {
      this.map = event.map;
      this.loadMap = true
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
        const { id, location, photo, title, description, attributes } = markerWithLocation[index];
        this.geojsons.push({ ...this.convertWKTtoGeoJSON(location), id, photo, title, description, attributes });
      }
    },
    cardsOnScreen() {
      this.activeCard(this.activeCardId);
    },
    randomNumbers(min, max) {
      return Math.floor(Math.random() * (max - min + 1) + min);
    },
    activeCard(card) {
      this.titleCard = this.geojsons[card].title
      this.photoCard = this.geojsons[card].photo
      this.item = this.geojsons[card].id

      if (this.geojsons[card].coordinates.length <= 1) {
        // polygons
        this.coordinatesMarker = this.geojsons[card].coordinates[0][0]

        this.map.flyTo({
          center: this.coordinatesMarker,
          zoom: this.randomNumbers(15, 17),
          bearing: this.randomNumbers(-60, 60),
          pitch: this.randomNumbers(10, 60),
          speed: 0.75
        });
      } else {
        // points
        this.coordinatesMarker = this.geojsons[card].coordinates

        this.map.flyTo({
          center: this.coordinatesMarker,
          zoom: this.randomNumbers(15, 17),
          bearing: this.randomNumbers(-60, 60),
          pitch: this.randomNumbers(10, 60),
          speed: 0.75
        });
      }

      this.activeCardId += 1

      if (this.activeCardId < this.geojsons.length) {
        this.activeTour = setTimeout(() => { this.cardsOnScreen(this.activeCardId) }, 3000)
      }
    },
    reloadTour() {
      clearTimeout(this.activeTour)
      this.activeCardId = 0
      this.cardsOnScreen(this.activeCardId)
    },
    backInvestments() {
      this.$router.push({ name: "home" });
    },
    navTo(item) {
      this.$router.push({ name: "project", params: { id: item } });
    },
  }
};

</script>
