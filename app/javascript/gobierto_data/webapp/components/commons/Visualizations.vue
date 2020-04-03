<template>
  <perspective-viewer ref="perspective-viewer" />
</template>
<script>
// TODO: mover este componente a commons
import perspective from "@finos/perspective";
import "@finos/perspective-viewer";
import "@finos/perspective-viewer-hypergrid";
import "@finos/perspective-viewer-d3fc";
import "@finos/perspective-viewer/themes/all-themes.css";

export default {
  name: "Visualizations",
  props: {
    items: {
      type: Array,
      default: () => []
    },
    config: {
      type: Object,
      default: () => {}
    }
  },
  watch: {
    items(newValue, oldValue) {
      if (JSON.stringify(newValue) !== JSON.stringify(oldValue)) {
        this.updateValues(newValue)
      }
    }
  },
  created() {
    this.$root.$on("exportPerspectiveConfig", this.exportPerspectiveConfig);
  },
  mounted() {
    this.viewer = this.$refs["perspective-viewer"];
    this.initPerspective(this.items);
  },
  beforeDestroy() {
    this.$root.$off("exportPerspectiveConfig", this.exportPerspectiveConfig);
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
    exportPerspectiveConfig(opts) {
      const config = this.viewer.save()
      this.$root.$emit("saveVisualization", config, opts);
    }
  }
};
</script>
