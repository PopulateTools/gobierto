<template>
  <div style="height: 100vh; position:relative; ">
    <template>
      <MglMap ref="mglMap" :accessToken="accessToken" :scrollZoom="scrollZoom" :mapStyle.sync="mapStyle" :minZoom="5" :maxZoom="18" @load="onMapLoaded">
        <MglNavigationControl position="top-left" />
        <MglGeolocateControl position="top-right" />
      </MglMap>
      <button style="position: absolute; top: 80%; left: 8px;" class="btn-tour-virtual" @click="backInvestments">
        {{ titleButton }}
      </button>
      <div v-on:scroll.passive="cardsOnScreen" class="container-scroll-map" style="position: absolute; top: 10px; left: 77%; height: 100%; overflow-y: scroll;">
        <div
          v-for="(item, index) in geojsons"
          class="investments-home-main--gallery-item"
          @click.prevent="nav(item)"
          :key="item.id"
          :id="`${index}`"
          style="height:auto; margin-bottom: 90vh; width: 300px; background: #fff; box-shadow: 0 13px 27px -5px rgba(50,50,93,.25), 0 8px 16px -8px rgba(0,0,0,.3), 0 -6px 16px -6px rgba(0,0,0,.025);">
          <div class="investments-home-main--photo">
            <img v-if="item.photo" :src="item.photo" />
          </div>
          <div class="investments-home-main--data">
            <a href class="investments-home-main--link" @click.stop.prevent="nav(item)">{{item.title | translate}}</a>
          </div>
        </div>
      </div>
    </template>

  </div>
</template>
<script>
import Mapbox from "mapbox-gl";
import {
  MglMap,
  MglNavigationControl,
  MglGeolocateControl
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
    MglNavigationControl,
    MglGeolocateControl
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
      attributes: []
    };
  },
  created() {
    window.addEventListener('scroll', this.cardsOnScreen)

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
        const { id, location, photo, title, description, attributes } = markerWithLocation[index];
        this.geojsons.push({ ...this.convertWKTtoGeoJSON(location), id, photo, title, description, attributes });
      }

    },
    backInvestments() {
      this.$router.push({ name: "home" });
    },
    cardsOnScreen() {
      this.cardElements = Object.keys(this.geojsons);
      for (let i = 0; i < this.cardElements.length; i++) {
        this.card = this.cardElements[i];
        if (this.isElementOnScreen(this.card)) {
          this.activeCard(this.card);
          break;
        }
      }
    },
    activeCard(card) {
      if (card === this.activeCardId) return;

      const [lat, lng] = Object.values(this.geojsons[card].coordinates)

      if (this.geojsons[card].coordinates.length <= 1) {
        const [lat, lng] = Object.values(this.geojsons[card].coordinates[0][0])
        this.map.flyTo({ center: [lat, lng], zoom: 28, speed: 0.5 });
      } else {
        this.map.flyTo({ center: [lat, lng], zoom: 28, speed: 0.5 });
      }

      document.getElementById(this.card).setAttribute('class', 'active container-text');
      document.getElementById(this.activeCardId).setAttribute('class', 'container-text');

      this.activeCardId = this.card;
    },
    isElementOnScreen(activeId) {
      this.element = document.getElementById(activeId);
      this.bounds = this.element.getBoundingClientRect();
      return this.bounds.top < window.innerHeight && this.bounds.bottom > 0;
    }
  }
};

</script>
