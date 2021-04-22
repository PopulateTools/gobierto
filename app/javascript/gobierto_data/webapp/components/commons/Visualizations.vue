<template>
  <perspective-viewer
    v-if="items"
    ref="perspective-viewer"
  />
</template>
<script>
import perspective from "@finos/perspective";
import "@finos/perspective-viewer";
import "@finos/perspective-viewer-datagrid";
import "@finos/perspective-viewer-d3fc";
import "@finos/perspective-viewer/themes/all-themes.css";
import "lib/perspective-viewer-map";

export default {
  name: "Visualizations",
  props: {
    items: {
      type: String,
      default: ''
    },
    objectColumns: {
      type: Object,
      default: () => {}
    },
    metricMap: {
      type: String,
      default: ''
    },
    config: {
      type: Object,
      default: () => {}
    }
  },
  data() {
    return {
      prevConfig: this.config
    }
  },
  watch: {
    items(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.checkIfQueryResultIsEmpty(newValue)
      }
    },
    config() {
      this.setConfig()
    }
  },
  created() {
    this.worker = perspective.worker();
  },
  mounted() {
    this.viewer = this.$refs["perspective-viewer"];
    this.checkIfQueryResultIsEmpty(this.items)

    this.viewer.addEventListener('perspective-config-update', this.handleConfigUpdates)
  },
  beforeDestroy() {
    this.viewer.removeEventListener('perspective-config-update', this.handleConfigUpdates)
  },
  methods: {
    // You can run a query that gets an empty result, and this isn't an error. But if the result comes empty Perspective has no data to build the table, so console returns an error. We need to check if the result of the query is equal to the columns
    checkIfQueryResultIsEmpty(items) {
      // The result of the query, if returns empty only contains the columns.
      const data = items.trim()
      // Only the columns of the query.
      const [columns = ""] = items.split("\n");

      // Clean any previous config
      this.resetConfig();

      this.viewer.setAttribute('columns', JSON.stringify(columns.split(",")))
      if (this.metricMap) {
        this.viewer.setAttribute('metric', this.metricMap)
      }

      if (columns !== data) {
        this.checkPerspectiveTypes()
      } else {
        // Well, it's a bit tricky, but reset the table with .clear() only responds when trigger an event, if not trigger an event .clear() isn't fired
        window.dispatchEvent(new Event('resize'))
      }
    },
    async checkPerspectiveTypes() {
      //If columns contains Boolean values goes to replace them
      let data = this.items
      if (Object.values(this.objectColumns).some(value => value === "boolean")) {
        data = this.items.replace(/"t"/g, '"true"').replace(/"f"/g, '"false"')
      }

      const schema = this.objectColumns

      Object.keys(schema).forEach((key) => {
        if (['text', 'hstore', 'jsonb', 'tsvector'].includes(schema[key])) {
          schema[key] = 'string'
        } else if (schema[key] === 'decimal') {
          schema[key] = 'float'
        } else if (schema[key] === 'inet') {
          schema[key] = 'integer'
        } else if (schema[key] === 'date') {
          schema[key] = 'datetime'
        }
      });

      if (this.config) {
        // requires wait for the config to be loaded
        await this.setConfig()
      }

      this.hideConfigButton()

      this.worker.table(schema);
      this.viewer.load(data)
    },
    getConfig() {
      // export the visualization configuration object
      return this.viewer.save()
    },
    async setConfig() {
      this.viewer.restore(this.config);
    },
    resetConfig() {
      this.viewer.reset();
    },
    handleConfigUpdates() {
      // NOTE: instead of compare the full object, we can destructure it and trigger the event only on those changing values we care
      const config = this.getConfig()
      if (JSON.stringify(this.prevConfig) !== JSON.stringify(config)) {
        // don't emit event on the first load
        if (this.prevConfig) {
          this.$emit("showSaving")
        }
        this.prevConfig = config
      }
    },
    toggleConfigPerspective() {
      this.$root.$emit('showSavedVizString', false)
      this.viewer.toggleConfig()
    },
    hideConfigButton() {
      const configButtonPerspective = this.viewer.shadowRoot?.getElementById('config_button')
      configButtonPerspective.style.display = "none"
    }
  }
};
</script>
