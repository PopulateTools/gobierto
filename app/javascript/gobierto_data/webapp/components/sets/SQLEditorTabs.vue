<template>
  <div class="pure-g gobierto-data-sql-editor-tabs">
    <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column gobierto-data-layout-sidebar">
      <nav class="gobierto-data-tabs-sidebar">
        <ul>
          <li
            :class="{ 'is-active': activeTab === 0 }"
            class="gobierto-data-tab-sidebar--tab"
            @click="activateTab(0)"
          >
            <i
              class="fas fa-table"
            />
            <span>{{ labelTable }}</span>
          </li>
          <li
            :class="{ 'is-active': activeTab === 1 }"
            class="gobierto-data-tab-sidebar--tab"
            @click="activateTab(1)"
          >
            <i
              class="fas fa-chart-line"
            />
            <span>{{ labelVisualization }}</span>
          </li>
        </ul>
      </nav>
    </div>
    <div class="pure-u-lg-1-4">
      <keep-alive>
        <DownloadButton
          :editor="true"
          :array-formats="arrayFormats"
          :class="[
            directionLeft ? 'modal-left': 'modal-right'
          ]"
          class="arrow-top"
        />
      </keep-alive>
    </div>
    <SQLEditorTable
      v-if="activeTab === 0"
      :items="items"
      :number-rows="numberRows"
      :table-name="tableName"
    />
    <SQLEditorVisualizations v-if="activeTab === 1" />
  </div>
</template>
<script>
import SQLEditorTable from "./SQLEditorTable.vue";
import SQLEditorVisualizations from "./SQLEditorVisualizations.vue";
import DownloadButton from "./../commons/DownloadButton.vue";
export default {
  name: "SQLEditorTabs",
  components: {
    SQLEditorTable,
    SQLEditorVisualizations,
    DownloadButton
  },
  props: {
    activeTab: {
      type: Number,
      default: 0
    },
    arrayFormats: {
      type: Object,
      required: true
    },
    numberRows: {
      type: Number,
      required: true
    },
    items: {
      type: Array,
      default: () => []
    },
    tableName: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      labelTable: "",
      labelVisualization: "",
      directionLeft: false,
      editorFocus: false
    }
  },
  created() {
    this.labelTable = I18n.t("gobierto_data.projects.table")
    this.labelVisualization = I18n.t("gobierto_data.projects.visualization")
    this.$root.$on('blurEditor', this.activateShortcutsListener)
    this.$root.$on('focusEditor', this.removeShortcutsListener)
    this.activateShortcutsListener()
  },
  methods: {
    shortcutsListener(e) {
      if (e.keyCode == 84) {
        this.$emit("active-tab", 0)
      } else if (e.keyCode == 86) {
        this.$emit("active-tab", 1);
      }
    },
    activateShortcutsListener(){
      window.addEventListener("keydown", this.shortcutsListener, true);
    },
    removeShortcutsListener(){
      window.removeEventListener("keydown", this.shortcutsListener, true);
    },
    activateTab(index) {
      this.$emit("active-tab", index);
    }
  }
}
</script>
