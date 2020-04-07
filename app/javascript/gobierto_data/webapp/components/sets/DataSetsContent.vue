<template>
  <div>
    <div class="pure-g">
      <div class="pure-u-1-2">
        <h2
          v-if="titleDataset"
          class="gobierto-data-title-dataset"
        >
          {{ titleDataset }}
        </h2>
      </div>
      <div class="pure-u-1-2 gobierto-data-buttons">
        <Button
          :text="labelFav"
          icon="star"
          color="#fff"
          background="var(--color-base)"
        />
        <Button
          :text="labelFollow"
          icon="bell"
          color="#fff"
          background="var(--color-base)"
        />
      </div>
    </div>

    <NavDataSets :active-dataset-tab="activeDatasetTab" />

    <SummaryTab
      v-if="activeDatasetTab === 0"
      :private-queries="privateQueries"
      :public-queries="publicQueries"
      :array-formats="arrayFormats"
      :description-dataset="descriptionDataset"
      :category-dataset="categoryDataset | translate"
      :frequency-dataset="frequencyDataset | translate"
      :resources-list="resourcesList"
      :date-updated="dateUpdated"
      :dataset-id="datasetId"
    />

    <DataTab
      v-else-if="activeDatasetTab === 1"
      :dataset-id="datasetId"
      :private-queries="privateQueries"
      :public-queries="publicQueries"
      :recent-queries="recentQueriesFiltered"
      :array-columns="arrayColumns"
      :table-name="tableName"
      :array-formats="arrayFormats"
      :items="items"
      :is-query-running="isQueryRunning"
      :query-stored="currentQuery"
      :query-name="queryName"
      :query-number-rows="queryNumberRows"
      :query-duration="queryDuration"
      :query-error="queryError"
    />

    <QueriesTab
      v-else-if="activeDatasetTab === 2"
      :dataset-id="datasetId"
      :private-queries="privateQueries"
      :public-queries="publicQueries"
    />

    <VisualizationsTab
      v-else-if="activeDatasetTab === 3"
      :dataset-id="datasetId"
    />

    <DownloadsTab
      v-else-if="activeDatasetTab === 4"
      :array-formats="arrayFormats"
      :resources-list="resourcesList"
    />
  </div>
</template>

<script>
// TODO: este componente se debe mover a /pages, reemplazando el actual
import Button from "./../commons/Button.vue";
import SummaryTab from "./SummaryTab.vue";
import DataTab from "./DataTab.vue";
import QueriesTab from "./QueriesTab.vue";
import VisualizationsTab from "./VisualizationsTab.vue";
import DownloadsTab from "./DownloadsTab.vue";
import NavDataSets from "./NavDataSets.vue";
import { getUserId } from "./../../../lib/helpers";
import { translate } from "./../../../../lib/shared/modules/vue-filters";
import { DatasetFactoryMixin } from "./../../../lib/factories/datasets";
import { QueriesFactoryMixin } from "./../../../lib/factories/queries";
import { DataFactoryMixin } from "./../../../lib/factories/data";

// THIS IS THE COMPONENT WHO KNOWS WHAT THE DATA IS ABOUT
// EVERY SINGLE API REQUEST IS DONE THROUGHOUT THIS ONE
export default {
  name: "DataSetsContent",
  components: {
    Button,
    SummaryTab,
    DataTab,
    QueriesTab,
    VisualizationsTab,
    DownloadsTab,
    NavDataSets,
  },
  filters: {
    translate,
  },
  mixins: [DatasetFactoryMixin, QueriesFactoryMixin, DataFactoryMixin],
  props: {
    activeDatasetTab: {
      type: Number,
      default: 0,
    },
  },
  data() {
    return {
      labelFav: I18n.t("gobierto_data.projects.fav") || "",
      labelFollow: I18n.t("gobierto_data.projects.follow") || "",
      tableName: "",
      titleDataset: "",
      datasetId: 0,
      arrayFormats: {},
      arrayColumns: {},
      privateQueries: [],
      publicQueries: [],
      recentQueries: [],
      resourcesList: [],
      dateUpdated: "",
      descriptionDataset: "",
      categoryDataset: "",
      frequencyDataset: "",
      currentQuery: null,
      items: null,
      isQueryRunning: false,
      queryName: null,
      queryDuration: 0,
      queryNumberRows: 0,
      queryError: null,
    };
  },
  computed: {
    recentQueriesFiltered() {
      return this.recentQueries
        .filter((sql) => sql.includes(this.tableName))
        .reverse();
    },
  },
  watch: {
    $route(to) {
      if (to) {
        const {
          params: { queryId },
          query: { sql },
        } = to;

        this.parseUrl({ queryId, sql });
      }
    },
  },
  created() {
    // remove saved query
    this.$root.$on("deleteSavedQuery", this.deleteSavedQuery);
    // change the current query, triggering a new SQL execution
    this.$root.$on("setCurrentQuery", this.setCurrentQuery);
    // execute the current query
    this.$root.$on("runCurrentQuery", this.runCurrentQuery);
    // save the query in database
    this.$root.$on("storeCurrentQuery", this.storeCurrentQuery);

    this.setDatasetMetadata();
  },
  mounted() {
    const recentQueries = localStorage.getItem("recentQueries");
    if (recentQueries) {
      this.recentQueries = JSON.parse(recentQueries);
    }
  },
  beforeDestroy() {
    this.$root.$off("deleteSavedQuery", this.deleteSavedQuery);
    this.$root.$off("setCurrentQuery", this.setCurrentQuery);
    this.$root.$off("runCurrentQuery", this.runCurrentQuery);
    this.$root.$off("storeCurrentQuery", this.storeCurrentQuery);
  },
  methods: {
    parseUrl({ queryId, sql }) {
      let item = null;
      if (queryId) {
        // if has queryId it's a privateQuery
        item = this.privateQueries.find((d) => d.id === queryId);
      } else if (sql) {
        // if has sql it's a publicQuery
        item = this.publicQueries.find((d) => d.attributes.sql === sql);
      }

      if (item) {
        const {
          attributes: { sql: itemSql, name, user_id },
        } = item;

        this.queryName = name;
        this.queryUserId = user_id;

        // update the editor text content
        this.setCurrentQuery(itemSql);
        // run such query
        this.runCurrentQuery();
      }
    },
    setCurrentQuery(sql) {
      this.currentQuery = sql;
    },
    storeRecentQuery() {
      // if the currentQuery does not exist, nor recent, nor public, nor private queries neither
      // then save it in recent ones, and update localStorage
      if (
        !this.recentQueries.some((query) => query === this.currentQuery) &&
        !this.publicQueries.some(
          ({ attributes: { sql } }) => sql === this.currentQuery
        ) &&
        !this.privateQueries.some(
          ({ attributes: { sql } }) => sql === this.currentQuery
        )
      ) {
        this.recentQueries.push(this.currentQuery);
        localStorage.setItem(
          "recentQueries",
          JSON.stringify(this.recentQueries)
        );
      }
    },
    async setDatasetMetadata() {
      const { id } = this.$route.params;

      // factory method
      const { data: raw, included } = await this.getDatasetMetadata(id);

      const {
        data: {
          id: datasetId,
          attributes: {
            name: titleDataset,
            slug: slugDataset,
            table_name: tableName,
            columns: arrayColumns,
            description: descriptionDataset,
            data_updated_at: dateUpdated,
            formats: arrayFormats,
            frequency = [],
            category = [],
          },
        },
      } = raw;

      this.datasetId = parseInt(datasetId);
      this.titleDataset = titleDataset;
      this.slugDataset = slugDataset;
      this.tableName = tableName;
      this.arrayColumns = arrayColumns;
      this.descriptionDataset = descriptionDataset;
      this.dateUpdated = dateUpdated;
      this.arrayFormats = arrayFormats;
      this.resourcesList = included;
      this.frequencyDataset = frequency[0].name_translations;
      this.categoryDataset = category[0].name_translations;

      // Once we have the dataset info, we request both kind of queries
      const queriesPromises = [];
      queriesPromises.push(this.fetchPublicQueries());

      const userId = getUserId();
      if (userId) {
        // Do not request private queries if the user is not logged
        queriesPromises.push(this.fetchPrivateQueries(userId));
      }
      const [publicResponse, privateResponse] = await Promise.all(
        queriesPromises
      );
      const {
        data: { data: publicItems },
      } = publicResponse;
      this.publicQueries = publicItems;

      // Only update data if there's any response
      if (privateResponse) {
        const {
          data: { data: privateItems },
        } = privateResponse;
        this.privateQueries = privateItems;
      }

      const {
        params: { queryId },
        query: { sql },
      } = this.$route;

      if (queryId || sql) {
        // update the sql editor if the url contains a query
        this.parseUrl({ queryId, sql });
      } else {
        // update the editor text content
        this.setCurrentQuery(`SELECT * FROM ${this.tableName}`);
      }
    },
    async getPrivateQueries() {
      const userId = getUserId();
      const {
        data: { data: items },
      } = await this.fetchPrivateQueries(userId);
      this.privateQueries = items;
    },
    async getPublicQueries() {
      const {
        data: { data: items },
      } = await this.fetchPublicQueries();
      this.publicQueries = items;
    },
    async deleteSavedQuery(id) {
      // factory method
      const { status } = await this.deleteQuery(id);

      if (status === 204) {
        this.getPrivateQueries();
      }
    },
    async storeCurrentQuery({ name, privacy }) {
      const data = {
        type: "gobierto_data-queries",
        attributes: {
          privacy_status: privacy === false ? "open" : "closed",
          sql: this.currentQuery,
          name,
          dataset_id: this.datasetId,
        },
      };

      const userId = Number(getUserId());
      let status = null; // https://javascript.info/destructuring-assignment

      // Only update the query is the user and the name are the same
      if (name === this.queryName && userId === this.queryUserId) {
        const { queryId } = this.$route.params;
        // factory method
        ({ status } = await this.putQuery(queryId, { data }));
      } else {
        // factory method
        ({ status } = await this.postQuery({ data }));
      }

      // reload the queries if the response was successfull
      // 200 OK (PUT) / 201 Created (POST)
      if ([200, 201].includes(status)) {
        this.getPublicQueries();
        this.getPrivateQueries();
      }
    },
    async runCurrentQuery() {
      this.isQueryRunning = true;

      // save the query executed
      this.storeRecentQuery();

      // wrap the result in an small number of records
      let query = "";
      if (this.currentQuery.includes("LIMIT")) {
        query = this.currentQuery;
      } else {
        query = `SELECT * FROM (${this.currentQuery}) AS data_limited_results LIMIT 100 OFFSET 0`;
      }

      const params = { sql: query };

      // factory method
      try {
        const {
          data: {
            data: items,
            meta: { rows, duration },
          },
        } = await this.getData(params);

        this.items = items;
        this.queryDuration = duration;
        this.queryNumberRows = rows;
        this.isQueryRunning = false;
      } catch (error) {
        this.queryError = error;
      }
    },
    // returns a simply promise
    fetchPrivateQueries(userId) {
      // factory method
      return this.getQueries({
        "filter[dataset_id]": this.datasetId,
        "filter[user_id]": userId,
      });
    },
    // returns a simply promise
    fetchPublicQueries() {
      // factory method
      return this.getQueries({ "filter[dataset_id]": this.datasetId });
    },
  },
};
</script>
