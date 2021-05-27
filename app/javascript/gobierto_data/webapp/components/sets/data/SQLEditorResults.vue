<template>
  <div class="gobierto-data-sql-editor-tabs">
    <div
      class="pure-g"
      style="margin-bottom: 1rem;"
    >
      <div class="pure-u-1 pure-u-lg-4-4">
        <Button
          v-if="showResetViz"
          :title="labelResetViz"
          class="btn-sql-editor btn-sql-revert-viz"
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
          :label-saved="labelSavedVisualization"
          :label-modified="labelModifiedVizualition"
          :is-viz-saving-prompt-visible="isVizSavingPromptVisible"
          :is-viz-modified="isVizModified"
          :is-viz-saved="isVizSaved"
          :is-user-logged="isUserLogged"
          :enabled-viz-saved-button="enabledVizSavedButton"
          :show-private-public-icon-viz="showPrivatePublicIconViz"
          @save="onSaveEventHandler"
          @keyDownInput="updateVizNameHandler"
          @isPrivateChecked="isPrivateChecked"
        />
        <DownloadButton
          :editor="true"
          :query-stored="queryStored"
          :array-formats="arrayFormats"
          class="arrow-top modal-right"
        />
      </div>
      <transition
        name="fade"
        mode="out-in"
      >
        <div
          v-if="vizName && isVizSaved"
          class="gobierto-data-visualization-query-container"
        >
          <span class="gobierto-data-summary-queries-panel-title">{{ labelLink }}: </span>
          <router-link
            :to="`/datos/${$route.params.id}/v/${vizId}`"
            class="gobierto-data-summary-queries-container-name"
          >
            {{ vizName }}
          </router-link>
        </div>
      </transition>
    </div>

    <div class="gobierto-data-visualization--aspect-ratio-16-9">
      <Visualizations
        v-if="items"
        ref="viewer"
        :items="items"
        :object-columns="objectColumns"
        :config-map="configMapZoom"
        :config="config"
        @showSaving="showSavingDialog"
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
    objectColumns: {
      type: Object,
      default: () => {}
    },
    configMap: {
      type: Object,
      default: () => {}
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
    },
    showPrivatePublicIconViz: {
      type: Boolean,
      default: false
    },
    vizName: {
      type: String,
      default: ''
    },
    vizId: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      labelVisName: I18n.t('gobierto_data.projects.visName') || "",
      labelVisualize: I18n.t('gobierto_data.projects.visualize') || "",
      labelResetViz: I18n.t('gobierto_data.projects.resetViz') || "",
      labelModifiedVizualition: I18n.t("gobierto_data.projects.modifiedVisualization") || "",
      labelSavedVisualization: I18n.t("gobierto_data.projects.savedVisualization") || "",
      labelLink: I18n.t("gobierto_data.projects.link") || "",
      showVisualization: false,
      showResetViz: false,
      showVisualize: true,
      removeLabelBtn: false,
      perspectiveChanged: false,
      config: null,
      configMapZoom: { ...this.configMap, zoom: true }
    };
  },
  watch: {
    vizInputFocus(newValue) {
      if (newValue) {
        this.$nextTick(() => this.$refs.savingDialogViz.inputFocus())
      }
    }
  },
  mounted() {
    if (sessionStorage.getItem("map-tab")) {
      this.config = JSON.parse(sessionStorage.getItem("map-tab"))
      sessionStorage.removeItem("map-tab")

      // otherwise, it won't work ¬¬
      setTimeout(() => this.$refs.viewer.toggleConfigPerspective(), 20);
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
      this.showVisualize = true
      this.perspectiveChanged = false
      this.showResetViz = false

      this.$refs.viewer.toggleConfigPerspective();
      this.$refs.viewer.resetConfig()
      this.$root.$emit('resetVizEvent')
    },
    showChart() {
      this.showVisualization = true
      this.$refs.viewer.toggleConfigPerspective();
    },
    showSavingDialog() {
      this.perspectiveChanged = true
      this.showVisualize = false
      this.showResetViz = true
      this.$root.$emit('showSavingDialogEvent')
      this.$nextTick(() => this.$refs.savingDialogViz.inputFocus())
    },
    isPrivateChecked() {
      this.$root.$emit('eventIsVizModified', true)
    }
  },
};
</script>
