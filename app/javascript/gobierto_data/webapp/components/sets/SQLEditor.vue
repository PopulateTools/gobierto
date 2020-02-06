<template>
  <div>
    <div class="gobierto-data-sql-editor">
      <SQLEditorHeader
        :array-queries="arrayQueries"
        :dataset-id="datasetId"
        :table-name="tableName"
      />
      <SQLEditorCode
        :table-name="tableName"
      />
      <SQLEditorTabs
        v-if="data"
        :array-formats="arrayFormats"
        :items="data"
        :link="link"
        :active-tab="activeTabIndex"
        :array-queries="arrayQueries"
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
    arrayFormats: {
      type: Object,
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
      data: null,
      keysData: [],
      meta:[],
      links:[],
      link: '',
      queryEditor: '',
      url: '',
      endPoint: '',
      recentQueries: [],
      newRecentQuery: null,
      orderRecentQueries: [],
      totalRecentQueries: [],
      tempRecentQueries: [],
      localQueries: [],
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
      } catch (e) {
        localStorage.removeItem('recentQueries');
      }
    }
    this.addRecentQuery()
    this.$root.$on('activateModalRecent', this.loadRecentQuery)
  },
  mounted() {
    this.$root.$on('postRecentQuery', this.saveNewRecentQuery)
    this.queryEditor = `SELECT%20*%20FROM%20${this.tableName}%20`
    this.getData()
  },
  methods: {
    runYourQuery(sqlCode){
      this.queryDefault = false
      this.getSlug()
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
      this.endPoint = `${baseUrl}/data`
      this.url = `${this.endPoint}?sql=${this.queryEditor}`

      axios
        .get(this.url)
        .then(response => {
          this.rawData = response.data
          this.meta = this.rawData.meta
          this.data = this.rawData.data

          this.queryDurationRecors = [this.meta.rows, this.meta.duration]
          this.$root.$emit('recordsDuration', this.queryDurationRecors)

          this.keysData = Object.keys(this.data[0])
          this.$root.$emit('sendData', this.keysData)

        })
        .catch(error => {
          this.$root.$emit('apiError', error)
          this.data = []
          this.keysData = []
          this.$root.$emit('sendData', this.keysData)
        })
    },
    saveNewRecentQuery(query) {
      this.newRecentQuery = query
      this.addRecentQuery()
    }
  }
}
</script>
