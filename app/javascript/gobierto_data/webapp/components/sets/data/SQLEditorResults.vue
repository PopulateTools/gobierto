<template>
  <div class="gobierto-data-sql-editor-tabs">
    <div class="pure-g">
      <div
        class="pure-u-1 pure-u-lg-3-4"
        style="margin-bottom: 1rem"
      >
        <Button
          v-if="showResetViz"
          :title="labelResetViz"
          class="btn-sql-editor"
          icon="home"
          color="var(--color-base)"
          background="#fff"
          @click.native="resetViz"
        />
        <Button
          v-if="showVisualize"
          :text="labelVisualize"
          :class="{ 'remove-label' : removeLabelBtn }"
          class="btn-sql-editor"
          icon="chart-area"
          color="var(--color-base)"
          background="#fff"
          @click.native="showChart"
        />
        <SavingDialog
          v-if="perspectiveChanged"
          :placeholder="labelVisName"
          :label-save="labelSaveViz"
          @save="onSaveEventHandler"
          @resetButtonViz="resetButtonViz"
        />
        <div
          v-if="isVisualizationModified"
          class="gobierto-data-sql-editor-modified-label-container"
        >
          <span class="gobierto-data-sql-editor-modified-label">
            {{ labelModifiedVizualition }}
          </span>
        </div>
      </div>
      <div
        class="pure-u-1 pure-u-lg-1-4"
        style="margin-bottom: 1rem"
      >
        <DownloadButton
          :editor="true"
          :query-stored="queryStored"
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
        @showSaving="showSavingDialog"
        @selectedChart="typeChart = $event"
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
    },
    queryStored: {
      type: String,
      default: ""
    }
  },
  data() {
    return {
      labelVisName: I18n.t('gobierto_data.projects.visName') || "",
      labelSaveViz: I18n.t('gobierto_data.projects.saveViz') || "",
      labelVisualize: I18n.t('gobierto_data.projects.visualize') || "",
      labelResetViz: I18n.t('gobierto_data.projects.resetViz') || "",
      labelModifiedVizualition: I18n.t("gobierto_data.projects.modifiedVisualization") || "",
      showVisualization: false,
      isVisualizationModified: false,
      showResetViz: false,
      showVisualize: true,
      removeLabelBtn: false,
      perspectiveChanged: false,
      typeChart: 'hypergrid'
    };
  },
  methods: {
    onSaveEventHandler(opts) {
      // get children configuration
      const config = this.$refs.viewer.getConfig()

      this.$root.$emit("storeCurrentVisualization", config, opts);
      this.removeLabelBtn = true
      this.isVisualizationModified = false
    },
    resetViz() {
      const hidePerspective = "none"

      this.showVisualize = true
      this.perspectiveChanged = false
      this.removeLabelBtn = false
      this.showResetViz = false
      this.typeChart = 'hypergrid'
      this.isVisualizationModified = false

      this.$refs.viewer.enableDisabledPerspective(hidePerspective);
      this.$refs.viewer.setColumns();
    },
    showChart() {
      const showPerspective = "flex"

      this.showVisualization = true
      this.$refs.viewer.enableDisabledPerspective(showPerspective);
    },
    showSavingDialog() {
      this.perspectiveChanged = true
      this.showVisualize = false
      this.showResetViz = true
      this.isVisualizationModified = true
    },
    resetButtonViz() {
      this.removeLabelBtn = false
      this.showResetViz = true
    }
  },
};
</script>
