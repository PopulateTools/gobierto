<template>
  <div class="gobierto-data-sql-editor">
    <div class="pure-g">
      <div class="pure-u-1 pure-u-lg-4-4">
        <SavingDialog
          ref="savingDialogVizElement"
          :value="name"
          :label-save="labelSaveViz"
          :label-saved="labelSavedVisualization"
          :label-modified="labelModifiedVizualition"
          :is-viz-saving-prompt-visible="isVizSavingPromptVisible"
          :is-viz-modified="isVizModified"
          :is-viz-saved="isVizSaved"
          :is-user-logged="isUserLogged"
          :enabled-fork-viz-button="enabledForkVizButton"
          :enabled-viz-saved-button="enabledVizSavedButton"
          :is-query-saving-prompt-visible="isQuerySavingPromptVisible"
          :show-private-public-icon-viz="showPrivatePublicIconViz"
          :show-private-viz="showPrivateViz"
          @save="onSaveEventHandler"
          @keyDownInput="updateVizName"
          @handlerFork="handlerForkViz"
        />
        <Button
          :text="labelEdit"
          class="btn-sql-editor"
          icon="chart-area"
          background="#fff"
          @click.native="showChart"
        />
      </div>
      <div
        v-if="queryID"
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
      <Visualizations
        v-if="items"
        ref="viewer"
        :items="items"
        :config="config"
        @showSaving="showSavingDialog"
        @selectedChart="typeChart = $event"
      />
    </div>
  </div>
</template>
<script>
import Visualizations from "./../commons/Visualizations.vue";
import SavingDialog from "./../commons/SavingDialog.vue";
import Button from "./../commons/Button.vue";
import { getUserId } from "./../../../lib/helpers";

export default {
  name: "VisualizationsItem",
  components: {
    Visualizations,
    SavingDialog,
    Button
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
    }
  },
  data() {
    return {
      labelVisName: I18n.t('gobierto_data.projects.visName') || "",
      labelEdit: I18n.t('gobierto_data.projects.edit') || "",
      labelSaveViz: I18n.t('gobierto_data.projects.saveViz') || "",
      labelVisualize: I18n.t('gobierto_data.projects.visualize') || "",
      labelDashboard: I18n.t('gobierto_data.projects.dashboards') || "",
      labelSavedVisualization: I18n.t("gobierto_data.projects.savedVisualization") || "",
      labelModifiedVizualition: I18n.t("gobierto_data.projects.modifiedVisualization") || "",
      labelQuery: I18n.t("gobierto_data.projects.query") || "",
      items: null,
      config: {},
      vizID: null,
      queryID: '',
      queryName: '',
      user: null,
      queryViz: '',
      isVizElementSavingVisible: false,
      name: '',
      isQuerySavingPromptVisible: false
    }
  },
  watch: {
    vizInputFocus(newValue) {
      if (newValue) {
        this.$nextTick(() => this.$refs.savingDialogVizElement.inputFocus())
      }
    },
    $route(to, from) {
      if (to.path !== from.path) {
        this.$root.$emit("isVizModified", false);
        this.$root.$emit('disabledSavedVizString')
        this.$root.$emit('enabledForkVizButton', false)
      }
    }
  },
  created() {
    const userId = getUserId()
    this.getDataVisualization(this.publicVisualizations);
    //Only getPrivate if user load a PrivateViz
    if (userId && this.showPrivateViz) {
      this.getDataVisualization(this.privateVisualizations);
    }
  },
  beforeDestroy() {
    //Hide the string, and the buttons return to their initial state.
    this.$root.$emit("isVizModified", false);
    this.$root.$emit('disabledSavedVizString')
    this.$root.$emit('enableSavedVizButton', false)
  },
  methods: {
    onSaveEventHandler(opts) {
      //Add visualization ID to opts object, we need it to update a viz saved
      opts.vizID = Number(this.vizID)
      opts.user = Number(this.user)
      opts.queryID = Number(this.queryID)
      opts.queryViz = this.queryViz
      // get children configuration
      const config = this.$refs.viewer.getConfig()

      this.$root.$emit("storeCurrentVisualization", config, opts);
    },
    updateVizName(value) {
      const {
        name: vizName
      } = value;
      this.labelValue = vizName
      this.$root.$emit('updateVizName')
    },
    showChart() {
      this.$root.$emit('disabledSavedVizString')
      this.$refs.viewer.toggleConfigPerspective();
    },
    showSavingDialog() {
      this.showVisualize = false
      this.showResetViz = true
      //Enable saved button
      this.$root.$emit('showSavingDialogEvent')
      this.$nextTick(() => this.$refs.savingDialogVizElement.inputFocus())
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
      const { attributes: { name: queryName } = {} } = this.privateQueries.find(({ id }) => id == queryID) || {}

      this.vizID = vizID
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
    }
  }
};
</script>
