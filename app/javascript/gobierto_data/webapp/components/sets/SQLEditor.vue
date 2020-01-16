<template>
  <div>
    <div class="gobierto-data-sql-editor">
      <SQLEditorHeader />
      <SQLEditorCode />
      <SQLEditorTable
        v-if="data"
        :items="data"
      />
    </div>
  </div>
</template>
<script>
import axios from 'axios';
import SQLEditorCode from "./SQLEditorCode.vue";
import SQLEditorHeader from "./SQLEditorHeader.vue";
import SQLEditorTable from "./SQLEditorTable.vue";

export default {
  name: 'SQLEditor',
  components: {
    SQLEditorCode,
    SQLEditorHeader,
    SQLEditorTable
  },
  data() {
    return {
      rawData: [],
      columns: [],
      data: null,
      keysData: [],
      meta:[],
      links:[],
      queryDurationRecors: [],
      queryEditor: '',
      url: '',
      urlPath: '',
      apiPath: '',
      fakeData: [
  {
    "id": 55982,
    "site_id": 19,
    "admin_id": null,
    "name": "person 8b9963d312ff7eaf4936",
    "bio_url": null,
    "visibility_level": 1,
    "created_at": "2019-10-10 03:06:54.12632",
    "updated_at": "2019-10-10 09:33:53.601263",
    "avatar_url": null,
    "statements_count": 0,
    "posts_count": 0,
    "political_group_id": null,
    "category": 0,
    "party": null,
    "position": 999999,
    "email": "person-8b9963d312ff7eaf4936@gobierto.tools",
    "charge_translations": "{\"ca\": \"Secretari general\"}",
    "bio_translations": null,
    "slug": "person-8b9963d312ff7eaf4936",
    "google_calendar_token": null,
    "bio_source_translations": null
  },
  {
    "id": 1837,
    "site_id": 21,
    "admin_id": null,
    "name": "person d87b61222c5cd4a76730",
    "bio_url": null,
    "visibility_level": 1,
    "created_at": "2018-11-07 11:56:53.532838",
    "updated_at": "2019-10-10 09:33:53.613038",
    "avatar_url": null,
    "statements_count": 0,
    "posts_count": 0,
    "political_group_id": null,
    "category": 0,
    "party": null,
    "position": 999999,
    "email": "person-d87b61222c5cd4a76730@gobierto.tools",
    "charge_translations": "{\"ca\": \"Secretari general\"}",
    "bio_translations": null,
    "slug": "person-d87b61222c5cd4a76730",
    "google_calendar_token": null,
    "bio_source_translations": null
  }
]
    }
  },
  mounted() {
    this.getData()
    this.$root.$on('updateCodeQuery', this.newQuery)
    console.log(this.fakeData)

  },
  methods: {
    getData() {
      this.rawData = []
      this.urlPath = 'http://mataro.gobierto.test:9280/';
      this.apiPath = 'api/v1/data/datasets/people';
      this.url = `${this.urlPath}${this.apiPath}?sql=${this.queryEditor}`
      console.log("this.url", this.url);
      axios
        .get(this.url)
        .then(response => {
          this.rawData = response.data
          this.meta = this.rawData.meta
          this.links = this.rawData.links
          this.data = this.rawData.data
          console.log("this.data", this.data);
          this.keysData = Object.keys(this.data[0])

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
      this.data = this.fakeData
      this.keysData = Object.keys(this.data[0])
      /*this.getData()*/
    }
  }
}
</script>
