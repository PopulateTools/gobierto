<template>
  <div>
    <div class="gobierto-data-sql-editor">
      <SQLEditorHeader
        :array-queries="arrayQueries"
        :public-queries="publicQueries"
        :dataset-id="datasetId"
        :table-name="tableName"
        :number-rows="numberRows"
      />
      <SQLEditorCode
        :table-name="tableName"
        :array-columns="arrayColumns"
        :number-rows="numberRows"
      />
      <SQLEditorTabs
        v-if="dataLoaded"
        :array-formats="arrayFormats"
        :items="items"
        :table-name="tableName"
        :active-tab="activeTabIndex"
        :array-queries="arrayQueries"
        :number-rows="numberRows"
        :dataset-id="datasetId"
        :current-query="currentQuery"
        @active-tab="activeTabIndex = $event"
      />
    </div>
  </div>
</template>
<script>
import SQLEditorCode from "./SQLEditorCode.vue";
import SQLEditorHeader from "./SQLEditorHeader.vue";
import SQLEditorTabs from "./SQLEditorTabs.vue";
import { DataFactoryMixin } from "./../../../lib/factories/data"
import "./../../../lib/sql-theme.css"

export default {
  name: 'SQLEditor',
  components: {
    SQLEditorCode,
    SQLEditorHeader,
    SQLEditorTabs
  },
  mixins: [DataFactoryMixin],
  props: {
    tableName: {
      type: String,
      required: true
    },
    arrayQueries: {
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
      queryEditor: '',
      recentQueries: [],
      localQueries: [],
      orderRecentQueries: [],
      totalRecentQueries: [],
      newRecentQuery: null,
      localTableName : '',
      currentQuery: '',
      dataLoaded: false
    }
  },
  created() {
    this.localTableName = this.tableName
    this.$root.$on('sendYourCode', this.runYourQuery)
    if (localStorage.getItem('recentQueries')) {
      try {
        this.recentQueries = JSON.parse(localStorage.getItem('recentQueries'));
        this.localQueries = JSON.parse(localStorage.getItem('savedData'));
        this.addRecentQuery()
      } catch (e) {
        localStorage.removeItem('recentQueries');
      }
    }

    this.$root.$on('activateModalRecent', this.loadRecentQuery)
  },
  mounted() {
    this.$root.$on('postRecentQuery', this.saveNewRecentQuery)
    this.queryEditor = `SELECT * FROM ${this.tableName} `

    this.prepareData()
  },
  methods: {
    runYourQuery(sqlCode) {
      this.queryEditor = sqlCode
    },
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
      const localQueries = JSON.parse(localStorage.getItem('savedData') || "[]");
      this.$root.$emit('storeQuery', localQueries)
    },
    prepareData() {
      let query = ''
      const queryEditorLowerCase = this.queryEditor.toLowerCase()

      if (queryEditorLowerCase.includes('limit')) {
        this.$root.$emit('hiddeShowButtonColumns')
      } else {
        this.$root.$emit('ShowButtonColumns')
        this.$root.$emit('sendCompleteQuery', this.queryEditor)

        query = `SELECT * FROM (${this.queryEditor}) AS data_limited_results LIMIT 100 OFFSET 0`
      }

      // save the query in the editor
      this.currentQuery = this.queryEditor

      // this will become into ?sql=${query}
      const params = { sql: query }

      // factory method
      this.getData(params)
        .then(response => {
          const rawData = response.data
          const data = rawData.data
          this.items = data
          this.dataLoaded = true

          const keysData = Object.keys(data[0])
          this.$root.$emit('sendDataViz', keysData)
        })
        .catch(error => {
          this.$root.$emit('apiError', error)
          const keysData = []
          this.$root.$emit('sendData', keysData)
        })
    },
    saveNewRecentQuery(query) {
      this.newRecentQuery = query
      this.currentQuery = query
      this.addRecentQuery()
    }
  }
}

</script>
