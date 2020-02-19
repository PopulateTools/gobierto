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
                :item="i"
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
              :item="i"
              class="gobierto-data-sidebar-datasets-links-columns"
            >
              {{ i }}
            </span>
          </div>
          <div v-if="Object.keys(item.attributes.columns).length > 10">
            <template
              v-if="showLess"
            >
              <span
                class="gobierto-data-sidebar-datasets-links-columns-see-more"
                @click="showLess = false"
              >
                {{ labelSeeMore }}
              </span>
            </template>
            <template v-else>
              <span
                class="gobierto-data-sidebar-datasets-links-columns-see-more"
                @click="showLess = true"
              >
                {{ labelSeeLess }}
              </span>
            </template>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
import { store } from "./../../lib/store";
export default {
  name: "SidebarDatasets",
  data() {
    return {
      labelSets: "",
      labelQueries: "",
      labelCategories: "",
      labelSeeMore: "",
      labelSeeLess: "",
      listDatasets: [],
      toggle: 0,
      indexToggle: null,
      showLess: true,
      lessColumns: [],
      items: store.state.datasets || []
    }
  },
  created() {
    this.labelSets = I18n.t("gobierto_data.projects.sets")
    this.labelQueries = I18n.t("gobierto_data.projects.queries")
    this.labelCategories = I18n.t("gobierto_data.projects.categories")
    this.labelSeeMore = I18n.t("gobierto_data.projects.seeMore")
    this.labelSeeLess = I18n.t("gobierto_data.projects.seeLess")
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
        slug = allDatasets[0].attributes.slug
      }
      let firstElement = allDatasets.find(dataset => dataset.attributes.slug == slug)
      let filteredArray = allDatasets.filter(dataset => dataset.attributes.slug !== slug)
      filteredArray.unshift(firstElement)
      this.listDatasets = filteredArray
      this.toggle = 0
      this.sliceColumns()
    },
    handleToggle(index) {
      this.showLess = true
      this.sliceColumns()
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
    }, () => {})
    },
    sliceColumns() {
      const allColumns = Object.keys(this.listDatasets[0].attributes.columns)
      this.lessColumns = allColumns.slice(0, 10)
    }
  }
};
</script>
