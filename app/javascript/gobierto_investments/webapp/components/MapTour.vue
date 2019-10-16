<template>
  <div class="map-flyto-container">
    <div class="map-flyto-header">
      <div class="site_header_image">
        <a href="#">
          <img alt="Ajuntament de Mataró" src="https://gobierto-populate-staging.s3-eu-west-1.amazonaws.com/site-8/sites/logo-e92cb83c-9c73-46e8-ae2d-af48fcf7b494/logo_mataro.png">
        </a>
      </div>
      <div class="map-flyto-header-btns">
        <button class="btn-reload-tour-virtual" @click="reloadTour">
          <i class="fas icon fa-redo-alt"></i>{{ buttonReload }}
        </button>
        <button class="btn-back-tour-virtual" @click="backInvestments">
          {{buttonExit}}<i class="fas icon fa-sign-out-alt"></i>
        </button>
      </div>
    </div>
    <template>
      <MglMap
        :accessToken="accessToken"
        :mapStyle.sync="mapStyle"
        :scrollZoom="scrollZoom"
        @load="onMapLoaded">
        <MglMarker
          :coordinates="coordinatesMarker"
          :color="colorTheme"/>
      </MglMap>
      <div class="container-card">
        <div
          @click.stop.prevent="navTo(item)"
          class="container-card-element">
          <div class="investments-home-main--photo">
            <img v-if="photoCard" :src="photoCard" />
          </div>
          <div class="investments-home-main--data">
            <a href
              @click.stop.prevent="navTo(item)"
              class="investments-home-main--link">{{ titleCard }}</a>
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
import Mapbox from "mapbox-gl";
import {
  MglMap,
  MglMarker
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
    MglMarker
  },
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
      zoomDefault: 15,
      mapbox: null,
      activeCardId: 0,
      coordinatesCities: [2.451, 41.552],
      titleCard: null,
      photoCard: null,
      projectId: null,
      item: null,
      coordinatesMarker: [2.451, 41.552],
      colorTheme: '#0178A8'
    };
  },
  computed: {
    center() {
      return this.geojsons.length !== 0 ? Object.values(this.geojsons).reverse() : this.coordinatesCities;
    },
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

      this.setGeoJSONs(this.items);
    })
  },
  mounted() {
    setTimeout(() => { this.cardsOnScreen(this.activeCardId) }, 3000)
  },
  methods: {
    onMapLoaded(event) {
      this.map = event.map;
      this.addMarkers
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
    cardsOnScreen(elementCard) {
      this.activeCard(this.activeCardId);
    },
    randomNumbers(min, max) {
      return Math.floor(Math.random() * (max - min + 1) + min);
    },
    activeCard(card) {
      this.titleCard = this.geojsons[card].title.ca
      this.photoCard = this.geojsons[card].photo
      this.item = this.geojsons[card].id

      const [lat, lng] = Object.values(this.geojsons[card].coordinates)

      if (this.geojsons[card].coordinates.length <= 1) {
        this.coordinatesMarker = this.geojsons[card].coordinates[0][0]
        const [lat, lng] = Object.values(this.geojsons[card].coordinates[0][0])
        this.map.flyTo({
          center: [lat, lng],
          zoom: this.randomNumbers(15, 17),
          bearing: this.randomNumbers(-60, 60),
          pitch: this.randomNumbers(10, 60),
          speed: 0.75
        });

      } else {
        this.coordinatesMarker = this.geojsons[card].coordinates
        this.map.flyTo({
          center: [lat, lng],
          zoom: this.randomNumbers(15, 17),
          bearing: this.randomNumbers(-60, 60),
          pitch: this.randomNumbers(10, 60),
          speed: 0.75
        });

      }
      this.activeCardId += 1
      if (this.activeCardId < this.geojsons.length) {
        this.activeTour = setTimeout(() => { this.cardsOnScreen(this.activeCardId) }, 3000)
        this.activeTour
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
