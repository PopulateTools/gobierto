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
import { getUserId } from "./../../lib/helpers";

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

    this.userId = getUserId()
  },
  methods: {
    getQueries() {
      this.urlPath = location.origin
      this.endPoint = '/api/v1/data/queries?filter[dataset_id]='
      this.filterId = `&filter[user_id]=${this.userId}`
      this.url = `${this.urlPath}${this.endPoint}${this.numberId}${this.filterId}`
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
      this.endPoint = `/api/v1/data/datasets/${this.$route.params.id}/meta`
      this.url = `${this.urlPath}${this.endPoint}`
      axios
        .get(this.url)
        .then(response => {
          this.rawData = response.data
          this.titleDataset = this.rawData.data.attributes.name
          this.idDataset = this.rawData.data.id
          this.titleDataset = this.rawData.data.attributes.name
          this.slugDataset = this.rawData.data.attributes.slug
          this.tableName = this.rawData.data.attributes.table_name
          this.datasetId = parseInt(this.idDataset)

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
