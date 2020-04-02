<template>
  <div class="gobierto-data-summary-queries">
    <div class="gobierto-data-summary-queries-panel pure-g">
      <div class="pure-u-1-2 gobierto-data-summary-queries-panel-dropdown">
        <Dropdown
          @is-content-visible="showPrivateQueries = !showPrivateQueries"
        >
          <template v-slot:trigger>
            <h3 class="gobierto-data-summary-queries-panel-title">
              <Caret :rotate="showPrivateQueries" />

              {{ labelYourQueries }} ({{ privateQueries.length }})
            </h3>
          </template>

          <div>
            <div
              v-for="(item, index) in privateQueries"
              :key="index"
              class="gobierto-data-summary-queries-container"
              @mouseover="showCode(index)"
              @mouseleave="hideCode = true"
            >
              <a
                :href="`/datos/${pathQueries}/q/${index}`"
                class="gobierto-data-summary-queries-container-name"
                @click.prevent="
                  handleQueries(
                    privateQueries[index].attributes.sql,
                    item,
                    false
                  )
                "
              >
                {{ item.attributes.name }}
              </a>
              <div class="gobierto-data-summary-queries-container-icon">
                <i
                  class="fas fa-trash-alt icons-your-queries"
                  style="color: var(--color-base);"
                  @click="deleteSavedQuery(item.id)"
                />
                <i
                  v-if="item.attributes.privacy_status === 'closed'"
                  style="color: #D0021B"
                  class="fas fa-lock icons-your-queries"
                />
                <i
                  v-else
                  style="color: rgb(160, 197, 29)"
                  class="fas fa-lock-open icons-your-queries"
                />
              </div>
            </div>
          </div>
        </Dropdown>

        <Dropdown @is-content-visible="showFavQueries = !showFavQueries">
          <template v-slot:trigger>
            <h3 class="gobierto-data-summary-queries-panel-title">
              <Caret :rotate="showFavQueries" />

              <!-- TODO: Favorite Queries -->
              {{ labelFavs }} ({{ 0 }})
            </h3>
          </template>

          <!-- TODO: Favorite Queries -->
          <div />
        </Dropdown>

        <Dropdown @is-content-visible="showPublicQueries = !showPublicQueries">
          <template v-slot:trigger>
            <h3 class="gobierto-data-summary-queries-panel-title">
              <Caret :rotate="showPublicQueries" />

              {{ labelAll }} ({{ publicQueries.length }})
            </h3>
          </template>

          <div>
            <div
              v-for="(item, index) in publicQueries"
              :key="index"
              class="gobierto-data-summary-queries-container"
              @mouseover="showCodePublic(index)"
              @mouseleave="hideCode = true"
              @click="handleQueries(publicQueries[index].attributes.sql, item)"
            >
              <span class="gobierto-data-summary-queries-container-name">
                {{ item.attributes.name }}</span>
            </div>
          </div>
        </Dropdown>
      </div>

      <div class="pure-u-1-2 border-color-queries">
        <p class="gobierto-data-summary-queries-sql-code">
          <span v-if="!hideCode"> {{ sqlCode }}</span>
        </p>
      </div>
    </div>
  </div>
</template>
<script>
import axios from "axios";
import { Dropdown } from "lib/vue-components";
import Caret from "./Caret.vue";
import { QueriesFactoryMixin } from "./../../../lib/factories/queries";

export default {
  name: "Queries",
  components: {
    Caret,
    Dropdown
  },
  mixins: [QueriesFactoryMixin],
  props: {
    datasetId: {
      type: Number,
      required: true
    },
    privateQueries: {
      type: Array,
      required: true
    },
    publicQueries: {
      type: Array,
      required: true
    }
  },
  data() {
    return {
      labelQueries: I18n.t("gobierto_data.projects.queries") || "",
      labelYourQueries: I18n.t("gobierto_data.projects.yourQueries") || "",
      labelFavs: I18n.t("gobierto_data.projects.favs") || "",
      labelAll: I18n.t("gobierto_data.projects.all") || "",
      hideCode: true,
      sqlCode: "",
      showSection: true,
      showPrivateQueries: true,
      showFavQueries: true,
      showPublicQueries: true,
      endPoint: "",
      url: "",
      pathQueries: this.$parent.$root._route.params.id
    };
  },
  methods: {
    handleQueries(sql, item, index) {
      this.runYourQuery(sql);
      this.sendQuery(item);
      this.closeModal();
      this.changeTab();
      if (item.attributes.privacy_status === "open") {
        this.nav(index);
      }
    },
    closeModal() {
      this.$root.$emit("closeQueriesModal");
    },
    showCode(index) {
      this.hideCode = false;
      this.sqlCode = this.privateQueries[index].attributes.sql;
    },
    showCodePublic(index) {
      this.hideCode = false;
      this.sqlCode = this.publicQueries[index].attributes.sql;
    },
    sendQuery(item) {
      this.queryParams = [
        item.attributes.name,
        item.attributes.privacy_status,
        item.attributes.sql,
        item.id,
        item.attributes.user_id
      ];
      this.queryCode = item.attributes.sql;
      this.$root.$emit("sendQueryParams", this.queryParams);
      this.$root.$emit("sendQueryCode", this.queryCode);
    },
    changeTab() {
      this.$root.$emit("changeNavTab");
    },
    async deleteSavedQuery(id) {
      // factory method
      const { status } = await this.deleteQuery(id)

      if (status === 204){
        // TODO: this shouldn't be done here, nor this way. Centralize all this shared props within an state manager (vuex/store)
        this.$delete(this.privateQueries, this.privateQueries.findIndex(d => d.id === id))
      }
    },
    runYourQuery(code) {
      this.queryEditor = encodeURI(code);
      this.$root.$emit("postRecentQuery", code);
      this.$root.$emit("showMessages", false, true);
      this.$root.$emit("updateCode", code);
      const queryEditorLowerCase = this.queryEditor.toLowerCase();

      if (queryEditorLowerCase.includes("limit")) {
        this.queryEditor = this.queryEditor;
        this.$root.$emit("hiddeShowButtonColumns");
      } else {
        this.$root.$emit("ShowButtonColumns");
        this.$root.$emit("sendCompleteQuery", this.queryEditor);
        this.code = `SELECT%20*%20FROM%20(${this.queryEditor})%20AS%20data_limited_results%20LIMIT%20100%20OFFSET%200`;
        this.queryEditor = this.code;
      }
      this.urlPath = location.origin;
      this.endPoint = "/api/v1/data/data";
      this.url = `${this.urlPath}${this.endPoint}?sql=${this.queryEditor}`;

      axios
        .get(this.url)
        .then(response => {
          let data = [];
          let keysData = [];
          const rawData = response.data;
          const meta = rawData.meta;
          data = rawData.data;

          const queryDurationRecords = [meta.rows, meta.duration];

          keysData = Object.keys(data[0]);

          this.$root.$emit("recordsDuration", queryDurationRecords);
          this.$root.$emit("sendData", keysData, data);
          this.$root.$emit("sendDataViz", data);
          this.$root.$emit("showMessages", true, false);
          this.$root.$emit("firstQuery", true);
          this.$root.$emit("sendQueryCode", this.queryCode);
          this.$root.$emit("activateModalRecent");
          this.$root.$emit("runSpinner");
        })
        .catch(error => {
          const messageError = error.response.data.errors[0].sql;
          this.$root.$emit("apiError", messageError);
          const data = [];
          const keysData = [];
          this.$root.$emit("sendData", keysData, data);
        });
    },
    nav(index) {
      this.$router.push(
        {
          name: "queries",
          params: {
            queryId: index
          }
        },
        () => {}
      );
      this.changeTab();
    }
  }
};
</script>
