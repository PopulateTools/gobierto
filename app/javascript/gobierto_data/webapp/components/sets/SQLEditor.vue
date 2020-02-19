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
        v-if="items"
        :array-formats="arrayFormats"
        :items="items"
        :link="link"
        :table-name="tableName"
        :active-tab="activeTabIndex"
        :array-queries="arrayQueries"
        :number-rows="numberRows"
        @active-tab="activeTabIndex = $event"
      />
    </div>
  </div>
</template>
<script>
import axios from 'axios';
import SQLEditorCode from "./SQLEditorCode.vue";
import SQLEditorHeader from "./SQLEditorHeader.vue";
import SQLEditorTabs from "./SQLEditorTabs.vue";
import { baseUrl } from "./../../../lib/commons.js"
import "./../../../lib/sql-theme.css"

export default {
  name: 'SQLEditor',
  components: {
    SQLEditorCode,
    SQLEditorHeader,
    SQLEditorTabs
  },
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
      url: '',
      endPoint: '',
      recentQueries: [],
      orderRecentQueries: [],
      totalRecentQueries: [],
      tempRecentQueries: [],
      localQueries: [],
      newRecentQuery: null,
      localTableName : ''
    }
  },
  created(){
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
    this.queryEditor = `SELECT%20*%20FROM%20${this.tableName}%20`
    this.getData()
  },
  methods: {
    runYourQuery(sqlCode){
      this.queryEditor = sqlCode
    },
    addRecentQuery() {
      if (!this.newRecentQuery) {
        return;
      }
      if (Object.values(this.recentQueries).indexOf(this.newRecentQuery) > -1) {
        this.$root.$emit('storeQuery', this.recentQueries)
      } else {
        this.recentQueries.push(this.newRecentQuery);
        localStorage.setItem('recentQueries', JSON.stringify(this.recentQueries));

        if (this.localTableName === this.tableName) {
          for (let i = 0; i < 1; i++) {
            this.orderRecentQueries[i] = {
              dataset: this.tableName,
              text: this.newRecentQuery
            }
          }
          this.newRecentQuery = '';

          this.localQueries = JSON.parse(localStorage.getItem('savedData') || "[]");
          this.tempRecentQueries = [ ...this.localQueries, ...this.orderRecentQueries ]
          this.totalRecentQueries = this.tempRecentQueries
          this.orderRecentQueries = []
          localStorage.setItem("savedData", JSON.stringify(this.totalRecentQueries));

          this.saveRecentQuery();
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
    getData() {
      const endPoint = `${baseUrl}/data`
      const url = `${endPoint}?sql=${this.queryEditor}`

      if (this.queryEditor.includes('LIMIT')) {
        this.queryEditor = this.queryEditor
      } else {
        this.$root.$emit('sendCompleteQuery', this.queryEditor)
        this.code = `SELECT%20*%20FROM%20(${this.queryEditor})%20AS%20data_limited_results%20LIMIT%20100%20OFFSET%200`
        this.queryEditor = this.code
      }

      axios
        .get(url)
        .then(response => {
          const rawData = response.data
          const data = rawData.data
          this.items = data


          const keysData = Object.keys(data[0])
          this.$root.$emit('sendData', keysData)

        })
        .catch(error => {
          this.$root.$emit('apiError', error)
          const keysData = []
          this.$root.$emit('sendData', keysData)
        })
    },
    saveNewRecentQuery(query) {
      this.newRecentQuery = query
      this.addRecentQuery()
    }
  }
}
</script>
