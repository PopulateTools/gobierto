<template>
  <div class="gobierto-data-visualization--aspect-ratio-16-9">
    <Visualizations
      ref="viewer"
      class="gobierto-data-visualization--item"
      :items="items"
      :type-chart="'map'"
      :config="config"
      :object-columns="objectColumns"
      :geom-column="geomColumn"
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
    geomColumn: {
      type: String,
      default: ""
    }
  },
  data() {
    return {
      config: {}
    }
  },
  mounted() {
    // this.$nextTick(() => this.$refs.viewer.toggleConfigPerspective());
    // this.$refs.viewer._side_panel.style = "block"
  }
};
</script>
