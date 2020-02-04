<template>
  <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
    <NavDatasets
      :active-tab="activeTabIndex"
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
      datasetId: 0
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
          this.datasetId = parseInt(this.numberId)
        })
        .catch(error => {
          const messageError = error.response
          console.error(messageError)
        })
    },
    getData() {
      this.endPoint = `${baseUrl}/datasets/`
      axios
        .get(this.endPoint)
        .then(response => {
          this.rawData = response.data
          this.titleDataset = this.rawData.data[0].attributes.name
          this.datasetId = this.rawData.data[0].id
          this.getQueries()
        })
        .catch(error => {
          console.error(error)
        })
    }
  }
}

</script>
