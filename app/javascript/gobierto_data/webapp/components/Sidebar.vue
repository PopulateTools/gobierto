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
            class="fas fa-caret-down gobierto-data-sidebar-icon"
            :class="{'rotate-caret': toggle !== index }"
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
      allDatasets: null,
      numberId: '',
      columns: '',
      toggle: 0
    }
  },
  created() {
    this.userId = getUserId()
    this.labelSets = I18n.t("gobierto_data.projects.sets")
    this.labelQueries = I18n.t("gobierto_data.projects.queries")
    this.labelCategories = I18n.t("gobierto_data.projects.categories")

    this.endPoint = `${baseUrl}/datasets`

    axios
      .get(this.endPoint)
      .then(response => {
        this.rawData = response.data

        this.allDatasets = this.rawData.data
        this.allDatasets.sort((a, b) => a.attributes.name.localeCompare(b.attributes.name));

        this.titleDataset = this.rawData.data[0].attributes.name
        this.slugDataset = this.rawData.data[0].attributes.slug
        this.firstColumns(this.slugDataset)
      })
      .catch(error => {
        console.error(error)
      })
  },
  methods: {
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
      this.toggle = this.toggle !== index ? index : null;
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
    activateTab(index) {
      this.$emit("active-tab", index);
    },
    nav(slugDataset) {
      this.$router.push({
        name: "dataset",
        params: {
          id: slugDataset,
          numberId: this.numberId,
          titleDataset: this.titleDataset,
          tableName: this.tableName,
          arrayQueries: this.arrayQueries
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

          this.$root.$emit('nameDataset', this.titleDataset)
          this.$root.$emit('sendTableName', this.tableName)
          this.$root.$emit('sendSlug', this.slugDataset)
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
          this.items = this.rawData.data
          this.arrayQueries = this.items
          this.datasetId = parseInt(this.numberId)
          this.nav(this.slugDataset)
        })
        .catch(error => {
          const messageError = error.response
          console.error(messageError)
        })
    },
  }
};
</script>
