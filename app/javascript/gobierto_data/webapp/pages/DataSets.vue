<template>
  <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
    <NavDatasets
      v-if="arrayQueries"
      :active-tab="activeTabIndex"
      :array-queries="arrayQueries"
      @active-tab="activeTabIndex = $event"
    />
  </div>
</template>
<script>
import axios from 'axios';
import NavDatasets from "./../components/sets/Nav.vue";

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
      numberId: '',
      datasetId: 0
    }
  },
  created() {
    this.getData()
    this.$root.$on('reloadQueries', this.getQueries)
    this.numberId = this.$route.params.numberId
  },
  methods: {
    getQueries() {
      this.urlPath = location.origin
      this.endPoint = '/api/v1/data/queries?=filter[dataset_id]='
      this.url = `${this.urlPath}${this.endPoint}${this.numberId}`
      axios
        .get(this.url)
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
      this.urlPath = location.origin
      this.endPoint = '/api/v1/data/datasets/'
      this.url = `${this.urlPath}${this.endPoint}`
      axios
        .get(this.url)
        .then(response => {
          this.rawData = response.data
          this.numberId = this.rawData.data[0].id
          this.titleDataset = this.rawData.data[0].attributes.name
          this.getQueries()

        })
        .catch(error => {
          console.error(error)

        })
    }
  }
}

</script>
