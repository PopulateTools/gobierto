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
      queryEditor: 'SELECT%20*%20FROM%20gp_people',
      url: '',
      urlPath: '',
      endPoint: ''
    }
  },
  mounted() {
    this.getData()
    this.$root.$on('updateCodeQuery', this.newQuery)
  },
  methods: {
    getData() {
      this.urlPath = location.origin
      this.endPoint = '/api/v1/data/data';
      this.url = `${this.urlPath}${this.endPoint}?sql=${this.queryEditor}`
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
        });
    },
    newQuery(value) {
      this.queryEditor = value
      this.queryEditor = encodeURIComponent(this.queryEditor.trim())
      this.keysData = Object.keys(this.data[0])
      this.getData()
    }
  }
}
</script>
