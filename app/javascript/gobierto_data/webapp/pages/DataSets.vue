<template>
  <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
    <NavDatasets
      :active-tab="activeTabIndex"
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
      datasetId: 0
    }
  },
  created() {
    this.getData()
    this.$root.$on('reloadQueries', this.getQueries)
  },
  methods: {
    getData() {
      this.urlPath = location.origin
      this.endPoint = '/api/v1/data/datasets/'
      this.url = `${this.urlPath}${this.endPoint}`
      axios
        .get(this.url)
        .then(response => {
          this.rawData = response.data
          this.titleDataset = this.rawData.data[0].attributes.name

        })
        .catch(error => {
          console.error(error)

        })
    }
  }
}

</script>
