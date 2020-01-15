<template>
  <div>
    <table>
      <thead>
        <tr>
          <th
            v-for="(column, index) in keysData"
            :key="index"
            :item="column"
          >
            {{ column }}
          </th>
        </tr>
      </thead>
      <tbody>
        <tr
          v-for="(row, idx) of data"
          :key="idx"
        >
          <td
            v-for="(column, idx1) of keysData"
            :key="idx1"
          >
            {{ row[column] }}
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script>
import axios from 'axios';
export default {
  name: 'SQLEditorTable',
  data() {
    return {
      rawData: [],
      columns: [],
      data: [],
      keysData: [],
      meta:[],
      links:[],
      queryDurationRecors: [],
      queryEditor: '',
      url: '',
      urlPath: '',
      apiPath: ''
    }
  },
  created() {
    this.labelSave = I18n.t('gobierto_data.projects.save');
  },
  mounted() {
    this.getData()
    this.$root.$on('updateCodeQuery', this.newQuery)
  },
  methods: {
    getData() {
      this.rawData = []
      this.urlPath = 'http://mataro.gobierto.test:9280/';
      this.apiPath = 'api/v1/data/datasets/people';
      this.url = `${this.urlPath}${this.apiPath}?sql=${this.queryEditor}`
      axios
        .get(this.url)
        .then(response => {
          this.rawData = response.data;
          this.meta = this.rawData.meta
          this.links = this.rawData.links
          this.data = this.rawData.data;
          this.keysData = Object.keys(this.data[0]);

          this.queryDurationRecors = [this.meta.rows, this.meta.duration]

          this.$root.$emit('recordsDuration', this.queryDurationRecors);
        })
        .catch(e => {
          console.error(e);
        });
    },
    newQuery(value) {
      this.queryEditor = value
      this.queryEditor = encodeURIComponent(this.queryEditor.trim())
      this.getData()
    }
  }
}
</script>
