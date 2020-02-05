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
      v-if="activeTab === 1 || activeTab === 4 && allDatasets"
    >
      <div
        v-for="(item, index) in allDatasets"
        :key="index"
        class="gobierto-data-sidebar-datasets"
      >
        <div class="gobierto-data-sidebar-datasets-links-container">
          <i
            :class="{'rotate-caret': toggle !== index }"
            class="fas fa-caret-down gobierto-data-sidebar-icon"
            @click="getColumns(item.attributes.slug, index)"
          />
          <a
            :href="item.attributes.slug"
            class="gobierto-data-sidebar-datasets-name"
            @click.prevent="getData(index)"
          >{{ item.attributes.name }}
          </a>
          <div
            v-show="toggle === index"
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
import axios from 'axios'
import { baseUrl } from "./../../lib/commons"
import { getUserId } from "./../../lib/helpers"
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
      allDatasets: [],
      numberId: '',
      columns: '',
      toggle: null,
      indexToggle: null
    }
  },
  created() {
    this.userId = getUserId()
    this.labelSets = I18n.t("gobierto_data.projects.sets")
    this.labelQueries = I18n.t("gobierto_data.projects.queries")
    this.labelCategories = I18n.t("gobierto_data.projects.categories")
    this.initData()
  },
  methods: {
    initData(){
      this.endPoint = `${baseUrl}/datasets`
      axios
        .get(this.endPoint)
        .then(response => {
          this.rawData = response.data

          this.sortDatasets = this.rawData.data
          this.allDatasets = this.sortDatasets.sort((a, b) => a.attributes.name.localeCompare(b.attributes.name));

          let slug = this.$route.params.id

          this.indexToggle = this.allDatasets.findIndex(dataset => dataset.attributes.slug == slug)
          this.toggle = this.indexToggle
          this.slugDataset = this.$route.params.id
          this.titleDataset = this.rawData.data[0].attributes.name
          this.firstColumns(this.slugDataset)
        })
        .catch(error => {
          console.error(error)
        })
    },
    firstColumns(slugDataset) {
      this.urlPath = location.origin
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
    getColumns(slugDataset, index) {
      this.handleToggle(index)
      this.caretActive = !this.caretActive;
      this.urlPath = location.origin
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
    handleToggle(index) {
      this.toggle = this.toggle !== index ? index : null;
    },
    activateTab(index) {
      this.$emit("active-tab", index);
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

          this.nav(this.slugDataset, index)
        })
        .catch(error => {
          console.error(error)

        })
    }
  }
};
</script>
