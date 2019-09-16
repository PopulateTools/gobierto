<template>
  <main>
    <keep-alive>
      <component v-bind:is="currentTabComponent" :items="items"></component>
    </keep-alive>
  </main>
</template>

<script>
import Map from "../../components/Map.vue";
import Gallery from "../../components/Gallery.vue";
import Table from "../../components/Table.vue";

export default {
  name: "HomeMain",
  components: {
    Map,
    Gallery,
    Table
  },
  props: {
    activeTab: Number,
    items: Array
  },
  data() {
    return {
      tabs: [],
      currentTabComponent: null
    };
  },
  created() {
    this.tabs = [Map, Gallery, Table];
    this.currentTabComponent = this.tabs[this.activeTab];
  },
  watch: {
    activeTab(tab) {
      this.currentTabComponent = this.tabs[tab];
    }
  }
};
</script>

