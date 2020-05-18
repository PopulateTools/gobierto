<template>
  <div class="gobierto-data-sql-editor">
    <template v-if="privateVisualizations.length || publicVisualizations.length">
      <div class="pure-g">
        <div
          class="pure-u-1 pure-u-lg-3-4"
          style="margin-bottom: 1rem"
        >
          <h2 class="gobierto-data-visualitzation-element-title">
            {{ name }}
          </h2>
        </div>
        <div
          class="pure-u-1 pure-u-lg-1-4"
          style="margin-bottom: 1rem"
        >
          <Button
            :text="labelEdit"
            class="btn-sql-editor"
            icon="chart-area"
            color="var(--color-base)"
            background="#fff"
            @click.native="showChart"
          />
          <Button
            :text="labelDashboard"
            class="btn-sql-editor"
            icon="th"
            color="var(--color-base)"
            background="#fff"
            @click.native="goToDashboard"
          />
        </div>
      </div>
      <div
        v-if="isVizElementSavingVisible"
        class="pure-g"
      >
        <div
          class="pure-u-1 pure-u-lg-4-4"
          style="margin-bottom: 1rem"
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
            :enabled-viz-saved-button="enabledVizSavedButton"
            @save="onSaveEventHandler"
            @keyDownInput="updateVizName"
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
      items: null,
      config: {},
      vizID: null,
      user: null,
      queryViz: '',
      isVizElementSavingVisible: false,
      name: '',
      tabs
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
  methods: {
    onSaveEventHandler(opts) {
      //Add visualization ID to opts object, we need it to update a viz savedlaputaelite
      opts.vizID = Number(this.vizID)
      opts.user = Number(this.user)
      opts.queryViz = Number(this.queryViz)
      // get children configuration
      const config = this.$refs.viewer.getConfig()

      if (!this.isVizSavingPromptVisible) {
        this.$root.$emit("isVizSavingPromptVisible", true);
        this.$nextTick(() => this.$refs.savingDialogVizElement.inputFocus());
      } else {
        if (!this.name) {
          this.$nextTick(() => this.$refs.savingDialogVizElement.inputFocus())
        } else {
          this.$root.$emit("storeCurrentVisualization", config, opts);
        }
      }
    },
    updateVizName(value) {
      const {
        name: vizName
      } = value;
      this.labelValue = vizName
      this.$root.$emit('isVizModified')
      this.$root.$emit('enableSavedVizButton')
      this.$root.$emit('disabledSavedVizString')
    },
    showChart() {
      this.isVizElementSavingVisible = true
      const showPerspective = "flex"
      this.$root.$emit('disabledSavedVizString')
      this.$refs.viewer.enableDisabledPerspective(showPerspective);
    },
    showSavingDialog() {
      this.showVisualize = false
      this.showResetViz = true
      this.$root.$emit('enableSavedVizButton')
      this.$root.$emit("isVizSavingPromptVisible", true);
      this.$root.$emit("isVizModified");
      this.$root.$emit('disabledSavedVizString')
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
    goToDashboard() {
      this.$emit('changeViz', 0)
      this.$router.push({ path: `/datos/${this.$route.params.id}/${tabs[3]}` })
    }
  }
};
</script>
