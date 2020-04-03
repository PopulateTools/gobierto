<template>
  <div>
    <div
      v-for="(item, index) in listDatasets"
      :key="index"
      class="gobierto-data-sidebar-datasets"
    >
      <div class="gobierto-data-sidebar-datasets-links-container">
        <i
          :class="{'rotate-caret': toggle !== index }"
          class="fas fa-caret-down gobierto-data-sidebar-icon"
          @click="handleToggle(index)"
        />
        <a
          :href="'/datos/' + item.attributes.slug"
          class="gobierto-data-sidebar-datasets-name"
          @click.prevent="nav(item.attributes.slug, item.attributes.name, index)"
        >{{ item.attributes.name }}
        </a>
        <div
          v-show="toggle === index"
          class="gobierto-data-sidebar-datasets-container-columns"
        >
          <div v-if="showLess">
            <template v-for="(column, i) in lessColumns">
              <span
                :key="i"
                class="gobierto-data-sidebar-datasets-links-columns"
              >
                {{ column }}
              </span>
            </template>
          </div>
          <div v-else>
            <span
              v-for="(column, i) in item.attributes.columns"
              :key="i"
              class="gobierto-data-sidebar-datasets-links-columns"
            >
              {{ i }}
            </span>
          </div>
          <div v-if="showKeys()">
            <template
              v-if="showLess"
            >
              <span
                class="gobierto-data-sidebar-datasets-links-columns-see-more"
                @click="showLess = false"
              >
                {{ labelshowAll }}
              </span>
            </template>
            <template v-else>
              <span
                class="gobierto-data-sidebar-datasets-links-columns-see-more"
                @click="showLess = true"
              >
                {{ labelshowLess }}
              </span>
            </template>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import { store } from "./../../../lib/store";
export default {
  name: "SidebarDatasets",
  data() {
    return {
      labelSets: "",
      labelQueries: "",
      labelCategories: "",
      labelshowAll: "",
      labelshowLess: "",
      listDatasets: [],
      toggle: 0,
      indexToggle: null,
      showMaxKeys: 10,
      showLess: true,
      lessColumns: [],
      items: store.state.datasets || []
    }
  },
  created() {
    this.labelSets = I18n.t("gobierto_data.projects.sets")
    this.labelQueries = I18n.t("gobierto_data.projects.queries")
    this.labelCategories = I18n.t("gobierto_data.projects.categories")
    this.labelshowAll = I18n.t("gobierto_data.projects.showAll")
    this.labelshowLess = I18n.t("gobierto_data.projects.showLess")
    this.orderDatasets()
  },
  methods: {
    orderDatasets() {
      const sortDatasets = this.items
      const allDatasets = sortDatasets.sort((a, b) => a.attributes.name.localeCompare(b.attributes.name));
      let slug = this.$route.params.id
      const indexToggle = allDatasets.findIndex(dataset => dataset.attributes.slug == slug)
      this.toggle = indexToggle
      if (this.toggle === -1) {
        this.toggle = 0
        slug = slug = allDatasets.length ? allDatasets[0].attributes.slug : ''
      }
      let firstElement = allDatasets.find(dataset => dataset.attributes.slug == slug)
      let filteredArray = allDatasets.filter(dataset => dataset.attributes.slug !== slug)
      filteredArray.unshift(firstElement)
      this.listDatasets = filteredArray
      this.toggle = 0
      this.sliceColumns(0)
    },
    handleToggle(index) {
      this.showLess = true
      this.sliceColumns(index)
      this.toggle = this.toggle !== index ? index : null;
    },
    nav(slugDataset, nameDataset) {
      this.toggle = 0
      this.$router.push({
        name: "dataset",
        params: {
          id: slugDataset,
          tabSidebar: 1,
          title: nameDataset
        }
    // eslint-disable-next-line no-unused-vars
    }).catch(err => {})
    },
    sliceColumns(index) {
      const allColumns = this.listDatasets ? Object.keys(this.listDatasets[index].attributes.columns) : []
      this.lessColumns = allColumns.slice(0, this.showMaxKeys)
    },
    showKeys() {
      return Object.keys(this.listDatasets[0].attributes.columns).length > this.showMaxKeys
    }
  }
};
</script>
