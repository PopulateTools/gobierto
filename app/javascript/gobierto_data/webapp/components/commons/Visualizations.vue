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
        this.updateValues(newValue)
      }
    }
  },
  mounted() {
    this.viewer = this.$refs["perspective-viewer"];
    this.initPerspective(this.items);
    console.log("this.items", this.items);
  },
  methods: {
    updateValues(values) {
      this.newColumns = []
      this.newColumns = Object.keys(values[0])
      if (JSON.stringify(this.newColumns) === JSON.stringify(this.initColumns)) {
        this.viewer.setAttribute('columns', JSON.stringify(this.newColumns))
        this.updatePerspectiveData(values)
      } else {
        this.viewer.setAttribute('columns', JSON.stringify(this.newColumns))
        this.updatePerspectiveColumns(values)
      }
    },
    initPerspective(data) {
      console.log("data", data);

      const table = perspective.worker().table(data);

      this.initColumns = Object.keys(data[0]);

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
      this.initColumns = this.newColumns;
    },
    getConfig() {
      // export the visualization configuration object
      return this.viewer.save()
    }
  }
};
</script>
