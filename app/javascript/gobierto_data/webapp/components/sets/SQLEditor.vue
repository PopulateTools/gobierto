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
      columns: [],
      data: null,
      keysData: [],
      meta:[],
      links:[],
      link: '',
      queryDurationRecors: [],
      queryEditor: 'SELECT%20*%20FROM%20mataro_budgets%20LIMIT%2050%20OFFSET%200',
      url: '',
      urlPath: '',
      endPoint: '',
      recentQueries: [],
      newRecentQuery: null,
      trimQuery: false,
      nameDataset: ''
    }
  },
  mounted() {
    this.getData()
    this.$root.$on('updateCodeQuery', this.newQuery)
    this.$root.$on('runRencentQuery', this.runRecentQuery)
    if (localStorage.getItem('recentQueries')) {
      try {
        this.recentQueries = JSON.parse(localStorage.getItem('recentQueries'));
      } catch (e) {
        localStorage.removeItem('recentQueries');
      }
    }
  },
  methods: {
    runRecentQuery(value) {
      this.trimQuery = true
      let newQueryRecentAgain = this.recentQueries[value]
      let oneLine = newQueryRecentAgain.replace(/\n/g, ' ');
      newQueryRecentAgain = oneLine.replace(/  +/g, ' ');
      this.newQuery(newQueryRecentAgain)
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
    getData() {
      this.urlPath = location.origin
      this.endPoint = '/api/v1/data/data';
      this.url = `${this.urlPath}${this.endPoint}?sql=${this.queryEditor}`

      this.fileCSV = `${this.urlPath}${this.endPoint}.csv?sql=${this.queryEditor}&csv_separator=semicolon`
      this.fileJSON = `${this.urlPath}${this.endPoint}.json?sql=${this.queryEditor}`
      this.arrayFiles = [this.fileCSV, this.fileJSON]
      this.$root.$emit('sendFiles', this.arrayFiles)

      axios
        .get(this.url)
        .then(response => {
          this.rawData = response.data
          this.meta = this.rawData.meta
          this.links = this.rawData.links
          this.data = this.rawData.data

          this.queryDurationRecors = [this.meta.rows, this.meta.duration]

          this.$root.$emit('recordsDuration', this.queryDurationRecors)

        })
        .catch(e => {
          console.error(e);
        })
    },
    newQuery(value) {
      this.queryEditor = value
      if (this.trimQuery === false) {
        this.queryEditor = encodeURIComponent(this.queryEditor.trim())
      }
      this.newRecentQuery = this.queryEditor
      this.keysData = Object.keys(this.data[0])
      this.getData()
      this.addRecentQuery()
      this.trimQuery = false
    }
  }
}
</script>
