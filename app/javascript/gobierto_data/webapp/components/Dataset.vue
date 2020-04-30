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

    <DatasetNav :active-dataset-tab="activeDatasetTab" />

    <!-- Only is mounted where there are attributes -->
    <SummaryTab
      v-if="activeDatasetTab === 0 && attributes"
      :private-queries="privateQueries"
      :public-queries="publicQueries"
      :array-formats="arrayFormats"
      :resources-list="resourcesList"
      :dataset-attributes="attributes"
    />

    <DataTab
      v-else-if="activeDatasetTab === 1"
      :private-queries="privateQueries"
      :public-queries="publicQueries"
      :recent-queries="recentQueriesFiltered"
      :array-columns="arrayColumns"
      :array-formats="arrayFormats"
      :array-columns-query="arrayColumnsQuery"
      :items="items"
      :is-query-running="isQueryRunning"
      :is-query-modified="isQueryModified"
      :is-query-saved="isQuerySaved"
      :is-saving-prompt-visible="isSavingPromptVisible"
      :query-stored="currentQuery"
      :query-name="queryName"
      :query-duration="queryDuration"
      :query-error="queryError"
      :enabled-saved-button="enabledSavedButton"
      :show-revert-query="showRevertQuery"
      :show-private="showPrivate"
    />

    <QueriesTab
      v-else-if="activeDatasetTab === 2"
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
import DatasetNav from "./sets/DatasetNav.vue";
import SummaryTab from "./sets/SummaryTab.vue";
import DataTab from "./sets/DataTab.vue";
import QueriesTab from "./sets/QueriesTab.vue";
import VisualizationsTab from "./sets/VisualizationsTab.vue";
import DownloadsTab from "./sets/DownloadsTab.vue";
import Button from "./commons/Button.vue";
import { getUserId } from "./../../lib/helpers";
import { DatasetFactoryMixin } from "./../../lib/factories/datasets";
import { QueriesFactoryMixin } from "./../../lib/factories/queries";
import { DataFactoryMixin } from "./../../lib/factories/data";
import { VisualizationFactoryMixin } from "./../../lib/factories/visualizations";

// THIS IS THE COMPONENT WHO KNOWS WHAT THE DATA IS ABOUT
// EVERY SINGLE API REQUEST IS DONE THROUGHOUT THIS ONE
export default {
  name: "Main",
  components: {
    Button,
    SummaryTab,
    DataTab,
    QueriesTab,
    VisualizationsTab,
    DownloadsTab,
    DatasetNav,
  },
  mixins: [
    DatasetFactoryMixin,
    QueriesFactoryMixin,
    DataFactoryMixin,
    VisualizationFactoryMixin,
  ],
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
      datasetId: 0, // possible deprecation in DATA, don't in the class
      titleDataset: "",
      arrayFormats: {},
      arrayColumns: {},
      attributes: null,
      privateQueries: [],
      publicQueries: [],
      recentQueries: [],
      resourcesList: [],
      arrayColumnsQuery: [],
      currentQuery: null,
      queryDefault: null,
      queryRevert: null,
      items: "",
      isQueryRunning: false,
      isQueryModified: false,
      isQuerySaved: false,
      isSavingPromptVisible: false,
      showPrivate: false,
      resetQueryDefault: false,
      revertQuerySaved: false,
      enabledSavedButton: false,
      showRevertQuery: false,
      queryName: null,
      queryDuration: 0,
      queryError: null
    };
  },
  computed: {
    recentQueriesFiltered() {
      return this.recentQueries.length ? this.recentQueries.filter(sql => (sql || '').includes(this.tableName))
        .reverse() : [];
    },
  },
  watch: {
    $route(to, from) {
      if (to) {
        const {
          params: { queryId },
          query: { sql },
        } = to;

        this.parseUrl({ queryId, sql });
      }

      if (to.path !== from.path) {
        this.setDefaultQuery()
        this.disabledSavedButton()
        this.isQueryModified = false;
      }

      //FIXME: Hugo, we need to talk about this hack
      // https://stackoverflow.com/questions/50295985/how-to-tell-if-a-vue-component-is-active-or-not
      if (to.name === 'Query' && this._inactive === false) {
        this.runCurrentQuery()
        this.disabledStringSavedQuery()
      }

    }
  },
  beforeRouteEnter (to, from, next) {
    const {
      name: nameComponent
    } = to;
    next(vm => {
      if (nameComponent === 'Query') {
        vm.showRevertQuery = true
      } else {
        vm.showRevertQuery = false
      }

    })
  },
  async created() {
    const {
      params: { id, queryId },
      query: { sql },
    } = this.$route;

    // factory method
    const {
      data: {
        data: { id: datasetId, attributes },
      },
      included,
    } = await this.getDatasetMetadata(id);

    this.datasetId = parseInt(datasetId);
    this.resourcesList = included;
    this.attributes = attributes;

    const {
      name: titleDataset,
      table_name: tableName,
      columns: arrayColumns,
      formats: arrayFormats
    } = attributes;

    this.titleDataset = titleDataset;
    this.tableName = tableName;
    this.arrayColumns = arrayColumns;
    this.arrayFormats = arrayFormats;

    // Once we have the dataset info, we request both kind of queries
    const queriesPromises = [];
    queriesPromises.push(this.getPublicQueries());

    const userId = getUserId();
    if (userId) {
      // Do not request private queries if the user is not logged
      queriesPromises.push(this.getPrivateQueries(userId));
    }

    // In order to update from the url, we need both public and private queries
    const [publicResponse, privateResponse] = await Promise.all(
      queriesPromises
    );
    this.setPublicQueries(publicResponse);

    // Only update data if there's any response
    if (privateResponse) {
      this.setPrivateQueries(privateResponse);
    }

    // Once we have the queries we can parse the url
    if (queryId || sql) {
      // update the sql editor if the url contains a query
      this.parseUrl({ queryId, sql });
    } else {
      // update the editor text content by default
      this.currentQuery = `SELECT * FROM ${this.tableName} LIMIT 50`;
    }

    this.runCurrentQuery();

  },
  mounted() {
    const recentQueries = localStorage.getItem("recentQueries");
    if (recentQueries) {
      this.recentQueries = JSON.parse(recentQueries);
    }
  },
  activated() {
    this.setDefaultQuery();
    this.$root.$on("deleteSavedQuery", this.deleteSavedQuery);
    // change the current query, triggering a new SQL execution
    this.$root.$on("setCurrentQuery", this.setCurrentQuery);
    // execute the current query
    this.$root.$on("runCurrentQuery", this.runCurrentQuery);
    // save the query in database
    this.$root.$on("storeCurrentQuery", this.storeCurrentQuery);
    // save the visualization in database
    this.$root.$on("storeCurrentVisualization", this.storeCurrentVisualization);
    // Reset to the default query
    this.$root.$on('resetQuery', this.resetQuery)
    //reset to the saved query
    this.$root.$on('revertSavedQuery', this.revertSavedQuery)

    this.$root.$on('enableSavedButton', this.activatedSavedButton)

    this.$root.$on('resetToInitialState', this.resetToInitialState)

    this.$root.$on('disabledSavedButton', this.disabledSavedButton)
    //Show a message for the user, your query is saved
    this.$root.$on('disabledStringSavedQuery', this.disabledStringSavedQuery)

    this.$root.$on('isSavingPromptVisible', this.isSavingPromptVisibleHandler)
  },
  deactivated() {
    this.$root.$off("deleteSavedQuery");
    this.$root.$off("setCurrentQuery");
    this.$root.$off("runCurrentQuery");
    this.$root.$off("storeCurrentQuery");
    this.$root.$off("storeCurrentVisualization");
    this.$root.$off("resetQuery");
    this.$root.$off("revertSavedQuery");
    this.$root.$off('enableSavedButton')
    this.$root.$off('resetToInitialState')
    this.$root.$off('disabledSavedButton')
    this.$root.$off('disabledStringSavedQuery')
    this.$root.$off('isSavingPromptVisible')
  },
  methods: {
    parseUrl({ queryId, sql }) {
      let item = null;
      if (queryId) {
        // if has id it's an stored query
        item = [...this.privateQueries, ...this.publicQueries].find(({ id }) => id === queryId);
      } else if (sql) {
        // FIXME: run normal
        // item = this.publicQueries.find((d) => d.attributes.sql === sql);
      }

      if (item) {
        const {
          attributes: { sql: itemSql, name, user_id, privacy_status },
        } = item;

        this.queryName = name;
        this.queryUserId = user_id;

        this.showPrivate = privacy_status === 'closed' ? true : false

        // update the editor text content
        this.setCurrentQuery(itemSql);
      }
    },
    setDefaultQuery() {
      //QueryDefault: users can reset to the initial Query
      this.queryDefault = `SELECT * FROM ${this.tableName} LIMIT 50`;
      //QueryRevert: if the user loads a saved query, there can reset to the initial query or reset to the saved query.
      this.queryRevert = this.currentQuery
    },
    ensureUserIsLogged() {
      if (getUserId() === "")
        location.href = "/user/sessions/new?open_modal=true";
    },
    isQueryStored(query = this.currentQuery) {
      // check if the query passed belongs to public/private arrays, if there's no args, it uses currentQuery
      return (
        this.publicQueries.some(({ attributes: { sql } }) => sql === query) ||
        this.privateQueries.some(({ attributes: { sql } }) => sql === query)
      );
    },
    setCurrentQuery(sql) {
      // trigger the modified label:
      // - hides if the new typed query is already stored
      // - shows if the previous query was stored
      if (this.isQueryStored(sql)) {
        this.isQueryModified = false;
      } else if (this.isQueryStored()) {
        this.isQueryModified = true;
      }

      // set the new query, trimming it to remove potentially harmful voids
      this.currentQuery = sql.trim();

      this.disabledSavedButton()
      this.resetQuery(false)
      this.revertSavedQuery(false)
    },
    storeRecentQuery() {
      // if the currentQuery does not exist, nor recent, nor in stored queries neither
      // then save it in recent ones, and update localStorage
      if (
        !this.recentQueries.some((query) => query === this.currentQuery) &&
        !this.isQueryStored()
      ) {
        this.recentQueries.push(this.currentQuery);
        localStorage.setItem(
          "recentQueries",
          JSON.stringify(this.recentQueries)
        );
      }
    },
    async getPrivateQueries() {
      const userId = getUserId();
      // factory method
      return this.getQueries({
        "filter[dataset_id]": this.datasetId,
        "filter[user_id]": userId,
      });
    },
    setPrivateQueries(response) {
      const {
        data: { data: items },
      } = response;
      this.privateQueries = items;
    },
    async getPublicQueries() {
      // factory method
      return this.getQueries({ "filter[dataset_id]": this.datasetId });
    },
    setPublicQueries(response) {
      const {
        data: { data: items },
      } = response;
      this.publicQueries = items;
    },
    async deleteSavedQuery(id) {
      // factory method
      const { status } = await this.deleteQuery(id);

      if (status === 204) {
        // only delete private queries
        this.setPrivateQueries(await this.getPrivateQueries());
      }
    },
    async storeCurrentQuery({ name, privacy }) {
      // if there's no user, you cannot save queries
      this.ensureUserIsLogged();

      const data = {
        type: "gobierto_data-queries",
        attributes: {
          privacy_status: privacy ? "closed" : "open",
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

        //Update revert query
        this.queryRevert = this.currentQuery
      } else {
        // factory method
        ({ status } = await this.postQuery({ data }));
      }

      // reload the queries if the response was successfull
      // 200 OK (PUT) / 201 Created (POST)
      if ([200, 201].includes(status)) {
        this.isQueryModified = false;
        //Show a message for the user, your query is saved
        this.isQuerySaved = true;

        this.setPublicQueries(await this.getPublicQueries());
        this.setPrivateQueries(await this.getPrivateQueries());
      }
    },
    async runCurrentQuery() {
      this.isQueryRunning = true;

      // save the query executed
      this.storeRecentQuery();

      const params = { sql: this.currentQuery };

      this.setDefaultQuery()

      //
      const startTime = new Date().getTime();
      // factory method
      try {
        const {
          data: items
        } = await this.getData(params);

        this.items = items;
        this.queryDuration = new Date().getTime() - startTime;
        this.isQueryRunning = false;
        this.getColumnsQuery(this.items)
      } catch (error) {
        const {
          response: {
            data: {
              errors: arrayError
            }
          }
        } = error;
        const [ sqlError ] = arrayError
        const { sql: stringError } = sqlError
        this.queryError = stringError
        this.isQueryRunning = false;
      }
    },
    async storeCurrentVisualization(config, opts) {
      // if there's no user, you cannot save visualizations
      this.ensureUserIsLogged();

      const { name, privacy } = opts;

      // default attributes
      let attributes = {
        name_translations: {
          en: name,
          es: name,
        },
        privacy_status: privacy ? "closed" : "open",
        spec: config,
        user_id: this.userId,
        dataset_id: this.datasetId,
      };

      // Get the id if the query matches with a stored query
      const { id } =
        this.privateQueries.find(
          ({ attributes: { sql } }) => sql === this.currentQuery
        ) || {};

      // Depending whether the query was stored in database or not,
      // we must save the query_id or the query, instead
      if (id) {
        attributes = { ...attributes, query_id: id };
      } else {
        attributes = { ...attributes, sql: this.currentQuery };
      }

      // POST data obj
      const data = {
        type: "gobierto_data-visualizations",
        attributes,
      };

      // factory method
      const { status } = await this.postVisualization({ data });
      // TODO: indicar algo con el status OK
      console.log("postVisualization", status);
    },
    getColumnsQuery(csv = '') {
      const [ columns = '' ] = csv.split("\n");
      this.arrayColumnsQuery = columns.split(",");
    },
    resetQuery(value) {
      this.resetQueryDefault = value
      if (value === true) {
        this.isSavingPromptVisible = false
        this.currentQuery = `SELECT * FROM ${this.tableName} LIMIT 50`;
        this.isQueryModified = false
        this.runCurrentQuery()
        this.disabledSavedButton()
        this.disabledStringSavedQuery()
        this.queryName = null
      }
    },
    revertSavedQuery(value) {
      this.revertQuerySaved = value
      if (value === true) {
        this.isSavingPromptVisible = false
        this.currentQuery = this.queryRevert
        this.isQueryModified = false
        this.runCurrentQuery()
        this.disabledSavedButton()
        this.disabledStringSavedQuery()
      }
    },
    activatedSavedButton() {
      this.enabledSavedButton = true
      const {
        name: name
      } = this.$route;

      if (name === 'Query') {
        this.showRevertQuery = true
      }

    },
    disabledSavedButton() {
      this.enabledSavedButton = false
    },
    resetToInitialState() {
      this.isQueryModified = false
    },
    resetToInitialStateSavedQuery() {
      this.showRevertQuery = true
      this.isQueryModified = false
    },
    disabledStringSavedQuery() {
      this.isQuerySaved = false;
    },
    isSavingPromptVisibleHandler(value) {
      this.isSavingPromptVisible = value
    }
  },
};
</script>
