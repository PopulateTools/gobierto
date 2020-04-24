<template>
  <perspective-viewer
    v-if="items"
    ref="perspective-viewer"
  />
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
    },
    arrayColumnsQuery: {
      type: Array,
      default: () => []
    },
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
    },
    arrayColumnsQuery(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.viewer.clear();
        this.viewer.setAttribute('columns', JSON.stringify(this.newValue))
        this.initPerspective(this.items);
      }
    }
  },
  mounted() {
    this.viewer = this.$refs["perspective-viewer"];
    this.initPerspective(this.items);
    this.listenerPerspective()
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
    enableDisabledPerspective(value) {
      const shadowRootPerspective = document.querySelector('perspective-viewer').shadowRoot
      const sidePanelPerspective = shadowRootPerspective.getElementById('side_panel')
      const topPanelPerspective = shadowRootPerspective.getElementById('top_panel')
      topPanelPerspective.style.display = value
      sidePanelPerspective.style.display = value
    },
    listenerPerspective() {
      const shadowRootPerspective = document.querySelector('perspective-viewer').shadowRoot
      const configButtonPerspective = shadowRootPerspective.getElementById('config_button')
      configButtonPerspective.style.display = "none"
      const selectVizPerspective = shadowRootPerspective.getElementById('vis_selector')
      const showDialog = this.showSavingDialog
      const sendSelectedValue = this.selectedValue
      let selectedValue

      selectVizPerspective.addEventListener('change', function() {
        selectedValue = selectVizPerspective.options[selectVizPerspective.selectedIndex].value;
        showDialog()
        sendSelectedValue(selectedValue)
      })
    },
    showSavingDialog() {
      this.$emit("showSaving")
    },
    selectedValue(chart) {
      this.$emit("selectedChart", chart)
    },
    setColumns() {
      this.viewer.setAttribute('columns', this.arrayColumnsQuery)
    }
  }
};
</script>
