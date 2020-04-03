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

    <keep-alive v-if="activeDatasetTab === 0">
      <SummaryTab
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
    </keep-alive>

    <DataTab
      v-else-if="activeDatasetTab === 1"
      :dataset-id="datasetId"
      :private-queries="privateQueries"
      :public-queries="publicQueries"
      :array-columns="arrayColumns"
      :table-name="tableName"
      :array-formats="arrayFormats"
      :current-query="currentQuery"
      :items="items"
      :query-number-rows="queryNumberRows"
      :query-duration="queryDuration"
      :query-error="queryError"
    />
    <!-- <keep-alive /> -->

    <keep-alive v-else-if="activeDatasetTab === 2">
      <QueriesTab
        :dataset-id="datasetId"
        :private-queries="privateQueries"
        :public-queries="publicQueries"
      />
    </keep-alive>

    <!-- Visualizations requires to query API on created, so we don't keep-alive it -->
    <VisualizationsTab
      v-else-if="activeDatasetTab === 3"
      :dataset-id="datasetId"
    />

    <keep-alive v-else-if="activeDatasetTab === 4">
      <DownloadsTab
        :array-formats="arrayFormats"
        :resources-list="resourcesList"
      />
    </keep-alive>
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
import { DataFactoryMixin } from "./../../../lib/factories/data"

export default {
  name: "DataSetsContent",
  components: {
    Button,
    SummaryTab,
    DataTab,
    QueriesTab,
    VisualizationsTab,
    DownloadsTab,
    NavDataSets
  },
  filters: {
    translate
  },
  mixins: [DatasetFactoryMixin, QueriesFactoryMixin, DataFactoryMixin],
  props: {
    activeDatasetTab: {
      type: Number,
      default: 0
    }
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
      resourcesList: [],
      dateUpdated: "",
      descriptionDataset: "",
      categoryDataset: "",
      frequencyDataset: "",
      currentQuery: null,
      items: null,
      queryDuration: 0,
      queryNumberRows: 0,
      queryError: null
    };
  },
  watch: {
    $route(to) {
      if (to) {
        this.parseUrl(to);
      }
    }
  },
  created() {
    // refresh public queries
    this.$root.$on("reloadPublicQueries", this.getPublicQueries);
    // refresh private queries
    this.$root.$on("reloadPrivateQueries", this.getPrivateQueries);
    // change the current query, triggering a new SQL execution
    this.$root.$on("reloadCurrentQuery", this.setCurrentQuery);

    this.setValuesDataset();
  },
  beforeDestroy() {
    this.$root.$off("reloadPublicQueries", this.getPublicQueries);
    this.$root.$off("reloadPrivateQueries", this.getPrivateQueries);
    this.$root.$off("reloadCurrentQuery", this.setCurrentQuery);
  },
  methods: {
    parseUrl(route) {
      const {
        params: { queryId },
        query: { sql }
      } = route;

      let item = null;
      if (queryId) {
        // if has queryId it's a privateQuery
        item = this.privateQueries[Number(queryId)];
      } else if (sql) {
        // if has sql it's a publicQuery
        item = this.publicQueries.find(d => d.attributes.sql === sql);
      }

      if (item) {
        const { attributes: { sql: itemSql } } = item;

        // update the editor text content
        this.setCurrentQuery(itemSql)
      }
    },
    setCurrentQuery(sql) {
      this.currentQuery = sql
    },
    async setValuesDataset() {
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
            category = []
          }
        }
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
      const [publicResponse, privateResponse] = await Promise.all( queriesPromises );
      const {
        data: { data: publicItems }
      } = publicResponse;
      this.publicQueries = publicItems;

      // Only update data if there's any response
      if (privateResponse) {
        const {
          data: { data: privateItems }
        } = privateResponse;
        this.privateQueries = privateItems;
      }

      // update the sql editor if the url contains a query
      this.parseUrl(this.$route)
    },
    async getPrivateQueries() {
      const userId = getUserId();
      const {
        data: { data: items }
      } = await this.fetchPrivateQueries(userId);
      this.publicQueries = items;
    },
    async getPublicQueries() {
      const {
        data: { data: items }
      } = await this.fetchPublicQueries();
      this.publicQueries = items;
    },
    // returns a simply promise
    fetchPrivateQueries(userId) {
      // factory method
      return this.getQueries({
        "filter[dataset_id]": this.datasetId,
        "filter[user_id]": userId
      });
    },
    // returns a simply promise
    fetchPublicQueries() {
      // factory method
      return this.getQueries({ "filter[dataset_id]": this.datasetId });
    },
    runCurrentQuery() {
      let query = ''
      if (this.currentQuery.includes('LIMIT')) {
        query = this.currentQuery
      } else {
        query = `SELECT * FROM (${this.currentQuery}) AS data_limited_results LIMIT 100 OFFSET 0`
      }

      const params = { sql: query }

      // factory method
      this.getData(params)
        .then(({ data: { data: items, meta: { rows, duration } } }) => {
          this.items = items
          this.queryDuration = duration
          this.queryNumberRows = rows
        })
        .catch(error => (this.queryError = error))
    },
  }
};
</script>
