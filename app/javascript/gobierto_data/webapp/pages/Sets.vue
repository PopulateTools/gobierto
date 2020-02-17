<template>
  <div class="gobierto-data">
    <div class="pure-g gutters m_b_1">
      <div class="pure-u-1 pure-u-lg-4-4">
        <Nav
          :active-tab="activeTabTopIndex"
          @active-tab="activeTabTopIndex = $event"
        />
      </div>
      <keep-alive>
        <Sidebar
          :active-tab="activeTabSidebar"
          @active-tab="activeTabSidebar = $event"
        />
      </keep-alive>
      <div class="pure-u-1 pure-u-lg-3-4 gobierto-data-layout-column">
        <NavDatasets
          v-if="dataLoaded"
          :active-tab="activeTabIndex"
          :array-queries="arrayQueries"
          :public-queries="publicQueries"
          :array-formats="arrayFormats"
          :table-name="tableName"
          :dataset-id="datasetId"
          :title-dataset="titleDataset"
          @active-tab="activeTabIndex = $event"
        />
      </div>
    </div>
  </div>
</template>
<script>
import axios from 'axios'
import { getUserId } from "./../../lib/helpers"
import { baseUrl } from "./../../lib/commons"
import NavDatasets from "./../components/sets/Nav.vue";
import Sidebar from "./../components/Sidebar.vue";
import Nav from "./../components/Nav.vue";

export default {
  name: "Sets",
  components: {
    Sidebar,
    Nav,
    NavDatasets
  },
  props: {
    activeTab: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      activeTabSidebar: 1,
      activeTabTopIndex: 0,
      rawData: '',
      titleDataset: '',
      arrayQueries: null,
      publicQueries: [],
      datasetId: 0,
      tableName: '',
      arrayFormats: {},
      activeTabIndex: 0,
      dataLoaded: false
    }
  },
  beforeRouteEnter (to, from, next) {
    next((vm) => {
      if (to.name === 'resumen') {
        vm.activeTabIndex = 0
      } else if (to.name === 'editor') {
        vm.activeTabIndex = 1
      } else if (to.name === 'consultas') {
        vm.activeTabIndex = 2
      } else if (to.name === 'visualizaciones') {
        vm.activeTabIndex = 3
      } else if (to.name === 'descarga') {
        vm.activeTabIndex = 4
      } else if (to.name === 'queries') {
        vm.activeTabIndex = 1
      }
    })
  },
  beforeRouteUpdate (to, from, next) {
    if (to.name === 'resumen') {
      this.activeTabIndex = 0
    } else if (to.name === 'editor') {
      this.activeTabIndex = 1
    } else if (to.name === 'consultas') {
      this.activeTabIndex = 2
    } else if (to.name === 'visualizaciones') {
      this.activeTabIndex = 3
    } else if (to.name === 'descarga') {
      this.activeTabIndex = 4
    } else if (to.name === 'queries') {
      this.activeTabIndex = 1
    }
    next()
  },
  created() {
    this.userId = getUserId()
    this.$root.$on('reloadQueries', this.getQueries)
    this.getData(this.$route.params.id)
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
         this.dataLoaded = true
       })
       .catch(error => {
         const messageError = error.response
         console.error(messageError)
       })
   }
  }
}

</script>
