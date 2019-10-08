<template>
  <div style="background: #eee; min-height: 500px" />
  <!-- <div id="mapid" style="background: #eee"></div> -->
</template>

<script>
import "leaflet";

export default {
  name: "Map",
  mounted() {
    // var mymap = L.map("mapid").setView([40, -3], 8);
    // L.tileLayer("http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
    //   maxZoom: 18,
    //   attribution:
    //     'Map data &copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, ' +
    //     '<a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>'
    // }).addTo(mymap);
  }
};
</script>