<template>
  <div>
    <div class="gobierto-data-sql-editor">
      <SQLEditorHeader />
      <SQLEditorCode />
      <SQLEditorTabs
        v-if="data"
        :items="data"
        :link="link"
        :active-tab="activeTabIndex"
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

export default {
  name: 'SQLEditor',
  components: {
    SQLEditorCode,
    SQLEditorHeader,
    SQLEditorTabs
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
      urlPath: location.origin,
      endPoint: '',
      recentQueries: [],
      newRecentQuery: null,
      nameDataset: '',
      tableName: ''
    }
  },
  created(){
    this.$root.$on('sendTable', this.tableName)
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
    this.getSlug()
  },
  methods: {
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
    getSlug() {
      this.endPointSlug = '/api/v1/data/datasets';
      this.urlSlug = `${this.urlPath}${this.endPointSlug}`
      axios
        .get(this.urlSlug)
        .then(response => {
          this.rawDataSlug = response.data
          this.tableName = this.rawDataSlug.data[0].attributes.table_name
          this.$root.$emit('sendTableName', this.tableName)
          this.queryEditor = `SELECT%20*%20FROM%20${this.tableName}%20LIMIT%2050`
          this.getData()

        })
        .catch(error => {
          console.error(error)
        })
    },
    getData() {
      this.endPoint = '/api/v1/data/data';
      this.url = `${this.urlPath}${this.endPoint}?sql=${this.queryEditor}`

      axios
        .get(this.url)
        .then(response => {
          this.rawData = response.data
          this.meta = this.rawData.meta
          this.data = this.rawData.data

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
