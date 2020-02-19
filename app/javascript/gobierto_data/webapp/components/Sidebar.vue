<template>
  <div class="pure-u-1 pure-u-lg-1-4 gobierto-data-layout-column gobierto-data-layout-sidebar">
    <nav class="gobierto-data-tabs-sidebar">
      <ul>
        <li
          :class="{ 'is-active': activeTab === 0 }"
          class="gobierto-data-tab-sidebar--tab"
          @click="activateTab(0)"
        >
          <span>{{ labelCategories }}</span>
        </li>
        <li
          :class="{ 'is-active': activeTab === 1 }"
          class="gobierto-data-tab-sidebar--tab"
          @click="activateTab(1)"
        >
          <span>{{ labelSets }}</span>
        </li>

        <li
          :class="{ 'is-active': activeTab === 2 }"
          class="gobierto-data-tab-sidebar--tab"
          @click="activateTab(2)"
          @change-view="updateComponent"
        >
          <span>{{ labelQueries }}</span>
        </li>
      </ul>
    </nav>
    <SidebarCategories
      v-if="activeTab === 0"
      :filters="filters"
    />
    <SidebarDatasets
      v-if="activeTab === 1"
      :filters="filters"
    />
    <SidebarQueries
      v-if="activeTab === 2"
    />
  </div>
</template>
<script>
import SidebarCategories from './SidebarCategories.vue';
import SidebarDatasets from './SidebarDatasets.vue';
import SidebarQueries from './SidebarQueries.vue';
export default {
  name: "Sidebar",
  components: {
    SidebarCategories,
    SidebarDatasets,
    SidebarQueries
  },
  props: {
    activeTab: {
      type: Number,
      default: 0
    },
    filters: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      labelSets: "",
      labelQueries: "",
      labelCategories: "",
      titleDataset: '',
      slugDataset: '',
      tableName: '',
      allDatasets: null,
    }
  },
  created() {
    this.labelSets = I18n.t("gobierto_data.projects.sets")
    this.labelQueries = I18n.t("gobierto_data.projects.queries")
    this.labelCategories = I18n.t("gobierto_data.projects.categories")

    this.endPoint = `${baseUrl}/datasets`

    this.$root.$on('toggleId', this.toggleIndex)

    axios
      .get(this.endPoint)
      .then(response => {
        this.rawData = response.data

        this.allDatasets = this.rawData.data
        this.allDatasets.sort((a, b) => a.attributes.name.localeCompare(b.attributes.name));

        this.titleDataset = this.rawData.data[0].attributes.name
        this.slugDataset = this.rawData.data[0].attributes.slug
        this.getColumns(this.slugDataset)
      })
      .catch(error => {
        console.error(error)
      })
  },
  methods: {
    initData(){
      const endPoint = `${baseUrl}/datasets`
      axios
        .get(endPoint)
        .then(response => {
          const rawData = response.data

          const sortDatasets = rawData.data
          this.allDatasets = sortDatasets.sort((a, b) => a.attributes.name.localeCompare(b.attributes.name));

          let slug = this.$route.params.id

          this.indexToggle = this.allDatasets.findIndex(dataset => dataset.attributes.slug == slug)
          this.toggle = this.indexToggle
          if (this.toggle < 0) {
            this.toggle = 0
            slug = this.allDatasets[0].attributes.slug
          }
          let firstElement = this.allDatasets.find(dataset => dataset.attributes.slug == slug)
          let filteredArray = this.allDatasets.filter(dataset => dataset.attributes.slug !== slug)
          filteredArray.unshift(firstElement)
          this.allDatasets = filteredArray
          this.toggle = 0
        })
        .catch(error => {
          console.error(error)
        })
    },
    handleToggle(index) {
      this.toggle = this.toggle !== index ? index : null;
    },
    activateTab(index) {
      this.$emit("active-tab", index);
    },
    nav(slugDataset, nameDataset) {
      this.toggle = 0
      this.$router.push({
        name: "dataset",
        params: {
          id: slugDataset,
          title: nameDataset
        }
    }, () => {})
    },
    getData(index) {
      this.endPoint = `${baseUrl}/datasets/`
      axios
        .get(this.endPoint)
        .then(response => {
          this.rawData = response.data
          this.rawData = this.rawData.data
          this.rawData = this.rawData.sort((a, b) => a.attributes.name.localeCompare(b.attributes.name));
          this.numberId = this.rawData[index].id
          this.titleDataset = this.rawData[index].attributes.name
          this.idDataset = this.rawData[index].id
          this.titleDataset = this.rawData[index].attributes.name
          this.slugDataset = this.rawData[index].attributes.slug
          this.tableName = this.rawData[index].attributes.table_name

          this.$root.$emit('nameDataset', this.titleDataset)
          this.$root.$emit('sendTableName', this.tableName)
          this.$root.$emit('sendSlug', this.slugDataset)
          this.nav(this.slugDataset)

        })
        .catch(error => {
          console.error(error)
        })
    },
    getMeta() {
      this.urlPath = location.origin
      this.endPoint = `/api/v1/data/datasets/${this.slugDataset}/meta`
      this.url = `${this.urlPath}${this.endPoint}`
      axios
        .get(this.url)
        .then(response => {
          this.rawData = response.data
          this.numberRows = this.rawData.data.attributes.data_summary.number_of_rows
          this.arrayFormats = this.rawData.data.attributes.formats
          this.columns = this.rawData.data.attributes.columns
          this.columns = Object.keys(this.columns)
          this.nav(this.slugDataset)
        })
        .catch(error => {
          console.error(error)
        })
    },
    getQueries() {
      this.endPoint = `${baseUrl}/queries?filter[dataset_id]=${this.numberId}&filter[user_id]=${this.userId}`
      axios
        .get(this.endPoint)
        .then(response => {
          this.rawData = response.data
          this.titleDataset = this.rawData.data.attributes.name
          this.idDataset = this.rawData.data.id
          this.slugDataset = this.rawData.data.attributes.slug
          this.tableName = this.rawData.data.attributes.table_name
          this.datasetId = parseInt(this.idDataset)
          this.getQueries()
        })
        .catch(error => {
          console.error(error)
        })
    }
  }
}
</script>
