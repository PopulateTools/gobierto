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
      type: Array,
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
      newRecentQuery: null,
      localTableName : ''
    }
  },
  created(){
    this.localTableName = this.tableName
    this.$root.$on('sendYourCode', this.runYourQuery)
    if (localStorage.getItem('recentQueries')) {
      try {
        const recentQueries = JSON.parse(localStorage.getItem('recentQueries'));
        const localQueries = JSON.parse(localStorage.getItem('savedData'));
        this.addRecentQuery(recentQueries, localQueries)
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
      this.queryDefault = false
      this.getSlug()
      this.queryEditor = sqlCode
    },
    addRecentQuery(recentQueries, localQueries) {
      if (!this.newRecentQuery) {
        return;
      }

      if (Object.values(recentQueries).indexOf(this.newRecentQuery) > -1) {
        this.$root.$emit('store', recentQueries)
      } else {
        recentQueries.push(this.newRecentQuery);
        localStorage.setItem('recentQueries', JSON.stringify(recentQueries));

        if (this.localTableName === this.tableName) {
          let orderRecentQueries
          for (let i = 0; i < 1; i++) {
            orderRecentQueries[i] = {
              dataset: this.tableName,
              text: this.newRecentQuery
            }
          }
          this.newRecentQuery = '';

          localQueries = JSON.parse(localStorage.getItem('savedData') || "[]");
          const tempRecentQueries = [ ...localQueries, ...orderRecentQueries ]
          const totalRecentQueries = tempRecentQueries
          orderRecentQueries = []
          localStorage.setItem("savedData", JSON.stringify(totalRecentQueries));

          this.saveRecentQuery(totalRecentQueries);
        }
      }
    },
    saveRecentQuery(totalRecentQueries) {
      localStorage.setItem("savedData", JSON.stringify(totalRecentQueries));
      this.$root.$emit('storeQuery', totalRecentQueries)
    },
    loadRecentQuery() {
      const localQueries = JSON.parse(localStorage.getItem('savedData') || "[]");
      this.$root.$emit('storeQuery', localQueries)
    },
    getData() {
      this.endPoint = `${baseUrl}/data`

      if (this.queryEditor.includes('LIMIT')) {
        this.queryEditor = this.queryEditor
      } else {
        this.$root.$emit('sendCompleteQuery', this.queryEditor)
        this.code = `SELECT%20*%20FROM%20(${this.queryEditor})%20AS%20data_limited_results%20LIMIT%20100%20OFFSET%200`
        this.queryEditor = this.code
      }
      this.url = `${this.endPoint}?sql=${this.queryEditor}`

      axios
        .get(this.url)
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
