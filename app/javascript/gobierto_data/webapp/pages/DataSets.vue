<template>
  <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
    <NavDatasets
      :items="items"
      @active-tab="activeTabIndex = $event"
    />
  </div>
</template>
<script>
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
      const endPoint = `${baseUrl}/queries?filter[dataset_id]=${this.datasetId}&filter[user_id]=${this.userId}`
      axios
        .get(endPoint)
        .then(response => {
          const rawData = response.data
          const items = rawData.data
          this.arrayQueries = items.sort((a, b) => parseFloat(a.id) - parseFloat(b.id));
        })
        .catch(error => {
          const messageError = error.response
          console.error(messageError)
        })
    },
    getPublicQueries() {
      const endPoint = `${baseUrl}/queries?filter[dataset_id]=${this.datasetId}`
      axios
        .get(endPoint)
        .then(response => {
          const rawData = response.data
          const items = rawData.data
          this.publicQueries = items
        })
        .catch(error => {
          const messageError = error.response
          console.error(messageError)
        })
    },
    getData() {
      const url = `${baseUrl}/datasets/${this.$route.params.id}/meta`
      axios
        .get(url)
        .then(response => {
          const rawData = response.data
          this.titleDataset = rawData.data.attributes.name
          this.datasetId = parseInt(rawData.data.id)
          this.slugDataset = rawData.data.attributes.slug
          this.tableName = rawData.data.attributes.table_name
          this.arrayFormats = rawData.data.attributes.formats
          this.numberRows = rawData.data.attributes.data_summary.number_of_rows

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
