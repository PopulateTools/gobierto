<template>
  <div class="gobierto-data-sql-editor-tabs">
    <div class="pure-g">
      <div
        class="pure-u-1 pure-u-lg-3-4"
        style="margin-bottom: 1rem"
      >
        <Button
          v-if="showResetViz && isUserLogged"
          :title="labelResetViz"
          class="btn-sql-editor"
          icon="home"
          background="#fff"
          @click.native="resetViz"
        />
        <Button
          v-if="showVisualize"
          :text="labelVisualize"
          class="btn-sql-editor"
          icon="chart-area"
          background="#fff"
          @click.native="showChart"
        />
        <SavingDialog
          v-if="perspectiveChanged"
          ref="savingDialogViz"
          :placeholder="labelVisName"
          :label-save="labelSaveViz"
          :label-saved="labelSavedVisualization"
          :label-modified="labelModifiedVizualition"
          :is-viz-saving-prompt-visible="isVizSavingPromptVisible"
          :is-viz-modified="isVizModified"
          :is-viz-saved="isVizSaved"
          :is-user-logged="isUserLogged"
          :enabled-viz-saved-button="enabledVizSavedButton"
          @save="onSaveEventHandler"
          @keyDownInput="updateVizNameHandler"
        />
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
    isVizSavingPromptVisible: {
      type: Boolean,
      default: false
    },
    isVizModified: {
      type: Boolean,
      default: false
    },
    isVizSaved: {
      type: Boolean,
      default: false
    },
    enabledVizSavedButton: {
      type: Boolean,
      default: false
    },
    queryStored: {
      type: String,
      default: ""
    },
    isUserLogged: {
      type: Boolean,
      default: false
    },
    vizInputFocus: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      labelVisName: I18n.t('gobierto_data.projects.visName') || "",
      labelSaveViz: I18n.t('gobierto_data.projects.saveViz') || "",
      labelVisualize: I18n.t('gobierto_data.projects.visualize') || "",
      labelResetViz: I18n.t('gobierto_data.projects.resetViz') || "",
      labelModifiedVizualition: I18n.t("gobierto_data.projects.modifiedVisualization") || "",
      labelSavedVisualization: I18n.t("gobierto_data.projects.savedVisualization") || "",
      showVisualization: false,
      showResetViz: false,
      showVisualize: true,
      removeLabelBtn: false,
      perspectiveChanged: false,
      typeChart: 'hypergrid',
    };
  },
  watch: {
    vizInputFocus(newValue) {
      if (newValue) {
        this.$nextTick(() => this.$refs.savingDialogViz.inputFocus())
      }
    }
  },
  methods: {
    onSaveEventHandler(opts) {
      // get children configuration
      const config = this.$refs.viewer.getConfig()
      this.$root.$emit("storeCurrentVisualization", config, opts);
    },
    updateVizNameHandler(value) {
      const {
        name: vizName
      } = value;
      this.labelValue = vizName
      this.$root.$emit("eventIsVizModified", true);
    },
    resetViz() {
      const hidePerspective = "none"

      this.showVisualize = true
      this.perspectiveChanged = false
      this.showResetViz = false
      this.typeChart = 'hypergrid'

      this.$refs.viewer.enableDisabledPerspective(hidePerspective);
      this.$refs.viewer.setColumns();
      this.$root.$emit('resetVizEvent')
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
      this.$root.$emit('showSavingDialogEvent')
      this.$nextTick(() => this.$refs.savingDialogViz.inputFocus())
    }
  },
};
</script>
