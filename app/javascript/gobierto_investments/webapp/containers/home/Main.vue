<template>
  <main>
    <keep-alive>
      <component
        :is="currentTabComponent"
        :items="items"
      />
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
    activeTab: {
      type: Number,
      default: 0
    },
    items: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      tabs: [],
      currentTabComponent: null
    };
  },
  watch: {
    activeTab(tab) {
      this.currentTabComponent = this.tabs[tab];
    }
  },
  created() {
    this.tabs = [Map, Gallery, Table];
    this.currentTabComponent = this.tabs[this.activeTab];
  }
};
</script>

