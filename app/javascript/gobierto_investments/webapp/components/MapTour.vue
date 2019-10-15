<template>
  <div class="map-container">
    <template>
      <MglMap :accessToken="accessToken" :scrollZoom="scrollZoom" :mapStyle.sync="mapStyle" @load="onMapLoaded">
      </MglMap>
      <button class="btn-back-tour-virtual" @click="backInvestments">
        {{ titleButton }}
      </button>
      <div class="container-scroll-map">
        <div class="container-card">
          <div class="investments-home-main--photo">
            <img
              v-if="photoCard"
              :src="photoCard"
            />
          </div>
          <div class="investments-home-main--data">
            <a href class="investments-home-main--link">{{titleCard}}</a>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>
<script>
import Mapbox from "mapbox-gl";
import {
  MglMap
} from "vue-mapbox";
import Wkt from "wicket";
import Vue from "vue";
import axios from "axios";
import { CommonsMixin, baseUrl } from "./../mixins/common.js";

export default {
  name: "MapTour",
  mixins: [CommonsMixin],
  components: {
    MglMap
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
      zoom: 14,
      mapbox: null,
      activeCardId: 0,
      coordinatesCities: [2.451, 41.552],
      titleCard: null,
      photoCard: null
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

      this.setGeoJSONs(this.items);
    })
  },
  computed: {
    center() {
      return this.geojsons.length !== 0 ? Object.values(this.geojsons).reverse() : this.coordinatesCities;
    },
  },
  mounted() {
    setTimeout(() => { this.cardsOnScreen(this.activeCardId) }, 2500)
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

      const [lat, lng] = Object.values(this.geojsons[card].coordinates)

      if (this.geojsons[card].coordinates.length <= 1) {
        const [lat, lng] = Object.values(this.geojsons[card].coordinates[0][0])
        this.map.flyTo({ center: [lat, lng], zoom: this.randomNumbers(15, 17), bearing: this.randomNumbers(-60, 60), pitch: this.randomNumbers(10, 60), speed: 0.75 });
      } else {
        this.map.flyTo({ center: [lat, lng], zoom: this.randomNumbers(15, 17), bearing: this.randomNumbers(-60, 60), pitch: this.randomNumbers(10, 60), speed: 0.75 });
      }
      this.activeCardId += 1
      if(this.activeCardId < this.geojsons.length) {
        setTimeout(() => { this.cardsOnScreen(this.activeCardId) }, 2500)
      }

    },
    backInvestments() {
      this.$router.back({ name: "home" });
    }
  }
};

</script>
