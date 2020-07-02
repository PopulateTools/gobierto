<template>
  <div class="gobierto-data-sql-editor">
    <template v-if="isPrivateVizLoading">
      <Loading />
    </template>
    <template v-else>
      <div class="pure-g">
        <div
          class="pure-u-1 pure-u-lg-4-4"
          style="margin-bottom: 1rem;"
        >
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
    </template>
  </div>
</template>
<script>
import { Loading } from "lib/vue-components";
import Visualizations from "./../commons/Visualizations.vue";
import SavingDialog from "./../commons/SavingDialog.vue";
import Button from "./../commons/Button.vue";
import { getUserId } from "./../../../lib/helpers";
import { tabs } from '../../../lib/router';

export default {
  name: "VisualizationsItem",
  components: {
    Visualizations,
    SavingDialog,
    Button,
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
    isPrivateVizLoading: {
      type: Boolean,
      default: false
    },
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
      items: null,
      config: {},
      vizID: null,
      user: null,
      queryViz: '',
      isVizElementSavingVisible: false,
      name: '',
      isQuerySavingPromptVisible: false,
      tabs
    }
  },
  computed: {
    checkVisualizationsItems() {
      return (this.privateVisualizations.length && this.items) || (this.publicVisualizations.length && this.items)
    }
  },
  watch: {
    publicVisualizations(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.getDataVisualization(newValue);
      }
    },
    privateVisualization(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.getDataVisualization(newValue);
      }
    },
    vizInputFocus(newValue) {
      if (newValue) {
        this.$nextTick(() => this.$refs.savingDialogVizElement.inputFocus())
      }
    },
    async $route(to, from) {
      if (to.path !== from.path) {
        await this.getDataVisualization(this.privateVisualizations);
        await this.getDataVisualization(this.publicVisualizations);
      }
    }
  },
  async created() {
    const userId = getUserId()
    if (userId) {
      await this.getDataVisualization(this.privateVisualizations);
      await this.getDataVisualization(this.publicVisualizations);
    } else {
      await this.getDataVisualization(this.publicVisualizations);
    }
  },
  beforeDestroy() {
    //Hide the string, and the buttons return to their initial state.
    this.$root.$emit("isVizModified", false);
    this.$root.$emit('disabledSavedVizString')
  },
  methods: {
    onSaveEventHandler(opts) {
      //Add visualization ID to opts object, we need it to update a viz saved
      opts.vizID = Number(this.vizID)
      opts.user = Number(this.user)
      opts.queryViz = Number(this.queryViz)
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
        sql: sql
      } = objectViz

      this.vizID = vizID
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
