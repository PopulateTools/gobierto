<template>
  <div class="gobierto-data-sets-nav--tab-container">
    <div class="gobierto-data-sql-editor">
      <SQLEditorHeader
        v-if="publicQueries.length"
        :private-queries="privateQueries"
        :public-queries="publicQueries"
        :dataset-id="datasetId"
        :table-name="tableName"
        :number-rows="numberRows"
      />
      <SQLEditorCode
        :text-editor-content="currentQuery"
        :table-name="tableName"
        :array-columns="arrayColumns"
        :number-rows="numberRows"
      />
      <SQLEditorResults
        v-if="items"
        :array-formats="arrayFormats"
        :items="items"
        :link="link"
        :table-name="tableName"
        :active-tab="activeTabIndex"
        :private-queries="privateQueries"
        :number-rows="numberRows"
        :dataset-id="datasetId"
        :current-query="currentQuery"
        @active-tab="activeTabIndex = $event"
      />
    </div>
  </div>
</template>
<script>
import SQLEditorCode from "./data/SQLEditorCode.vue";
import SQLEditorHeader from "./data/SQLEditorHeader.vue";
import SQLEditorResults from "./data/SQLEditorResults.vue";
import { DataFactoryMixin } from "./../../../lib/factories/data"
import "./../../../lib/sql-theme.css"

export default {
  name: 'DataTab',
  components: {
    SQLEditorCode,
    SQLEditorHeader,
    SQLEditorResults
  },
  mixins: [DataFactoryMixin],
  props: {
    tableName: {
      type: String,
      required: true
    },
    privateQueries: {
      type: Array,
      required: true
    },
    arrayColumns: {
      type: Object,
      required: true
    },
    publicQueries: {
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
    datasetId: {
      type: Number,
      required: true
    }
  },
  data() {
    return {
      activeTabIndex: 0,
      rawData: [],
      columns: [],
      items: null,
      keysData: [],
      meta:[],
      links:[],
      link: '',
      recentQueries: [],
      localQueries: [],
      orderRecentQueries: [],
      totalRecentQueries: [],
      newRecentQuery: null,
      localTableName : '',
      currentQuery: `SELECT * FROM ${this.tableName}`
    }
  },
  created() {
    this.localTableName = this.tableName

    if (localStorage.getItem('recentQueries')) {
      try {
        this.recentQueries = JSON.parse(localStorage.getItem('recentQueries'));
        this.localQueries = JSON.parse(localStorage.getItem('savedData'));
        this.addRecentQuery()
      } catch (e) {
        localStorage.removeItem('recentQueries');
      }
    }

    this.$root.$on('runQuery', this.runQuery)
    this.$root.$on('editCurrentQuery', this.editCurrentQuery)

    this.$root.$on('activateModalRecent', this.loadRecentQuery)
    this.$root.$on('postRecentQuery', this.saveNewRecentQuery)
  },
  mounted() {
    if (this.currentQuery) {
      this.runQuery()
    }
  },
  beforeDestroy() {
    this.$root.$off('runQuery', this.runQuery)
    this.$root.$off('editCurrentQuery', this.editCurrentQuery)
    this.$root.$off('postRecentQuery', this.saveNewRecentQuery)
    this.$root.$off('activateModalRecent', this.loadRecentQuery)
  },
  methods: {
    addRecentQuery() {
      if (!this.newRecentQuery) {
        return;
      }
      if (Object.values(this.recentQueries).indexOf(this.newRecentQuery) > -1) {
        this.$root.$emit('store', this.recentQueries)
      } else {
        this.recentQueries.push(this.newRecentQuery);
        localStorage.setItem('recentQueries', JSON.stringify(this.recentQueries));

        if (this.localTableName === this.tableName) {
          this.orderRecentQueries = [{
            dataset: this.tableName,
            text: this.newRecentQuery
          }]
          this.newRecentQuery = '';

          const tempRecentQueries = [ ...this.localQueries, ...this.orderRecentQueries ]
          this.totalRecentQueries = tempRecentQueries
          this.orderRecentQueries = []
          localStorage.setItem("savedData", JSON.stringify(this.totalRecentQueries));

          this.saveRecentQuery(this.totalRecentQueries);
        }
      }
    },
    saveRecentQuery() {
      localStorage.setItem("savedData", JSON.stringify(this.totalRecentQueries));
      this.$root.$emit('storeQuery', this.totalRecentQueries)
    },
    loadRecentQuery() {
      this.totalRecentQueries = this.localQueries
      this.$root.$emit('storeQuery', this.totalRecentQueries)
    },
    editCurrentQuery(text) {
      this.currentQuery = text

      console.log('editCurrentQuery', text);
    },
    runQuery() {
      let query = ''
      if (this.currentQuery.includes('LIMIT')) {
        query = this.currentQuery
      } else {
        query = `SELECT * FROM (${this.currentQuery}) AS data_limited_results LIMIT 100 OFFSET 0`
      }

      const params = { sql: query }

      // factory method
      this.getData(params)
        .then(response => {
          const rawData = response.data
          const data = rawData.data
          this.items = data

          const keysData = Object.keys(data[0])
          this.$root.$emit('sendDataViz', keysData)
        })
        .catch(error => this.$root.$emit('apiError', error))
    },
    saveNewRecentQuery(query) {
      this.newRecentQuery = query
      this.currentQuery = query
      this.addRecentQuery()
    }
  }
}

</script>
