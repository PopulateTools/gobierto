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

      <div class="pure-u-1 pure-u-lg-2-3">
        <div class="pure-g">
          <div class="pure-u-1 pure-u-lg-3-4">
            <div class="gobierto-data-sql-editor-container-save">
              <input
                ref="inputText"
                v-model="labelQueryName"
                type="text"
                class="gobierto-data-sql-editor-container-save-text"
                @keyup="onSave($event.target.value)"
              >
              <label
                :for="labelPrivate"
                class="gobierto-data-sql-editor-container-save-label"
              >
                <input
                  :id="labelPrivate"
                  :checked="privateQuery"
                  type="checkbox"
                  class="gobierto-data-sql-editor-container-save-checkbox"
                  @input="privateQueryValue($event.target.checked)"
                >
                {{ labelPrivate }}
              </label>
              <i
                :class="privateQuery ? 'fa-lock' : 'fa-lock-open'"
                :style="privateQuery ? 'color: #D0021B;' : 'color: #A0C51D;'"
                class="fas"
              />

              <SaveChartButton />

              <Button
                :text="labelCancel"
                class="btn-sql-editor btn-sql-editor-cancel"
                icon="undefined"
                color="var(--color-base)"
                background="#fff"
                @click.native="cancelQuery()"
              />
            </div>
          </div>

          <div class="pure-u-1 pure-u-lg-1-4">
            <keep-alive>
              <DownloadButton
                :editor="true"
                :array-formats="arrayFormats"
                :class="[directionLeft ? 'modal-left' : 'modal-right']"
                class="arrow-top"
              />
            </keep-alive>
          </div>
        </div>
      </div>
    </div>
    <SQLEditorTable
      v-if="activeTab === 2"
      :items="items"
      :number-rows="numberRows"
      :table-name="tableName"
    />
    <SQLEditorVisualizations :items="items" />
  </div>
</template>
<script>
import SQLEditorTable from "./SQLEditorTable.vue";
import SQLEditorVisualizations from "./SQLEditorVisualizations.vue";
import DownloadButton from "./../commons/DownloadButton.vue";
import SaveChartButton from "./../commons/SaveChartButton.vue";
import { getToken, getUserId } from "./../../../lib/helpers";
import { baseUrl } from "./../../../lib/commons.js";
import axios from "axios";

export default {
  name: "SQLEditorTabs",
  components: {
    SQLEditorTable,
    SQLEditorVisualizations,
    DownloadButton,
    SaveChartButton
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
      labelPrivate: "",
      labelCancel: "",
      labelQueryName: "",
      directionLeft: false,
      privateQuery: false
    };
  },
  created() {
    this.labelTable = I18n.t("gobierto_data.projects.table");
    this.labelVisualization = I18n.t("gobierto_data.projects.visualization");
    this.labelPrivate = I18n.t('gobierto_data.projects.private');
    this.labelCancel = I18n.t('gobierto_data.projects.cancel');
    this.labelQueryName = I18n.t('gobierto_data.projects.queryName');

    this.token = getToken();
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
    saveVisualization(config) {
      if (this.noLogin) this.goToLogin();

      const endPoint = `${baseUrl}/visualizations`;
      const data = {
        data: {
          type: "gobierto_data-visualizations",
          attributes: {
            name_translations: {
              en: "New visualization",
              es: "Nueva visualizacion"
            },
            privacy_status: "open",
            spec: config,
            query_id: "79",
            user_id: this.userId
          }
        }
      };

      axios
        .post(endPoint, data, {
          headers: {
            "Content-type": "application/json",
            Authorization: `${this.token}`
          }
        })
        .then(response => {
          console.log(response);

          // this.$root.$emit('reloadQueries')
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
