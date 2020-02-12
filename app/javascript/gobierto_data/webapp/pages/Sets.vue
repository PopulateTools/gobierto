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
        :number-rows="numberRows"
        :table-name="tableName"
        :dataset-id="datasetId"
        :title-dataset="titleDataset"
      />
    </div>
  </div>
</template>
<script>
import axios from 'axios'
import { getUserId, getToken } from "./../../lib/helpers"
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
      rawData: '',
      titleDataset: '',
      arrayQueries: [],
      publicQueries: [],
      datasetId: 0,
      numberRows: 0,
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
    this.token = getToken()
    this.$root.$on('reloadQueries', this.getQueries)
    this.getData(this.$route.params.id)
  },
  methods: {
    getQueries() {
      this.endPoint = `${baseUrl}/queries?filter[dataset_id]=${this.datasetId}&filter[user_id]=${this.userId}`
      axios
        .get(this.endPoint, {
          headers: {
            'Content-type': 'application/json',
            'Authorization': `${this.token}`
          }
        })
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
    getData(id) {
      this.url = `${baseUrl}/datasets/${id}/meta`
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
    },
    getColumns(slugDataset, index) {
      this.url = `${baseUrl}/datasets/${slugDataset}`
      axios
        .get(this.url)
        .then(response => {
          this.rawData = response.data
          this.keysData = this.rawData.data
          this.columns = Object.keys(this.keysData[0])
          this.handleToggle(index)
        })
        .catch(error => {
          console.error(error)
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
   }
  }
}

</script>
