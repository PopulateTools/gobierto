<template>
  <div class="gobierto-data-visualization--aspect-ratio-16-9">
    <Visualizations
      ref="viewer"
      class="gobierto-data-visualization--item"
      :items="items"
      :config="config"
      :object-columns="objectColumns"
      :metric-map="metricMap"
      @showSaving="handleConfig"
    />
  </div>
</template>
<script>
import Visualizations from "../commons/Visualizations.vue";

export default {
  name: "MapTab",
  components: {
    Visualizations
  },
  props: {
    items: {
      type: String,
      default: ""
    },
    objectColumns: {
      type: Object,
      default: () => {}
    },
    metricMap: {
      type: String,
      default: ""
    }
  },
  data() {
    return {
      config: {
        plugin: 'map'
      }
    }
  },
  mounted() {
    if (sessionStorage.getItem("map-tab")) {
      this.config = JSON.parse(sessionStorage.getItem("map-tab"))
      // sessionStorage.removeItem("map-tab")
    }

    // otherwise, it won't work ¬¬
    setTimeout(() => this.$refs.viewer.toggleConfigPerspective(), 20);
  },
  methods: {
    handleConfig() {
      const config = this.$refs.viewer.getConfig()
      sessionStorage.setItem("map-tab", JSON.stringify(config))
    }
  }
};
</script>
