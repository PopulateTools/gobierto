<template>
  <div class="gobierto-data-sql-editor-tabs">
    <div class="pure-g">
      <div
        class="pure-u-1 pure-u-lg-1-3 gobierto-data-layout-column gobierto-data-layout-sidebar"
      >
        <nav class="gobierto-data-tabs-sidebar">
          <ul>
            <li
              :class="{ 'is-active': activeTab === 0 }"
              class="gobierto-data-tab-sidebar--tab"
              @click="activateTab(0)"
            >
              <i class="fas fa-table" />
              <span>{{ labelTable }}</span>
            </li>
            <li
              :class="{ 'is-active': activeTab === 1 }"
              class="gobierto-data-tab-sidebar--tab"
              @click="activateTab(1)"
            >
              <i class="fas fa-chart-line" />
              <span>{{ labelVisualization }}</span>
            </li>
          </ul>
        </nav>
      </div>

      <div
        class="pure-u-1 pure-u-lg-2-3"
        style="text-align: right"
      >
        <SaveChartButton />
        <keep-alive>
          <DownloadButton
            :editor="true"
            :array-formats="arrayFormats"
            :class="[directionLeft ? 'modal-left' : 'modal-right']"
            style="display: inline-block"
            class="arrow-top"
          />
        </keep-alive>
      </div>
    </div>
    <SQLEditorTable
      v-if="activeTab === 2"
      :items="items"
      :number-rows="numberRows"
      :table-name="tableName"
    />

    <div class="gobierto-data-visualization">
      <SQLEditorVisualizations :items="items" />
    </div>
  </div>
</template>
<script>
import SQLEditorTable from "./SQLEditorTable.vue";
import SQLEditorVisualizations from "./SQLEditorVisualizations.vue";
import DownloadButton from "./../commons/DownloadButton.vue";
import SaveChartButton from "./../commons/SaveChartButton.vue";
import { getUserId } from "./../../../lib/helpers";
import { VisualizationFactoryMixin } from "./../../../lib/visualizations";

export default {
  name: "SQLEditorTabs",
  components: {
    SQLEditorTable,
    SQLEditorVisualizations,
    DownloadButton,
    SaveChartButton
  },
  mixins: [VisualizationFactoryMixin],
  props: {
    activeTab: {
      type: Number,
      default: 0
    },
    arrayQueries: {
      type: Array,
      required: true
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
    },
    currentQuery: {
      type: String,
      default: ""
    }
  },
  data() {
    return {
      labelTable: "",
      labelVisualization: "",
      directionLeft: false,
      privateQuery: false
    };
  },
  created() {
    this.labelTable = I18n.t("gobierto_data.projects.table");
    this.labelVisualization = I18n.t("gobierto_data.projects.visualization");

    this.userId = getUserId();
    this.noLogin = this.userId === "" ? true : false;

    this.$root.$on("saveVisualization", this.saveVisualization);
  },
  beforeDestroy() {
    this.$root.$off("saveVisualization", this.saveVisualization);
  },
  methods: {
    activateTab(index) {
      this.$emit("active-tab", index);
    },
    saveVisualization(config, opts) {
      if (this.noLogin) this.goToLogin();

      const { name, privacy } = opts;

      // default attributes
      let attributes = {
        name_translations: {
          en: name,
          es: name
        },
        privacy_status: privacy ? "closed" : "open",
        spec: config,
        user_id: this.userId
      };

      // Get the id if the query matches with a stored query
      const { id } =
        this.arrayQueries.find(
          ({ attributes }) =>
            attributes.sql === decodeURIComponent(this.currentQuery).trim()
        ) || {};

      // Depending whether the query was stored in database or not,
      // we must save the query_id or the query, instead
      if (id) {
        attributes = { ...attributes, query_id: id };
      } else {
        attributes = { ...attributes, query: this.currentQuery };
      }

      // POST data obj
      const data = {
        data: {
          type: "gobierto_data-visualizations",
          attributes
        }
      };

      this.postVisualization(data)
        .then(response => {
          // TODO:
        })
        .catch(error => {
          const messageError = error.response;
          console.error(messageError);
        });
    },
    goToLogin() {
      location.href = "/user/sessions/new?open_modal=true";
    }
  }
};
</script>
