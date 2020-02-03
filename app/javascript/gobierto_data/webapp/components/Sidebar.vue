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
          :class="{ 'is-active': activeTab === 1 || activeTab === 4 }"
          class="gobierto-data-tab-sidebar--tab"
          @click="activateTab(1)"
        >
          <span>{{ labelSets }}</span>
        </li>

        <li
          :class="{ 'is-active': activeTab === 2 }"
          class="gobierto-data-tab-sidebar--tab"
          @click="activateTab(2)"
        >
          <span>{{ labelQueries }}</span>
        </li>
      </ul>
    </nav>
    <div
      v-if="activeTab === 1"
    >
      <div
        v-for="(item, index) in allDatasets"
        :key="index"
        class="gobierto-data-sidebar-datasets"
      >
        <div
          class="gobierto-data-sidebar-datasets-links-container"
        >
          <i
            class="fas fa-caret-down"
          />
          <span
            class="gobierto-data-sidebar-datasets-name"
            @click.stop="getData(index)"
          >{{ item.attributes.name }}
          </span>
          <div
            v-show="isActive === index"
          >
            <span
              v-for="(column, i) in columns"
              :key="i"
              :item="i"
              class="gobierto-data-sidebar-datasets-links-columns"
            >
              {{ column }}
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>


<script>
import axios from 'axios';

export default {
  name: "Sidebar",
  props: {
    activeTab: {
      type: Number,
      default: 0
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
      numberId: '',
      columns: [],
      isActive: 0,
      allDatasets: []
    }
  },
  watch:{
    columns: function(){
        console.log("this.columns", this.columns);
        this.columns = this.columns
        console.log("this.columns", this.columns);
    }
  },
  created() {
    this.labelSets = I18n.t("gobierto_data.projects.sets")
    this.labelQueries = I18n.t("gobierto_data.projects.queries")
    this.labelCategories = I18n.t("gobierto_data.projects.categories")

    this.urlPath = location.origin
    this.endPoint = '/api/v1/data/datasets';
    this.url = `${this.urlPath}${this.endPoint}`

    axios
      .get(this.url)
      .then(response => {
        this.rawData = response.data
        this.allDatasets = this.rawData.data
        console.log("this.allDatasets", this.allDatasets);
        this.titleDataset = this.rawData.data[0].attributes.name
        this.firstSlug = this.rawData.data[0].attributes.slug
        this.firstColumns(this.firstSlug)
      })
      .catch(error => {
        console.error(error)
      })


  },
  methods: {
    firstColumns(slugDataset) {
      console.log("slugDataset", slugDataset);
      this.endPoint = `/api/v1/data/datasets/${slugDataset}`
      this.url = `${this.urlPath}${this.endPoint}`
      axios
        .get(this.url)
        .then(response => {
          this.rawData = response.data
          this.keysData = this.rawData.data

          this.columns = Object.keys(this.keysData[0])
        })
        .catch(error => {
          console.error(error)

        })
    },
    getColumns(slugDataset) {
      console.log("slugDataset", slugDataset);
      console.log('peticion')
      this.urlPath = location.origin
      this.endPoint = `/api/v1/data/datasets/${slugDataset}`
      this.url = `${this.urlPath}${this.endPoint}`
      axios
        .get(this.url)
        .then(response => {
          this.rawData = response.data
          this.keysData = this.rawData.data

          this.columns = []
          this.columns = Object.keys(this.keysData[0])
          console.log("this.columns", this.columns);
          this.nav(slugDataset)
        })
        .catch(error => {
          console.error(error)

        })
    },
    activateTab(value) {
      this.$emit("active-tab", value);
    },
    nav(slugDataset) {
      this.$router.push({
        name: "dataset",
        params: {
          id: slugDataset
        }
    })
    },
    getData(index) {
      this.isActive = index
      console.log("this.isActive", this.isActive);
      this.urlPath = location.origin
      this.endPoint = '/api/v1/data/datasets/'
      this.url = `${this.urlPath}${this.endPoint}`
      axios
        .get(this.url)
        .then(response => {
          this.rawData = response.data
          this.numberId = this.rawData.data[index].id
          this.titleDataset = this.rawData.data[index].attributes.name

          this.idDataset = this.rawData.data[index].id

          this.titleDataset = this.rawData.data[index].attributes.name
          this.slugDataset = this.rawData.data[index].attributes.slug
          this.tableName = this.rawData.data[index].attributes.table_name

          this.getColumns(this.slugDataset)
        })
        .catch(error => {
          console.error(error)

        })
    }
  }
};
</script>
