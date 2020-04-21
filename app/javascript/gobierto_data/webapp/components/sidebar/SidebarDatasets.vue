<template>
  <div v-if="listDatasets.length">
    <div
      v-for="({ id, attributes: { slug, name }}, index) in listDatasets"
      :key="slug"
      class="gobierto-data-sidebar-datasets"
    >
      <div class="gobierto-data-sidebar-datasets-links-container">
        <i
          :class="{'rotate-caret': currentDatasetIndex !== index }"
          class="fas fa-caret-down gobierto-data-sidebar-icon"
          @click="handleToggle(index)"
        />

        <router-link
          :to="`/datos/${slug}`"
         class="gobierto-data-sidebar-datasets-name"
         @click.native="selectCurrentDataset"
        >
          {{ name }}
        </router-link>

        <div
          v-show="currentDatasetIndex === index"
          class="gobierto-data-sidebar-datasets-container-columns"
        >
          <template v-for="(type, column) in activeDatasetVisibleColumns">
            <span
              :key="`${column}-${type}`"
              class="gobierto-data-sidebar-datasets-links-columns"
            >
              {{ column }}: {{type | translateType}}
            </span>
          </template>
          <div v-if="showToggle">
            <span v-if="showLess"
              class="gobierto-data-sidebar-datasets-links-columns-see-more"
              @click="showLess = false"
            >
              {{ labelshowAll }}
            </span>
            <span v-else
              class="gobierto-data-sidebar-datasets-links-columns-see-more"
              @click="showLess = true"
            >
              {{ labelshowLess }}
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
<script>
export default {
  name: "SidebarDatasets",
  props: {
    items: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      labelSets: "",
      labelQueries: "",
      labelCategories: "",
      labelshowAll: "",
      labelshowLess: "",
      sortedItems: [],
      listDatasets: [],
      currentDatasetIndex: null,
      showMaxKeys: 10,
      showLess: null,
      activeDatasetColumns: {},
      showToggle: null,
    }
  },
  created() {
    this.labelSets = I18n.t("gobierto_data.projects.sets")
    this.labelQueries = I18n.t("gobierto_data.projects.queries")
    this.labelCategories = I18n.t("gobierto_data.projects.categories")
    this.labelshowAll = I18n.t("gobierto_data.projects.showAll")
    this.labelshowLess = I18n.t("gobierto_data.projects.showLess")
    //TODO Datasets should be order in filter mixin
    this.sortedItems = this.items.sort(({ attributes: { name: a } = {} }, { attributes: { name: b } = {} }) => a.localeCompare(b));
    this.selectCurrentDataset()
  },
  watch: {
    currentDatasetIndex: function(value) {
      this.showLess = true;
      if(this.listDatasets.length) {
        this.activeDatasetColumns = this.listDatasets[value].attributes.columns || {}
        this.showToggle = Object.keys(this.activeDatasetColumns).length > this.showMaxKeys
      }
    }
  },
  computed: {
    activeDatasetVisibleColumns() {
      if(this.showLess && Object.keys(this.activeDatasetColumns).length) {
       return Object.keys(this.activeDatasetColumns).slice(0, this.showMaxKeys).reduce((result, key) => {
          result[key] = this.activeDatasetColumns[key];
          return result;
        }, {});
      } else {
        return this.activeDatasetColumns;
      }
    }
  },
  methods: {
    selectCurrentDataset() {
      // Get slug from route params, we need this when user click in any dataset
      let { id } = this.$route.params
      let selectedDatasetIndex = 0
      if(id !== undefined) {
        selectedDatasetIndex = this.sortedItems.findIndex(({ attributes: { slug } = {} }) => slug === id)
      }

      let selectedDataset = this.sortedItems[selectedDatasetIndex]
      let filteredArray = this.sortedItems.filter(({ attributes: { slug } = {} }) => slug !== selectedDataset.attributes.slug)
      this.listDatasets = [selectedDataset].concat(filteredArray)
      this.currentDatasetIndex = 0
    },
    handleToggle(index) {
      this.currentDatasetIndex = index;
    }
  },
  filters: {
    translateType: function(type) {
      return I18n.t(`gobierto_data.data_type.${type}`)
    }
  }
};
</script>
