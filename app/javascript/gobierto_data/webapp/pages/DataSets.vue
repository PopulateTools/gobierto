<template>
  <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
    <NavDatasets
      :active-tab="activeTabIndex"
      :array-queries="arrayQueries"
      :public-queries="publicQueries"
      :array-formats="arrayFormats"
      :number-rows="numberRows"
      :table-name="tableName"
      :dataset-id="datasetId"
      :title-dataset="titleDataset"
      @active-tab="activeTabIndex = $event"
    />
  </div>
</template>
<script>
import axios from 'axios'
import { getUserId } from "./../../lib/helpers"
import { baseUrl } from "./../../lib/commons"
import NavDatasets from "./../components/sets/Nav.vue"

export default {
  name: "DataSets",
  components: {
    NavDatasets
  },
  data() {
    return {
      activeTabIndex: 0,
      rawData: '',
      titleDataset: '',
      arrayQueries: [],
      numberRows: 0,
      datasetId: 0,
      tableName: '',
      arrayFormats:{},
      arrayColumns: [],
      keyColumns: []
    }
  },
  created() {
    this.getData()
    this.$root.$on('reloadQueries', this.getQueries)
    this.userId = getUserId()
  },
  methods: {
    getQueries() {
      this.endPoint = `${baseUrl}/queries?filter[dataset_id]=${this.datasetId}&filter[user_id]=${this.userId}`
      axios
        .get(this.endPoint)
        .then(response => {
          this.rawData = response.data
          this.items = this.rawData.data
          this.arrayQueries = this.items.sort((a, b) => parseFloat(a.id) - parseFloat(b.id));
        })
        .catch(error => {
          const messageError = error.response
          console.error(messageError)
        })
    },
    getPublicQueries() {
      this.endPoint = `${baseUrl}/queries?filter[dataset_id]=${this.datasetId}`
      axios
        .get(this.endPoint)
        .then(response => {
          this.rawData = response.data
          this.items = this.rawData.data
          this.publicQueries = this.items
        })
        .catch(error => {
          const messageError = error.response
          console.error(messageError)
        })
    },
    getData() {
      this.url = `${baseUrl}/datasets/${this.$route.params.id}/meta`
      axios
        .get(this.url)
        .then(response => {
          this.rawData = response.data
          this.titleDataset = this.rawData.data.attributes.name
          this.datasetId = parseInt(this.rawData.data.id)
          this.slugDataset = this.rawData.data.attributes.slug
          this.tableName = this.rawData.data.attributes.table_name
          this.arrayFormats = this.rawData.data.attributes.formats
          this.numberRows = this.rawData.data.attributes.data_summary.number_of_rows

          this.$root.$emit('nameDataset', this.titleDataset)

          this.getQueries()
          this.getPublicQueries()
        })
        .catch(error => {
          console.error(error)
        })
    }
  }
}
</script>
