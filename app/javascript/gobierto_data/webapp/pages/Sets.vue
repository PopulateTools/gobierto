<template>
  <div class="gobierto-data">
    <div class="pure-g gutters m_b_1">
      <div class="pure-u-1 pure-u-lg-4-4">
        <Nav
          :active-tab="activeTabIndex"
          @active-tab="activeTabIndex = $event"
        />
      </div>
      <Sidebar
        :active-tab="activeTabSidebar"
        @active-tab="activeTabSidebar = $event"
      >
        <template v-slot:sidebar>
          <slot name="sidebar" />
        </template>
      </Sidebar>
      <DataSets
        :active-tab="activeTabIndex"
        :array-queries="arrayQueries"
        :array-formats="arrayFormats"
        :public-queries="publicQueries"
        :table-name="tableName"
        :dataset-id="datasetId"
        :title-dataset="titleDataset"
      />
    </div>
  </div>
</template>
<script>
import axios from 'axios'
import { getUserId } from "./../../lib/helpers"
import { baseUrl } from "./../../lib/commons"
import DataSets from "./DataSets.vue";
import Sidebar from "./../components/Sidebar.vue";
import Nav from "./../components/Nav.vue";

export default {
  name: "Sets",
  components: {
    Sidebar,
    Nav,
    DataSets
  },
  props: {
    activeTab: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      activeTabIndex: 0,
      activeTabSidebar: 1,
      titleDataset: '',
      arrayQueries: [],
      publicQueries: [],
      datasetId: 0,
      tableName: '',
      arrayFormats: {}
    }
  },
  beforeRouteEnter (to, from, next) {
    const id = to.params.id
    next(vm => vm.getData(id))
  },
  created() {
    this.userId = getUserId()
    this.$root.$on('reloadQueries', this.getQueries)
    this.getData(this.$route.params.id)
  },
  methods: {
    getQueries() {
      const endPoint = `${baseUrl}/queries?filter[dataset_id]=${this.datasetId}&filter[user_id]=${this.userId}`
      axios
        .get(endPoint)
        .then(response => {
          const rawData = response.data
          const items = rawData.data
          this.arrayQueries = items
        })
        .catch(error => {
          const messageError = error.response
          console.error(messageError)
        })
    },
    getData(id) {
      const url = `${baseUrl}/datasets/${id}/meta`
      axios
        .get(url)
        .then(response => {
          const rawData = response.data
          this.titleDataset = rawData.data.attributes.name
          this.datasetId = parseInt(rawData.data.id)
          this.slugDataset = rawData.data.attributes.slug
          this.tableName = rawData.data.attributes.table_name
          this.arrayFormats = rawData.data.attributes.formats

          this.$root.$emit('nameDataset', this.titleDataset)

          this.getQueries()
          this.getPublicQueries()
        })
        .catch(error => {
          console.error(error)
        })
    },
    getColumns(slugDataset, index) {
      const url = `${baseUrl}/datasets/${slugDataset}`
      axios
        .get(url)
        .then(response => {
          const rawData = response.data
          const keysData = rawData.data
          this.columns = Object.keys(keysData[0])
          this.handleToggle(index)
        })
        .catch(error => {
          console.error(error)
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
   }
  }
}

</script>
