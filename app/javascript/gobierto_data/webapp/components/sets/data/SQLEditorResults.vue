<template>
  <div class="gobierto-data-sql-editor-tabs">
    <div class="pure-g">
      <div
        class="pure-u-1 pure-u-lg-3-4"
        style="margin-bottom: 1rem"
      >
        <Button
          v-if="showVisualization"
          :title="labelResetViz"
          class="btn-sql-editor"
          icon="home"
          color="var(--color-base)"
          background="#fff"
          @click.native="resetViz"
        />
        <Button
          :text="labelVisualize"
          :class="{ 'remove-label' : removeLabelBtn }"
          class="btn-sql-editor"
          icon="chart-area"
          color="var(--color-base)"
          background="#fff"
          @click.native="showChart"
        />
        <SavingDialog
          v-if="showVisualization"
          :placeholder="labelVisName"
          :label-save="labelSaveViz"
          @save="onSaveEventHandler"
        />

      </div>
      <div
        class="pure-u-1 pure-u-lg-1-4"
        style="margin-bottom: 1rem"
      >
        <DownloadButton
          :editor="true"
          :array-formats="arrayFormats"
          class="arrow-top modal-right"
        />
      </div>
    </div>

    <div class="gobierto-data-visualization--aspect-ratio-16-9">
      <Visualizations
        v-if="items"
        ref="viewer"
        :items="items"
        :type-chart="typeChart"
        :array-columns-query="arrayColumnsQuery"
      />
    </div>
  </div>
</template>
<script>
import Button from "./../../commons/Button.vue";
import DownloadButton from "./../../commons/DownloadButton.vue";
import SavingDialog from "./../../commons/SavingDialog.vue";
import Visualizations from "./../../commons/Visualizations.vue";

export default {
  name: "SQLEditorResults",
  components: {
    Visualizations,
    DownloadButton,
    Button,
    SavingDialog
  },
  props: {
    arrayFormats: {
      type: Object,
      required: true
    },
    arrayColumnsQuery: {
      type: Array,
      default: () => []
    },
    items: {
      type: String,
      default: ''
    }
  },
  data() {
    return {
      labelVisName: I18n.t('gobierto_data.projects.visName') || "",
      labelSaveViz: I18n.t('gobierto_data.projects.saveViz') || "",
      labelVisualize: I18n.t('gobierto_data.projects.visualize') || "",
      labelResetViz: I18n.t('gobierto_data.projects.resetViz') || "",
      showVisualization: false,
      removeLabelBtn: false,
      typeChart: 'hypergrid'
    };
  },
  created() {
    this.$root.$on('resetPerspective', this.resetViz)
  },
  beforeDestroy() {
    this.$root.$off('resetPerspective')
  },
  methods: {
    onSaveEventHandler(opts) {
      // get children configuration
      const config = this.$refs.viewer.getConfig()

      this.$root.$emit("storeCurrentVisualization", config, opts);
      this.removeLabelBtn = true
    },
    resetViz() {
      this.typeChart = 'hypergrid'
    },
    showChart() {
      this.showVisualization = true
      //Charts Perspective: y_line, hypegrid, xy_scatter, y_scatter, y_area, x_bar, y_bar, heatmap, sunburst, treemap, ohlc, candlestick
      this.typeChart = 'y_line'
    }
  },
};
</script>
