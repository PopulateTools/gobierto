<template>
  <div
    v-if="items"
    class="gobierto-data-sql-editor"
  >
    <div class="pure-g">
      <div class="pure-u-1 pure-u-lg-4-4">
        <SavingDialog
          ref="savingDialogVizElement"
          :value="name"
          :placeholder="labelVisName"
          :label-saved="labelSavedVisualization"
          :label-modified="labelModifiedVizualition"
          :is-viz-saving-prompt-visible="isVizSavingPromptVisible"
          :is-viz-modified="isVizModified"
          :is-viz-saved="isVizSaved"
          :is-viz-item-modified="isVizItemModified"
          :is-user-logged="isUserLogged"
          :enabled-fork-viz-button="enabledForkVizButton"
          :enabled-viz-saved-button="enabledVizSavedButton"
          :is-query-saving-prompt-visible="isQuerySavingPromptVisible"
          :show-private-public-icon-viz="showPrivatePublicIconViz"
          :show-private-viz="showPrivateViz"
          :show-label-edit="showLabelEdit"
          :reset-private="resetPrivate"
          @save="onSaveEventHandler"
          @keyDownInput="updateVizName"
          @handlerFork="handlerForkViz"
          @isPrivateChecked="isPrivateChecked"
          @showToggleConfig="showPromptSaveViz"
          @handlerRevertViz="hidePromptSaveViz"
        />
      </div>
      <div
        v-if="queryName"
        class="gobierto-data-visualization-query-container"
      >
        <span class="gobierto-data-summary-queries-panel-title">{{ labelQuery }}:</span>
        <router-link
          :to="`/datos/${$route.params.id}/q/${queryID}`"
          class="gobierto-data-summary-queries-container-name"
        >
          {{ queryName }}
        </router-link>
      </div>
    </div>
    <div class="gobierto-data-visualization--aspect-ratio-16-9">
      <template v-if="saveLoader">
        <Loading />
      </template>
      <template v-else>
        <Visualizations
          v-if="items"
          ref="viewer"
          class="gobierto-data-visualization--item"
          :items="items"
          :config="config"
          :object-columns="objectColumns"
          :config-map="configMapZoom"
          @showSaving="showSavingDialog"
        />
      </template>
    </div>
  </div>
</template>
<script>
import { Loading } from "lib/vue/components";
import Visualizations from "./../commons/Visualizations.vue";
import SavingDialog from "./../commons/SavingDialog.vue";
import { getUserId } from "./../../../lib/helpers";

export default {
  name: "VisualizationsItem",
  components: {
    Visualizations,
    SavingDialog,
    Loading
  },
  props: {
    datasetId: {
      type: Number,
      required: true
    },
    isUserLogged: {
      type: Boolean,
      default: false
    },
    privateVisualizations: {
      type: Array,
      default: () => []
    },
    publicVisualizations: {
      type: Array,
      default: () => []
    },
    privateQueries: {
      type: Array,
      default: () => []
    },
    publicQueries: {
      type: Array,
      default: () => []
    },
    isVizModified: {
      type: Boolean,
      default: false
    },
    isVizSaved: {
      type: Boolean,
      default: false
    },
    isVizSavingPromptVisible: {
      type: Boolean,
      default: false
    },
    enabledVizSavedButton: {
      type: Boolean,
      default: false
    },
    enabledForkVizButton: {
      type: Boolean,
      default: true
    },
    vizInputFocus: {
      type: Boolean,
      default: false
    },
    showPrivatePublicIconViz: {
      type: Boolean,
      default: false
    },
    showPrivateViz: {
      type: Boolean,
      default: false
    },
    showPrivate: {
      type: Boolean,
      default: false
    },
    showLabelEdit: {
      type: Boolean,
      default: false
    },
    isVizItemModified: {
      type: Boolean,
      default: false
    },
    resetPrivate: {
      type: Boolean,
      default: false
    },
    vizId: {
      type: Number,
      default: 0
    },
    userSaveViz: {
      type: Number,
      default: 0
    },
    objectColumns: {
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
    }
  },
  data() {
    return {
      labelVisName: I18n.t('gobierto_data.projects.visName') || "",
      labelVisualize: I18n.t('gobierto_data.projects.visualize') || "",
      labelDashboard: I18n.t('gobierto_data.projects.dashboards') || "",
      labelSavedVisualization: I18n.t("gobierto_data.projects.savedVisualization") || "",
      labelModifiedVizualition: I18n.t("gobierto_data.projects.modifiedVisualization") || "",
      labelQuery: I18n.t("gobierto_data.projects.query") || "",
      items: null,
      config: {},
      vizSaveID: null,
      queryID: '',
      queryName: '',
      user: null,
      queryViz: '',
      isVizElementSavingVisible: false,
      name: '',
      isQuerySavingPromptVisible: false,
      saveLoader: false,
      configMapZoom: { ...this.configMap, zoom: true }
    }
  },
  computed: {
    registrationDisabledAndUserIsLogged() {
      return !this.registrationDisabled || this.isUserLogged
    }
  },
  watch: {
    vizInputFocus(newValue) {
      if (newValue) {
        this.$nextTick(() => this.$refs.savingDialogVizElement.inputFocus())
      }
    },
    isVizSaved(newValue) {
      if (newValue) {
        this.saveLoader = false
      }
    },
    showPrivateViz(newValue) {
      if (newValue) {
        this.getDataVisualization(this.privateVisualizations);
      }
    },
    vizId(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.vizSaveID = newValue
      }
    },
    userSaveViz(newValue) {
      this.user = newValue
    }
  },
  created() {
    this.$root.$emit("showSavedVizString", false);
    const userId = getUserId()
    this.getDataVisualization(this.publicVisualizations);
    //Only getPrivate if user load a PrivateViz
    if (userId && this.showPrivateViz) {
      this.getDataVisualization(this.privateVisualizations);
    }
  },
  mounted() {
    this.currentConfigChart = this.$refs.viewer.getConfig()
  },
  beforeDestroy() {
    //Hide the string, and the buttons return to their initial state.
    this.$root.$emit("isVizModified", false);
    this.$root.$emit("showSavedVizString", false);
    this.$root.$emit('enabledForkVizButton', false)
    this.$root.$emit('showSavingDialogEventViz', false)
  },
  methods: {
    onSaveEventHandler(opts) {
      this.saveLoader = true
      //Add visualization ID to opts object, we need it to update a viz saved
      opts.vizID = Number(this.vizSaveID)
      opts.user = Number(this.user)
      opts.queryID = Number(this.queryID)
      opts.queryViz = this.queryViz
      // get children configuration
      const config = this.$refs.viewer.getConfig()
      this.$root.$emit("storeCurrentVisualization", config, opts);
      this.hidePromptSaveViz()

      const { plugin: updateConfigPlugin } = config
      const { plugin: currentConfigPlugin } = this.currentConfigChart
      /* When saving a query, checks if the type of chart is changed.
        If the chart change, we need to reload the visualization to
        show the new type of chart.*/
      if (updateConfigPlugin !== currentConfigPlugin) {
        this.$root.$emit("reloadVisualizations")
        this.saveLoader = false
      }
    },
    updateVizName(value) {
      const {
        name: vizName
      } = value;
      this.labelValue = vizName
      if (this.registrationDisabledAndUserIsLogged()) {
        this.$root.$emit('updateVizName')
      }
    },
    showSavingDialog() {
      if (this.registrationDisabledAndUserIsLogged()) {
        this.showVisualize = false
        this.showResetViz = true
        //Enable saved button
        this.$root.$emit('showSavingDialogEvent')
        this.$nextTick(() => this.$refs.savingDialogVizElement.inputFocus())
      }
    },
    getDataVisualization(data) {
      const {
        params: { queryId }
      } = this.$route;

      const objectViz = data.find(({ id }) => id === queryId) || {}

      const {
        items: elements,
        config: config,
        name: name,
        id: vizID,
        user_id: user_id,
        sql: sql,
        query_id: queryID
      } = objectViz

      //Find the query associated to the visualization
      const itemQueries = this.showPrivateViz ? this.privateQueries : this.publicQueries
      const { attributes: { name: queryName } = {} } = itemQueries.find(({ id }) => id == queryID) || {}

      this.vizSaveID = vizID
      this.queryID = queryID
      this.queryName = queryName
      this.user = user_id
      this.name = name
      this.config = config
      this.items = elements
      this.queryViz = sql
    },
    handlerForkViz() {
      this.$nextTick(() => {
        this.$refs.savingDialogVizElement.inputFocus()
        this.$refs.savingDialogVizElement.inputSelect()
      });
      this.$root.$emit('enabledForkVizButton', false)
      this.$refs.viewer.toggleConfigPerspective();
      this.$root.$emit('showSavingDialogEventViz', true)
    },
    isPrivateChecked() {
      this.$root.$emit('isVizModified', true)
    },
    showPromptSaveViz() {
      this.$refs.viewer.toggleConfigPerspective();
      if (this.registrationDisabledAndUserIsLogged()) {
        this.$root.$emit('showSavingDialogEventViz', true)
      }
    },
    hidePromptSaveViz() {
      this.$refs.viewer.toggleConfigPerspective();
      if (this.registrationDisabledAndUserIsLogged()) {
        this.$root.$emit('showSavingDialogEventViz', false)
        this.$root.$emit('enableSavedVizButton', false)
        this.$root.$emit("isVizModified", false);
      }
    },
  }
};
</script>
