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
    config: {
      type: Object,
      default: () => {}
    }
  },
  watch: {
    items(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.initPerspective(newValue)
      }
    }
  },
  mounted() {
    this.viewer = this.$refs["perspective-viewer"];
    this.initPerspective(this.items);
  },
  methods: {
    initPerspective(data) {

      const table = perspective.worker().table(data);

      this.viewer.load(table);
      if (this.config) {
        this.viewer.restore(this.config);
      }
    },
    updatePerspectiveData(values) {
      this.viewer.clear();
      this.viewer.load(values);
    },
    updatePerspectiveColumns(values) {
      const table = perspective.worker().table(values);

      this.viewer.load(table);
    },
    getConfig() {
      // export the visualization configuration object
      return this.viewer.save()
    }
  }
};
</script>
