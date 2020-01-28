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
        :item="item"
        class="gobierto-data-sidebar-datasets-links"
      >
        <i class="fas fa-caret-down" />
        <span
          @click="getDataDataset(index)"
        >{{ item.attributes.name }}</span>
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
      allDatasets: null,
      numberId: ''
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

        this.titleDataset = this.rawData.data[0].attributes.name
      })
      .catch(error => {
        console.error(error)
      })

  },
  methods: {
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
          tableName: this.tableName
        }
    })
    },
    getDataDataset(index) {
      this.getData(index)
    },
    getData(index) {
      this.urlPath = location.origin
      this.endPoint = '/api/v1/data/datasets/'
      this.url = `${this.urlPath}${this.endPoint}`
      axios
        .get(this.url)
        .then(response => {
          this.rawData = response.data
          console.log("this.rawData", this.rawData);
          this.numberId = this.rawData.data[index].id
          this.titleDataset = this.rawData.data[index].attributes.name

          this.idDataset = this.rawData.data[index].id

          this.titleDataset = this.rawData.data[index].attributes.name
          this.slugDataset = this.rawData.data[index].attributes.slug
          this.tableName = this.rawData.data[index].attributes.table_name

          this.$root.$emit('nameDataset', this.titleDataset)
          this.$root.$emit('sendTableName', this.tableName)
          this.$root.$emit('sendSlug', this.slugDataset)
          this.$root.$emit('sendIdDataset', this.idDataset)
          this.nav(this.slugDataset)
          this.getMeta()

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
          console.log("this.rawData", this.rawData);z

        })
        .catch(error => {
          console.error(error)

        })
    }
  }
};
</script>
