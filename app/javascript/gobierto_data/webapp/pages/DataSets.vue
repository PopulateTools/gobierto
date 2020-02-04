<template>
  <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
    <NavDatasets
      :active-tab="activeTabIndex"
      :array-queries="arrayQueries"
      :array-formats="arrayFormats"
      :table-name="tableName"
      :dataset-id="datasetId"
      :title-dataset="titleDataset"
      @active-tab="activeTabIndex = $event"
    />
  </div>
</template>
<script>
import axios from 'axios'
import { baseUrl } from "./../../lib/commons"
import { getUserId } from "./../../lib/helpers"
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
      datasetId: 0,
      tableName: '',
      arrayFormats:{}
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
          this.arrayQueries = this.items
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

          this.$root.$emit('nameDataset', this.titleDataset)

          this.getQueries()
        })
        .catch(error => {
          console.error(error)
        })
    }
  }
}

</script>
