<template>
  <div class="gobierto-data-sql-editor-tabs">
    <div class="pure-g">
      <div
        class="pure-u-1"
        style="text-align: right; margin-bottom: 1rem"
      >
        <SavingDialog
          :placeholder="labelVisName"
          @save="onSaveEventHandler"
        />
        <DownloadButton
          :editor="true"
          :array-formats="arrayFormats"
          class="arrow-top modal-right"
        />
      </div>
    </div>

    <div class="gobierto-data-visualization--aspect-ratio-16-9">
      <Visualizations :items="items" />
    </div>
  </div>
</template>
<script>
import DownloadButton from "./../../commons/DownloadButton.vue";
import SavingDialog from "./../../commons/SavingDialog.vue";
import Visualizations from "./../../commons/Visualizations.vue";

export default {
  name: "SQLEditorResults",
  components: {
    Visualizations,
    DownloadButton,
    SavingDialog
  },
  props: {
    arrayFormats: {
      type: Object,
      required: true
    },
    items: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      labelTable: I18n.t("gobierto_data.projects.table") || "",
      labelVisualization: I18n.t("gobierto_data.projects.visualization") || "",
      labelVisName: I18n.t('gobierto_data.projects.visName') || "",
    };
  },
  methods: {
    onSaveEventHandler(opts) {
      // TODO: temporal
      this.$root.$emit("exportPerspectiveConfig", opts)
    }
  },
};
</script>
