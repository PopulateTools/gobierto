<template>
  <div>
    <div class="gobierto-data-sql-editor">
      <SQLEditorHeader
        :array-queries="arrayQueries"
        :dataset-id="datasetId"
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
      rawDataSlug: [],
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
      nameDataset: ''
    }
  },
  created(){
    this.$root.$on('sendYourCode', this.runYourQuery)
  },
  mounted() {
    this.$root.$on('postRecentQuery', this.saveNewRecentQuery)
    this.$root.$on('activateModalRecent', this.saveRecentQuery)
    if (localStorage.getItem('recentQueries')) {
      try {
        this.recentQueries = JSON.parse(localStorage.getItem('recentQueries'));
      } catch (e) {
        localStorage.removeItem('recentQueries');
      }
    }
    this.$root.$on('activateModalRecent', this.loadRecentQuery)
    this.getSlug()
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
        this.newRecentQuery = '';
        this.saveRecentQuery();
      }
    },
    saveRecentQuery() {
      const parsed = JSON.stringify(this.recentQueries);
      localStorage.setItem('recentQueries', parsed);
      this.$root.$emit('storeQuery', this.recentQueries)
    },
    loadRecentQuery() {
      this.$root.$emit('storeQuery', this.recentQueries)
    },
    getSlug() {
      this.endPointSlug = `${baseUrl}/datasets`
      axios
        .get(this.endPointSlug)
        .then(response => {
          this.rawDataSlug = response.data
          this.queryEditor = `SELECT%20*%20FROM%20${this.tableName}%20`
          this.getData()

        })
        .catch(error => {
          console.error(error)
        })
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
