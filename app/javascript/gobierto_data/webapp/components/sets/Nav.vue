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

    <NavTabs :active-dataset-tab="activeDatasetTab" />

    <keep-alive v-if="activeDatasetTab === 0">
      <Summary
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

    <keep-alive v-else-if="activeDatasetTab === 1">
      <Data
        :dataset-id="datasetId"
        :private-queries="privateQueries"
        :public-queries="publicQueries"
        :array-columns="arrayColumns"
        :table-name="tableName"
        :array-formats="arrayFormats"
        :number-rows="numberRows"
      />
    </keep-alive>

    <keep-alive v-else-if="activeDatasetTab === 2">
      <Queries
        :dataset-id="datasetId"
        :private-queries="privateQueries"
        :public-queries="publicQueries"
      />
    </keep-alive>

    <!-- Visualizations requires to query API on created, so we don't keep-alive it -->
    <Visualizations
      v-else-if="activeDatasetTab === 3"
      :dataset-id="datasetId"
    />

    <keep-alive v-else-if="activeDatasetTab === 4">
      <Downloads
        :array-formats="arrayFormats"
        :resources-list="resourcesList"
      />
    </keep-alive>
  </div>
</template>
<script>
import Button from "./../commons/Button.vue";
import Summary from "./Summary.vue";
import Data from "./Data.vue";
import Queries from "./Queries.vue";
import Visualizations from "./Visualizations.vue";
import Downloads from "./Downloads.vue";
import NavTabs from "./NavTabs.vue";
import { getUserId } from "./../../../lib/helpers";
import { translate } from "./../../../../lib/shared/modules/vue-filters";
import { DatasetFactoryMixin } from "./../../../lib/factories/datasets";
import { QueriesFactoryMixin } from "./../../../lib/factories/queries";

export default {
  name: "NavSets",
  components: {
    Button,
    Summary,
    Data,
    Queries,
    Visualizations,
    Downloads,
    NavTabs
  },
  filters: {
    translate
  },
  mixins: [DatasetFactoryMixin, QueriesFactoryMixin],
  props: {
    activeDatasetTab: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      labelSummary: I18n.t("gobierto_data.projects.summary") || "",
      labelData: I18n.t("gobierto_data.projects.data") || "",
      labelQueries: I18n.t("gobierto_data.projects.queries") || "",
      labelVisualizations:
        I18n.t("gobierto_data.projects.visualizations") || "",
      labelDownload: I18n.t("gobierto_data.projects.download") || "",
      labelFav: I18n.t("gobierto_data.projects.fav") || "",
      labelFollow: I18n.t("gobierto_data.projects.follow") || "",
      tableName: "",
      titleDataset: "",
      numberRows: 0,
      datasetId: 0,
      arrayFormats: {},
      arrayColumns: {},
      privateQueries: [],
      publicQueries: [],
      resourcesList: [],
      dateUpdated: "",
      descriptionDataset: "",
      categoryDataset: "",
      frequencyDataset: ""
    };
  },
  watch: {
    $route(to) {
      if (to) {
        this.parseUrl(to)
      }
    }
  },
  created() {
    this.$root.$on("reloadPublicQueries", this.getPublicQueries);
    this.$root.$on("reloadPrivateQueries", this.getPrivateQueries);

    this.setValuesDataset();
  },
  mounted() {
    // TODO: move this after private/public queries are fulfilled
    this.parseUrl(this.$route)
  },
  beforeDestroy() {
    this.$root.$off("reloadPublicQueries", this.getPublicQueries);
    this.$root.$off("reloadPrivateQueries", this.getPrivateQueries);
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
        const {
          id,
          attributes: { name, privacy_status, sql: itemSql, user_id }
        } = item;
        const queryParams = [name, privacy_status, itemSql, id, user_id];

        this.$root.$emit("sendQueryParams", queryParams);

        // update the editor text content
        this.$root.$emit("editCurrentQuery", itemSql);
        // run the query directly
        this.$root.$emit("runQuery");
        // close the open modals
        this.$root.$emit("closeQueriesModal");
      }
    },
    setValuesDataset() {
      const { id } = this.$route.params;

      // factory method
      this.getDatasetMetadata(id)
        .then(response => {
          const { data: raw } = response;
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
                data_summary: { number_of_rows: numberRows },
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
          this.numberRows = numberRows;
          this.arrayFormats = arrayFormats;
          this.resourcesList = response.included;
          this.frequencyDataset = frequency[0].name_translations;
          this.categoryDataset = category[0].name_translations;

          // Get all queries
          this.getPrivateQueries();
          this.getPublicQueries();
        })
        .catch(error => console.error(error));
    },
    getPrivateQueries() {
      const userId = getUserId();

      // Only if user is logged
      if (userId) {
        // factory method
        this.getQueries({
          "filter[dataset_id]": this.datasetId,
          "filter[user_id]": userId
        })
          .then(({ data }) => {
            const { data: items } = data;
            this.privateQueries = items;
          })
          .catch(({ response }) => console.error(response));
      }
    },
    getPublicQueries() {
      // factory method
      this.getQueries({
        "filter[dataset_id]": this.datasetId
      })
        .then(({ data }) => {
          const { data: items } = data;
          this.publicQueries = items;
        })
        .catch(({ response }) => console.error(response));
    }
  }
};
</script>
