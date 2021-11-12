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
import "perspective-map";
import "leaflet/dist/leaflet.css";

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
    config: {
      type: Object,
      default: () => {}
    },
    configMap: {
      type: Object,
      default: () => {}
    },
    registrationDisabled: {
      type: Boolean,
      default: false
    },
    isUserLogged: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      prevConfig: this.config
    }
  },
  computed: {
    registrationDisabledAndUserIsLogged() {
      return !this.registrationDisabled || this.isUserLogged
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
  mounted() {
    this.viewer = this.$refs["perspective-viewer"];
    this.checkIfQueryResultIsEmpty(this.items)
    this.$root.$emit('showSavingDialogEventViz', false)
  },
  beforeDestroy() {
    document.removeEventListener("click", this.$emit("showSaving"));
    this.$root.$emit('showSavingDialogEventViz', false)
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

      this.viewer.setAttribute("columns", JSON.stringify(columns.split(",")))
      if (this.configMap) {
        this.viewer.setAttribute("config-map", JSON.stringify(this.configMap))
      }

      if (columns !== data) {
        this.checkPerspectiveTypes()
      } else {
        this.viewer.clear()
        // Well, it's a bit tricky, but reset the table with .clear() only responds when trigger an event,
        // if not trigger an event .clear() isn't fired
        window.dispatchEvent(new Event("resize"))
      }
    },
    async checkPerspectiveTypes() {
      //If columns contains Boolean values goes to replace them
      let data = this.items
      if (Object.values(this.objectColumns).some(value => value === "boolean")) {
        data = this.items.replace(/"t"/g, '"true"').replace(/"f"/g, '"false"')
      }

      if (this.config) {
        // requires wait for the config to be loaded
        await this.setConfig()
      }

      this.hideConfigButton()

      const table = perspective.worker().table(data);
      this.viewer.load(table)
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
    toggleConfigPerspective() {
      this.showVizzEditor()
      if (this.registrationDisabledAndUserIsLogged) {
        this.$root.$emit('showSavedVizString', false)
      }
    },
    hideConfigButton() {
      const configButtonPerspective = this.viewer.shadowRoot?.getElementById('config_button')
      configButtonPerspective.style.display = "none"
    },
    showVizzEditor() {
      this.viewer.toggleConfig()
      if (this.registrationDisabledAndUserIsLogged) {
        const shadowRootPerspective = document.querySelector('perspective-viewer').shadowRoot
        const selectVizPerspective = shadowRootPerspective.getElementById('vis_selector')
        selectVizPerspective.addEventListener('click', () => {
          this.$emit("showSaving")
          this.$root.$emit('isVizModified', true)
        })
        const sidePanelPerspective = shadowRootPerspective.getElementById("side_panel");
        sidePanelPerspective.addEventListener('click', () => {
          this.$emit("showSaving")
          this.$root.$emit('isVizModified', true)
        })
      }
    },
  }
};
</script>
