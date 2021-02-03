<template>
  <div>
    <template v-if="!isDatasetLoaded">
      <SkeletonSpinner
        height-square="300px"
        squares-rows="2"
        squares="2"
        lines="5"
      />
    </template>
    <template v-else>
      <div class="pure-g">
        <div class="pure-u-1-2">
          <h2
            v-if="titleDataset"
            class="gobierto-data-title-dataset"
          >
            {{ titleDataset }}
          </h2>
        </div>
      </div>

      <DatasetNav :active-dataset-tab="activeDatasetTab" />

      <!-- Only is mounted where there are attributes -->
      <SummaryTab
        v-if="activeDatasetTab === 0 && attributes"
        :dataset-id="datasetId"
        :is-viz-modified="isVizModified"
        :is-viz-item-modified="isVizItemModified"
        :is-viz-saved="isVizSaved"
        :is-private-viz-loading="isPrivateVizLoading"
        :is-public-viz-loading="isPublicVizLoading"
        :public-visualizations="publicVisualizations"
        :private-visualizations="privateVisualizations"
        :enabled-viz-saved-button="enabledVizSavedButton"
        :current-viz-tab="currentVizTab"
        :enabled-fork-viz-button="enabledForkVizButton"
        :viz-input-focus="vizInputFocus"
        :viz-id="vizID"
        :user-save-viz="userSaveViz"
        :show-private-public-icon-viz="showPrivatePublicIconViz"
        :show-private="showPrivate"
        :show-private-viz="showPrivateViz"
        :show-label-edit="showLabelEdit"
        :reset-private="resetPrivate"
        :private-queries="privateQueries"
        :public-queries="publicQueries"
        :array-formats="arrayFormats"
        :object-columns="objectColumns"
        :resources-list="resourcesList"
        :dataset-attributes="attributes"
        :is-user-logged="isUserLogged"
      />

      <DataTab
        v-else-if="activeDatasetTab === 1"
        :private-queries="privateQueries"
        :public-queries="publicQueries"
        :recent-queries="recentQueriesFiltered"
        :object-columns="objectColumns"
        :array-formats="arrayFormats"
        :array-columns-query="arrayColumnsQuery"
        :items="items"
        :is-query-saved="isQuerySaved"
        :is-viz-saved="isVizSaved"
        :is-query-saving-prompt-visible="isQuerySavingPromptVisible"
        :is-query-running="isQueryRunning"
        :is-query-modified="isQueryModified"
        :is-viz-modified="isVizModified"
        :is-viz-saving-prompt-visible="isVizSavingPromptVisible"
        :is-fork-prompt-visible="isForkPromptVisible"
        :query-stored="currentQuery"
        :query-name="queryName"
        :query-duration="queryDuration"
        :query-error="queryError"
        :enabled-query-saved-button="enabledQuerySavedButton"
        :enabled-viz-saved-button="enabledVizSavedButton"
        :enabled-fork-button="enabledForkButton"
        :enabled-revert-button="enabledRevertButton"
        :show-revert-query="showRevertQuery"
        :show-private="showPrivate"
        :table-name="tableName"
        :is-user-logged="isUserLogged"
        :query-input-focus="queryInputFocus"
        :viz-input-focus="vizInputFocus"
        :viz-name="vizName"
        :viz-id="vizID"
        :reset-private="resetPrivate"
        :show-private-public-icon="showPrivatePublicIcon"
        :show-private-public-icon-viz="showPrivatePublicIconViz"
      />

      <QueriesTab
        v-else-if="activeDatasetTab === 2"
        :private-queries="privateQueries"
        :public-queries="publicQueries"
        :is-user-logged="isUserLogged"
      />

      <VisualizationsTab
        v-else-if="activeDatasetTab === 3"
        :dataset-id="datasetId"
        :is-user-logged="isUserLogged"
        :is-viz-saving-prompt-visible="isVizSavingPromptVisible"
        :is-viz-modified="isVizModified"
        :is-viz-item-modified="isVizItemModified"
        :is-viz-saved="isVizSaved"
        :is-private-viz-loading="isPrivateVizLoading"
        :is-public-viz-loading="isPublicVizLoading"
        :public-visualizations="publicVisualizations"
        :private-visualizations="privateVisualizations"
        :private-queries="privateQueries"
        :public-queries="publicQueries"
        :enabled-viz-saved-button="enabledVizSavedButton"
        :current-viz-tab="currentVizTab"
        :enabled-fork-viz-button="enabledForkVizButton"
        :viz-input-focus="vizInputFocus"
        :viz-id="vizID"
        :user-save-viz="userSaveViz"
        :show-private-public-icon-viz="showPrivatePublicIconViz"
        :show-private="showPrivate"
        :show-private-viz="showPrivateViz"
        :show-label-edit="showLabelEdit"
        :reset-private="resetPrivate"
        :object-columns="objectColumns"
      />

      <DownloadsTab
        v-else-if="activeDatasetTab === 4"
        :array-formats="arrayFormats"
        :resources-list="resourcesList"
      />
    </template>
  </div>
</template>

<script>
import { SkeletonSpinner } from "lib/vue-components";
import DatasetNav from "./sets/DatasetNav.vue";
import SummaryTab from "./sets/SummaryTab.vue";
import DataTab from "./sets/DataTab.vue";
import QueriesTab from "./sets/QueriesTab.vue";
import VisualizationsTab from "./sets/VisualizationsTab.vue";
import DownloadsTab from "./sets/DownloadsTab.vue";
import { getUserId, convertToCSV } from "./../../lib/helpers";
import { ROUTE_NAMES, tabs } from "./../../lib/router";
import { DatasetFactoryMixin } from "./../../lib/factories/datasets";
import { QueriesFactoryMixin } from "./../../lib/factories/queries";
import { DataFactoryMixin } from "./../../lib/factories/data";
import { VisualizationFactoryMixin } from "./../../lib/factories/visualizations";

export default {
  name: "Dataset",
  components: {
    SummaryTab,
    DataTab,
    QueriesTab,
    VisualizationsTab,
    DownloadsTab,
    DatasetNav,
    SkeletonSpinner
  },
  mixins: [
    DatasetFactoryMixin,
    QueriesFactoryMixin,
    DataFactoryMixin,
    VisualizationFactoryMixin
  ],
  props: {
    activeDatasetTab: {
      type: Number,
      default: 0
    },
    pageTitle: {
      type: String,
      default: ""
    }
  },
  data() {
    return {
      datasetId: 0, // possible deprecation in DATA, don't in the class
      titleDataset: "",
      arrayFormats: {},
      objectColumns: {},
      attributes: null,
      privateQueries: undefined,
      publicQueries: undefined,
      recentQueries: [],
      publicVisualizations: undefined,
      privateVisualizations: undefined,
      resourcesList: [],
      arrayColumnsQuery: [],
      currentQuery: null,
      currentVizTab: null,
      queryRevert: null,
      items: "",
      isQuerySaved: false,
      isVizSaved: false,
      isQuerySavingPromptVisible: false,
      isQueryRunning: false,
      isQueryModified: false,
      isForkPromptVisible: true,
      isVizModified: false,
      isVizItemModified: false,
      isVizSavingPromptVisible: false,
      showPrivate: false,
      tableName: "",
      defaultLimit: 50,
      enabledQuerySavedButton: false,
      enabledVizSavedButton: false,
      enabledRevertButton: false,
      showRevertQuery: false,
      queryName: null,
      queryDuration: 0,
      queryError: null,
      isUserLogged: false,
      enabledForkButton: false,
      enabledForkVizButton: false,
      isPrivateVizLoading: false,
      queryInputFocus: false,
      isPublicVizLoading: false,
      vizName: null,
      vizID: null,
      userSaveViz: null,
      vizInputFocus: false,
      savingViz: false,
      savingQuery: false,
      showPrivatePublicIcon: false,
      showPrivatePublicIconViz: false,
      showPrivateViz: false,
      showLabelEdit: false,
      resetPrivate: false,
      labelSummary: I18n.t("gobierto_data.projects.summary") || "",
      labelData: I18n.t("gobierto_data.projects.data") || "",
      labelQueries: I18n.t("gobierto_data.projects.queries") || "",
      labelVisualizations:
        I18n.t("gobierto_data.projects.visualizations") || "",
      labelDownload: I18n.t("gobierto_data.projects.download") || ""
    };
  },
  computed: {
    recentQueriesFiltered() {
      return this.recentQueries.length
        ? this.recentQueries
            .filter(sql => (sql || "").includes(this.tableName))
            .reverse()
        : [];
    },
    isDatasetLoaded() {
      // When loading, show skeleton if:
      // 1. Any tab but download OR
      // 2a. Dataset has no attibutes (getDatasetMetadata empty or error) AND
      // 2b. publicQueries or publicVisualization are undefined (getPublicQueries or getPublicVisualizations have fetched no answer)
      return this.activeDatasetTab === 4 || !!(
        this.attributes && !!(this.publicQueries || this.publicVisualizations)
      );
    },
    queryLimit() {
      return this.defaultLimit !== null && this.defaultLimit > 0
        ? ` LIMIT ${this.defaultLimit}`
        : "";
    }
  },
  watch: {
    $route(to, from) {
      const {
        path,
        name,
        params: { queryId }
      } = to;

      // do nothing if the component is inactive
      if (this._inactive) return null

      this.parseUrl(queryId);

      if (path !== from.path) {
        this.isQueryModified = false;
        this.setDefaultQuery();
        this.queryOrVizIsNotMine();
        this.disabledRevertButton();
      }

      if (name === ROUTE_NAMES.Dataset) {
        this.currentVizTab = 0;
        this.vizName = null;

        this.updateBaseTitle();
        this.handleDatasetTabs(this.$route);
      } else if (name === ROUTE_NAMES.Visualization) {
        this.currentVizTab = 1;
        this.showLabelEdit = true;
      }
    }
  },
  beforeRouteEnter(to, from, next) {
    const { name: nameComponent } = to;
    next(vm => {
      vm.showRevertQuery = nameComponent === "Query";
    });
  },
  async created() {
    const {
      name,
      params: { id }
    } = this.$route;

    let responseMetaData;

    try {
      responseMetaData = await this.getDatasetMetadata(id);
    } catch ({ response }) {
      if (response.status === 404) {
        this.$router.push({ name: ROUTE_NAMES.Index });
        throw response;
      }
    }

    const {
      data: {
        data: { id: datasetId, attributes }
      },
      included
    } = responseMetaData;

    this.datasetId = parseInt(datasetId);
    this.resourcesList = included;
    this.attributes = attributes;

    const {
      name: titleDataset,
      table_name: tableName,
      columns: objectColumns,
      formats: arrayFormats,
      default_limit: defaultLimit
    } = attributes;

    this.titleDataset = titleDataset;
    this.tableName = tableName;
    this.objectColumns = objectColumns;
    this.arrayFormats = arrayFormats;
    this.defaultLimit = defaultLimit;

    const userId = getUserId();
    this.isUserLogged = !!(userId && userId.length);

    if (
      [
        ROUTE_NAMES.Dataset,
        ROUTE_NAMES.Query,
        ROUTE_NAMES.Visualization
      ].includes(name)
    ) {
      this.updateBaseTitle();
      this.handleDatasetTabs(this.$route);
    }

    this.queryOrVizIsNotMine();
    this.displayVizSavingPrompt();
  },
  mounted() {
    const recentQueries = localStorage.getItem("recentQueries");
    if (recentQueries) {
      this.recentQueries = JSON.parse(recentQueries);
    }
  },
  activated() {
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
    this.$root.$on("resetQuery", this.resetQuery);
    // reset to the saved query
    this.$root.$on("revertSavedQuery", this.revertSavedQuery);
    // activate button to saved a query
    this.$root.$on("enableSavedButton", this.activatedSavedButton);
    // reset query flow to initial state
    this.$root.$on("eventIsQueryModified", this.eventIsQueryModified);
    // disabled saved button
    this.$root.$on("disabledSavedButton", this.disabledSavedButton);
    //Show a message for the user, your query is saved
    this.$root.$on("disabledStringSavedQuery", this.disabledStringSavedQuery);
    // enabled button to saved a viz
    this.$root.$on("enableSavedVizButton", this.activatedSavedVizButton);
    //if user is logged show a prompt to saved a query
    this.$root.$on(
      "isQuerySavingPromptVisible",
      this.isQuerySavingPromptVisibleHandler
    );
    //if user is logged show a prompt to saved a visualization
    this.$root.$on(
      "isVizSavingPromptVisible",
      this.isVizSavingPromptVisibleHandler
    );
    //When user save a vizusliation show a string
    this.$root.$on("showSavedVizString", this.showSavedVizString);
    //Show a string when the vis is modified
    this.$root.$on("isVizModified", this.eventIsVizModified);
    //Check if the query is ours if it isn't ours show a button to fork
    this.$root.$on("disabledForkButton", this.disabledForkButton);
    this.$root.$on("enabledForkPrompt", this.enabledForkPrompt);
    //If load a query from the other user show a button to revert the code of the editor
    this.$root.$on("enabledRevertButton", this.activatedRevertButton);
    this.$root.$on("disabledRevertButton", this.disabledRevertButton);
    //Show the name of the visualization
    this.$root.$on("loadVizName", this.setVizName);
    //Reload a list of private and public visualizations
    this.$root.$on("reloadVisualizations", this.reloadVisualizations);
    //Check if the visualization is ours if it isn't ours show a button to fork
    this.$root.$on("enabledForkVizButton", this.activateForkVizButton);
    //Update the name of Visualization
    this.$root.$on("updateVizName", this.eventToUpdateVizName);
    //Enable input to write a name for query
    this.$root.$on(
      "eventToEnabledInputQueries",
      this.eventToEnabledInputQueries
    );
    //Reset visualization flow
    this.$root.$on("resetVizEvent", this.resetVizEvent);
    //Show saving dialog visualization
    this.$root.$on("showSavingDialogEvent", this.showSavingDialogEvent);
    //Show saving dialog visualization tab item
    this.$root.$on("showSavingDialogEventViz", this.showSavingDialogEventViz);
  },
  deactivated() {
    this.$root.$off("deleteSavedQuery");
    this.$root.$off("setCurrentQuery");
    this.$root.$off("runCurrentQuery");
    this.$root.$off("storeCurrentQuery");
    this.$root.$off("storeCurrentVisualization");
    this.$root.$off("resetQuery");
    this.$root.$off("revertSavedQuery");
    this.$root.$off("enableSavedButton");
    this.$root.$off("eventIsQueryModified");
    this.$root.$off("disabledSavedButton");
    this.$root.$off("disabledStringSavedQuery");
    this.$root.$off("disabledForkButton");
    this.$root.$off("enabledForkPrompt");
    this.$root.$off("enabledRevertButton");
    this.$root.$off("disabledRevertButton");
    this.$root.$off("isQuerySavingPromptVisible");
    this.$root.$off("eventToEnabledInputQueries");
    this.$root.$off("isVizSavingPromptVisible");
    this.$root.$off("enableSavedVizButton");
    this.$root.$off("showSavedVizString");
    this.$root.$off("isVizModified");
    this.$root.$off("loadVizName");
    this.$root.$off("updateVizName");
    this.$root.$off("reloadVisualizations");
    this.$root.$off("enabledForkVizButton");
    this.$root.$off("resetVizEvent");
    this.$root.$off("showSavingDialogEvent");
  },
  methods: {
    async handleDatasetTabs(path) {
      const {
        name,
        params: { queryId, tab },
        query: { sql }
      } = path;

      switch (true) {
        // resumen
        case (!tab && !queryId) || tab === tabs[0]: {
          await this.getAllQueries();
          await this.getAllVisualizations();
          break;
        }
        // datos or /q/:id
        case tab === tabs[1]:
        case name === ROUTE_NAMES.Query: {
          await this.getAllQueries();
          this.parseUrl(queryId, sql);
          this.runCurrentQuery();
          this.setDefaultQuery();
          break;
        }
        // consultas
        case tab === tabs[2]: {
          await this.getAllQueries();
          break;
        }
        // visualizaciones or /v/:id
        case tab === tabs[3]:
        case name === ROUTE_NAMES.Visualization: {
          await this.getAllVisualizations();
          break;
        }

        default:
          break;
      }
    },
    updateBaseTitle() {
      const {
        name: nameComponent,
        params: { tab: tabName }
      } = this.$route;
      if (nameComponent === ROUTE_NAMES.Dataset && this.titleDataset) {
        let title;
        let tabTitle;

        const titleI18n = this.titleDataset ? `${this.titleDataset} · ` : "";

        if (tabName === tabs[1]) {
          tabTitle = `${this.labelData} · `;
        } else if (tabName === tabs[2]) {
          tabTitle = `${this.labelQueries} · `;
        } else if (tabName === tabs[3]) {
          tabTitle = `${this.labelVisualizations} · `;
        } else if (tabName === tabs[4]) {
          tabTitle = `${this.labelDownload} · `;
        } else {
          tabTitle = `${this.labelSummary} · `;
        }
        title = `${titleI18n} ${tabTitle} ${this.pageTitle}`;
        document.title = title;
      }
    },
    displayVizSavingPrompt() {
      if (this.isUserLogged) {
        this.isVizSavingPromptVisible = true;
      }
    },
    parseUrl(queryId, queryText) {
      let item = null;
      if (queryId) {
        // if has id it's an stored query
        item = [...this.privateQueries || [], ...this.publicQueries || []].find(
          ({ id }) => id === queryId
        );
      }

      if (item) {
        const {
          attributes: { sql, name, user_id, privacy_status }
        } = item;

        this.queryName = name;
        this.queryUserId = user_id;
        this.showPrivate = (privacy_status === "closed");

        this.setCurrentQuery(sql);
      } else if (queryText) {
        this.setCurrentQuery(decodeURIComponent(queryText));
      }
    },
    setDefaultQuery() {
      const {
        params: { queryId }
      } = this.$route;

      //We need to keep this query separate from the editor query
      //When load a saved query we use the queryId to find inside privateQueries or publicQueries
      const items = !this.showPrivate
        ? this.publicQueries
        : this.privateQueries;
      const { attributes: { sql: queryRevert } = {} } =
        items?.find(({ id }) => id === queryId) || {};
      //QueryRevert: if the user loads a saved query, there can reset to the initial query or reset to the saved query.
      this.queryRevert = queryRevert;
    },
    isQueryStored(query = this.currentQuery) {
      // check if the query passed belongs to public/private arrays, if there's no args, it uses currentQuery
      return !!(
        this.publicQueries?.some(({ attributes: { sql } }) => sql === query) ||
        this.privateQueries?.some(({ attributes: { sql } }) => sql === query)
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

      this.currentQuery = sql;
    },
    storeRecentQuery() {
      // if the currentQuery does not exist, nor recent, nor in stored queries neither
      // then save it in recent ones, and update localStorage
      if (
        !this.recentQueries.some(query => query === this.currentQuery) &&
        !this.isQueryStored()
      ) {
        this.recentQueries.push(this.currentQuery);
        localStorage.setItem(
          "recentQueries",
          JSON.stringify(this.recentQueries)
        );
      }
    },
    async getAllQueries() {
      const queriesPromises = [];

      // Even though there was no publicQueries,
      // we need to keep the position of the publicResponse in the promises array
      queriesPromises.push(
        !this.publicQueries ? this.getPublicQueries() : Promise.resolve()
      );

      const userId = getUserId();
      // Do not request private queries if the user is not logged
      // OR if the privateQueries has been already fetched
      queriesPromises.push(
        userId && !this.privateQueries
          ? this.getPrivateQueries(userId)
          : Promise.resolve()
      );

      // In order to update from the url, we need both public and private queries
      const [publicResponse, privateResponse] = await Promise.all(
        queriesPromises
      );

      // Only update data if there's any response
      if (publicResponse) {
        this.setPublicQueries(publicResponse);
      }

      if (privateResponse) {
        this.setPrivateQueries(privateResponse);
      }
    },
    getPrivateQueries(id) {
      // factory method
      return this.getQueries({
        "filter[dataset_id]": this.datasetId,
        "filter[user_id]": id
      });
    },
    setPrivateQueries(response) {
      const {
        data: { data }
      } = response;
      this.privateQueries = data;
    },
    getPublicQueries() {
      // factory method
      return this.getQueries({ "filter[dataset_id]": this.datasetId });
    },
    setPublicQueries(response) {
      const {
        data: { data }
      } = response;
      this.publicQueries = data;
    },
    async reloadQueries() {
      // getAllQueries DOES NOT update, then we enforce it
      this.setPrivateQueries(await this.getPrivateQueries(getUserId()));
      this.setPublicQueries(await this.getPublicQueries());
    },
    async getAllVisualizations() {
      const visualizationsPromises = [];

      // Even though there was no publicVisualizations,
      // we need to keep the position of the publicResponse in the promises array
      visualizationsPromises.push(
        !this.publicVisualizations
          ? this.getPublicVisualizations()
          : Promise.resolve()
      );

      const userId = getUserId();
      // Do not request private visualizations if the user is not logged
      // OR if the privateVisualizations has been already fetched
      visualizationsPromises.push(
        userId && !this.privateVisualizations
          ? this.getPrivateVisualizations(userId)
          : Promise.resolve()
      );

      // In order to update from the url, we need both public and private visualizations
      const [publicResponse, privateResponse] = await Promise.all(
        visualizationsPromises
      );

      // Only update data if there's any response
      if (publicResponse) {
        this.setPublicVisualizations(publicResponse);
      }

      if (privateResponse) {
        this.setPrivateVisualizations(privateResponse);
      }
    },
    getPrivateVisualizations(id) {
      this.isPrivateVizLoading = true;
      // factory method
      return this.getVisualizations({
        "filter[dataset_id]": this.datasetId,
        "filter[user_id]": id
      });
    },
    async setPrivateVisualizations(response) {
      const {
        data: { data }
      } = response;
      this.privateVisualizations = await this.getDataFromVisualizations(data);

      this.isPrivateVizLoading = false;
    },
    getPublicVisualizations() {
      this.isPublicVizLoading = true;
      // factory method
      return this.getVisualizations({ "filter[dataset_id]": this.datasetId });
    },
    async setPublicVisualizations(response) {
      const {
        data: { data }
      } = response;
      this.publicVisualizations = await this.getDataFromVisualizations(data);

      this.isPublicVizLoading = false;
    },
    async reloadVisualizations() {
      // getAllVisualizations DOES NOT update, then we enforce it
      this.setPrivateVisualizations(await this.getPrivateVisualizations(getUserId()));
      this.setPublicVisualizations(await this.getPublicVisualizations());
    },
    async getDataFromVisualizations(data) {
      const visualizations = [];
      for (let index = 0; index < data.length; index++) {
        const { attributes = {}, id } = data[index];
        const {
          query_id,
          user_id,
          sql = "",
          spec = {},
          name = "",
          privacy_status = "open"
        } = attributes;

        let queryData = null;

        if (query_id) {
          // Get my queries, if they're stored
          const { data } = await this.getQuery(query_id);
          queryData = data;
        } else {
          // Otherwise, run the sql
          const { sql } = attributes;
          const { data } = await this.getData({ sql });
          queryData = data;
        }

        let items = "";
        if (typeof queryData === "object") {
          items = convertToCSV(queryData.data);
        } else {
          items = queryData;
        }

        // Append the visualization configuration
        const visualization = {
          items,
          config: spec,
          name,
          privacy_status,
          query_id,
          id,
          user_id,
          sql
        };

        visualizations.push(visualization);
      }

      return visualizations;
    },
    async deleteSavedQuery(id) {
      // factory method
      const { status } = await this.deleteQuery(id);

      if (status === 204) {
        this.reloadQueries()
      }
    },
    async storeCurrentQuery({ name, privacy }) {
      this.savingViz = false;
      this.savingQuery = true;

      const {
        params: { queryId }
      } = this.$route;

      if (!queryId && !this.isQuerySavingPromptVisible) {
        this.isQuerySavingPromptVisible = true;
        this.queryInputFocus = true;
      } else if (!this.labelValue) {
        this.queryInputFocus = true;
      }

      const data = {
        type: "gobierto_data-queries",
        attributes: {
          privacy_status: privacy ? "closed" : "open",
          sql: this.currentQuery,
          name,
          dataset_id: this.datasetId
        }
      };

      const userId = Number(getUserId());
      let status = null; // https://javascript.info/destructuring-assignment
      let newQuery;

      // Only update the query is the user and the name are the same
      if (name === this.queryName && userId === this.queryUserId) {
        const { queryId } = this.$route.params;
        // factory method
        try {
          ({ status } = await this.putQuery(queryId, { data }));
        } catch (error) {
          this.queryError = this.destructuringStoreQueryError(error);
        }

        //Update revert query
        this.queryRevert = this.currentQuery;
      } else {
        // factory method
        try {
          ({
            status,
            data: { data: newQuery }
          } = await this.postQuery({ data }));
        } catch (error) {
          this.queryError = this.destructuringStoreQueryError(error);
        }
      }

      // reload the queries if the response was successfull
      // 200 OK (PUT) / 201 Created (POST)
      if ([200, 201].includes(status)) {
        //Show a message for the user, your query is saved
        this.isQuerySaved = true;
        this.enabledQuerySavedButton = false;
        this.isQueryModified = false;
        this.isQuerySavingPromptVisible = false;

        this.reloadQueries()

        if (userId !== this.queryUserId || newQuery) {
          this.updateURL(newQuery);
        }
      }
    },
    async runCurrentQuery() {
      this.isQueryRunning = true;

      // save the query executed
      this.storeRecentQuery();

      let params = { sql: this.currentQuery };

      if (this.currentQuery === null) {
        this.currentQuery = `SELECT * FROM ${this.tableName}${this.queryLimit}`;
        params = { sql: this.currentQuery };
      }

      // update url with a temporal parameter
      this.$router.push({ ...this.$route, query: { ...this.$route.query, sql: encodeURIComponent(this.currentQuery) } }).catch(()=>{})

      const startTime = new Date().getTime();
      // factory method
      try {
        const { data: items } = await this.getData(params);

        this.items = items;
        this.queryDuration = new Date().getTime() - startTime;
        this.isQueryRunning = false;
        this.getColumnsQuery(this.items);
        this.queryError = null;
      } catch ({
        response: {
          data: { errors: [{ sql: stringError } = {}] = [] }
        }
      }) {
        this.queryError = stringError;
        this.isQueryRunning = false;
        this.enabledQuerySavedButton = false;
      }
    },
    async storeCurrentVisualization(config, opts) {
      const {
        params: { queryId },
        name: nameComponent
      } = this.$route;

      let vizIdFromRoute = +queryId;

      this.savingViz = true;
      this.savingQuery = false;

      if (!this.isVizSavingPromptVisible) {
        this.isVizSavingPromptVisible = true;
        this.vizInputFocus = true;
      } else if (!this.vizName) {
        this.vizInputFocus = true;
      }

      const { name, privacy, vizID, user, queryViz } = opts;
      this.vizName = name;

      const userId = Number(getUserId());

      // Get the id if the query matches with a stored query
      const { id } =
        this.privateQueries.find(
          ({ attributes: { sql } }) => sql === this.currentQuery
        ) || {};

      let currentQueryViz = !queryViz ? this.currentQuery : queryViz;

      // default attributes
      let attributes = {
        name_translations: {
          en: name,
          es: name
        },
        privacy_status: privacy ? "closed" : "open",
        spec: config,
        user_id: user,
        dataset_id: this.datasetId,
        query_id: id,
        sql: currentQueryViz
      };

      // POST data obj
      const data = {
        type: "gobierto_data-visualizations",
        attributes
      };

      let status = null;
      let newViz;

      if (vizID === vizIdFromRoute && user === userId) {
        // factory method
        ({ status } = await this.putVisualization(vizID, { data }));
      } else {
        // factory method
        ({
          status,
          data: { data: newViz }
        } = await this.postVisualization({ data }));
        const {
          id: saveVizID,
          attributes: { user_id: user }
        } = newViz;
        this.vizID = +saveVizID;
        this.userSaveViz = user;
      }

      if ([200, 201].includes(status)) {
        this.isVizModified = false;
        this.isVizSaved = true;
        this.isVizSavingPromptVisible = false;
        this.enabledVizSavedButton = false;
        /* Check if the user saved a viz from another user, we need to wait to obtain the private visualizations to avoid error because it's possible which this Visualization is the first Visualization which user save */
        /*Update URL only when saved a query from editor or a viz from Visualizations tabs*/
        if (
          (user !== userId || newViz) &&
          nameComponent === ROUTE_NAMES.Visualization
        ) {
          this.updateURL(newViz);
        }

        this.reloadVisualizations()
      }
    },
    updateURL(element) {
      const { id: queryId } = element;
      this.$router.push({
        name: this.savingViz ? ROUTE_NAMES.Visualization : ROUTE_NAMES.Query,
        params: { ...this.$route.params, queryId }
      });

      this.enabledForkButton = false;
      this.queryInputFocus = false;
      this.enabledForkVizButton = false;
      this.isVizSaved = true;
    },
    getColumnsQuery(csv = "") {
      const [columns = ""] = csv.split("\n");
      this.arrayColumnsQuery = columns.split(",");
    },
    resetQuery() {
      this.isQuerySavingPromptVisible = false;
      this.currentQuery = `SELECT * FROM ${this.tableName}${this.queryLimit}`;
      this.isQueryModified = false;
      this.runCurrentQuery();
      this.disabledSavedButton();
      this.disabledStringSavedQuery();
      this.queryName = null;
      this.disabledForkButton();
      this.showPrivatePublicIcon = false;
      this.showPrivate = false;
      this.resetPrivate = true;
    },
    revertSavedQuery() {
      this.isQuerySavingPromptVisible = false;
      this.currentQuery = this.queryRevert;
      this.isQueryModified = false;
      this.runCurrentQuery();
      this.disabledSavedButton();
      this.disabledStringSavedQuery();
      this.disabledRevertButton();

      const userId = Number(getUserId());
      if (this.queryUserId !== userId) {
        this.showPrivatePublicIcon = false;
        this.enabledForkButton = true;
        this.isForkPromptVisible = true;
      } else {
        this.showPrivatePublicIcon = true;
      }
    },
    activatedSavedButton() {
      this.enabledQuerySavedButton = true;
      this.isQueryModified = true;
      const { name: name } = this.$route;

      if (name === ROUTE_NAMES.Query) {
        this.showRevertQuery = true;
      }

      this.resetPrivate = false;
    },
    disabledSavedButton() {
      this.enabledQuerySavedButton = false;
    },
    eventIsQueryModified(value) {
      this.isQueryModified = value;
      this.enabledQuerySavedButton = true;
    },
    resetToInitialStateSavedQuery() {
      this.showRevertQuery = true;
      this.isQueryModified = false;
    },
    disabledStringSavedQuery() {
      this.isQuerySaved = false;
    },
    isSavingPromptVisibleHandler(value) {
      this.isSavingPromptVisible = value;
    },
    queryOrVizIsNotMine() {
      const userId = Number(getUserId());
      const {
        params: { queryId },
        name: nameComponent
      } = this.$route;

      //Find which query is loaded
      if (userId !== 0 && nameComponent === ROUTE_NAMES.Query) {
        const items = !this.showPrivate
          ? this.publicQueries
          : this.privateQueries;
        const { attributes: { user_id: checkUserId } = {} } =
          items?.find(({ id }) => id === queryId) || {};

        //Check if the user who loaded the query is the same user who created the query
        if (userId !== checkUserId) {
          this.showPrivatePublicIcon = false;
          this.enabledForkButton = true;
          this.isForkPromptVisible = true;
        } else {
          this.showPrivatePublicIcon = true;
          this.disabledForkButton();
        }
      } else if (userId !== 0 && nameComponent === ROUTE_NAMES.Visualization) {
        this.showLabelEdit = true;

        const objectViz =
          this.privateVisualizations?.find(({ id }) => id === queryId) || {};
        const { privacy_status: privacyStatus } = objectViz;

        this.showPrivateViz = privacyStatus === "closed" ? true : false;
        const items = !this.showPrivateViz
          ? this.publicVisualizations
          : this.privateVisualizations;

        //Find which viz is loaded
        const { user_id: checkUserId = {} } =
          items?.find(({ id }) => id === queryId) || {};

        this.vizUserId = checkUserId;

        //Check if the user who loaded the viz is the same user who created the viz
        if (userId !== checkUserId && !this.savingViz) {
          this.enabledForkVizButton = true;
          this.showPrivatePublicIconViz = false;
        } else {
          this.showPrivatePublicIconViz = true;
          this.enabledForkVizButton = false;
        }
      }
    },
    disabledForkButton() {
      this.enabledForkButton = false;
    },
    enabledForkPrompt() {
      this.isForkPromptVisible = true;
    },
    disabledRevertButton() {
      this.enabledRevertButton = false;
    },
    activatedRevertButton() {
      this.enabledRevertButton = true;
      this.showPrivatePublicIcon = true;
    },
    showSavedVizString(value) {
      this.isVizSaved = value;
    },
    isQuerySavingPromptVisibleHandler(value) {
      this.isQuerySavingPromptVisible = value;
    },
    activatedSavedVizButton(value) {
      this.enabledVizSavedButton = value;
    },
    isVizSavingPromptVisibleHandler(value) {
      this.isVizSavingPromptVisible = value;
    },
    eventIsVizModified(value) {
      this.isVizModified = value;
    },
    setVizName(vizName) {
      this.vizName = vizName;
    },
    activateForkVizButton(value) {
      this.enabledForkVizButton = value;
      this.userSaveViz = null;
    },
    eventToUpdateVizName() {
      this.isVizModified = true;
      this.enabledVizSavedButton = true;
    },
    eventToEnabledInputQueries() {
      this.activatedSavedButton();
      this.isForkPromptVisible = true;
      this.enabledRevertButton = false;
    },
    resetVizEvent() {
      this.enabledVizSavedButton = true;
      this.vizName = null;
    },
    showSavingDialogEvent() {
      this.enabledVizSavedButton = true;
      this.isVizModified = true;
      this.showPrivatePublicIconViz = true;
      this.isVizSavingPromptVisible = true;
    },
    showSavingDialogEventViz(value) {
      this.isVizItemModified = value;
      this.isVizModified = false;
      this.activatedSavedVizButton(value);
      this.showPrivatePublicIconViz = true;
    },
    destructuringStoreQueryError(error) {
      const {
        response: {
          data: { errors: [{ detail } = {}] = [] }
        }
      } = error;
      return detail;
    }
  }
};
</script>
