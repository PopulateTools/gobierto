<template>
  <perspective-viewer v-if="items" ref="perspective-viewer" />
</template>
<script>
import perspective from "@finos/perspective";
import "@finos/perspective-viewer";
import "@finos/perspective-viewer-hypergrid";
import "@finos/perspective-viewer-d3fc";
import "@finos/perspective-viewer/themes/all-themes.css";

export default {
  name: "Visualizations",
  props: {
    items: {
      type: String,
      default: ''
    },
    typeChart: {
      type: String,
      default: ''
    }
  },
  watch: {
    items(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.initPerspective(newValue)
      }
    },
    typeChart(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.viewer.setAttribute('plugin', newValue)
      }
    }
  },
  mounted() {
    this.viewer = this.$refs["perspective-viewer"];
    this.initPerspective(this.items);
  },
  methods: {
    initPerspective(data) {
      this.viewer.setAttribute('plugin', this.typeChart)
      this.viewer.clear();
      const table = perspective.worker().table(data);

      this.viewer.load(table);
      if (this.config) {
        this.viewer.restore(this.config);
      }
    },
    getConfig() {
      // export the visualization configuration object
      return this.viewer.save()
    },
    resetViz() {
      this.viewer.delete();
    }
  }
};
</script>
