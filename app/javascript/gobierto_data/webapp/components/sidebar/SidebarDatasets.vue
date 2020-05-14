<template>
  <div v-if="listDatasets.length">
    <div
      v-for="({ attributes: { slug, name }}) in listDatasets"
      :key="slug"
      class="gobierto-data-sidebar-datasets"
    >
      <div class="gobierto-data-sidebar-datasets-links-container">
        <i
          :class="{'rotate-caret': currentDatasetSlug !== slug }"
          class="fas fa-caret-down gobierto-data-sidebar-icon"
          @click="handleToggle(slug)"
        />

        <router-link
          :to="`/datos/${slug}`"
          class="gobierto-data-sidebar-datasets-name"
          @click.native="selectCurrentDataset(slug)"
        >
          {{ name }}
        </router-link>

        <div
          v-if="currentDatasetSlug === slug"
          class="gobierto-data-sidebar-datasets-container-columns"
        >
          <template v-for="(type, column) in activeDatasetVisibleColumns">
            <div
              :key="`${column}-${type}`"
              class="gobierto-data-sidebar-datasets-links-columns"
            >
              <i
                :key="`${column}-${type}`"
                :class="`fas gobierto-data-columns-icon gobierto-data-columns-icon-${type}`"
                style="color: var(--color-base);"
              />
              <span
                :key="`${column}-${type}`"
                class="gobierto-data-sidebar-datasets-links-columns-text"
              >
                {{ column }}
              </span>
            </div>
          </template>
          <div v-if="showToggle">
            <span
              v-if="showLess"
              class="gobierto-data-sidebar-datasets-links-columns-see-more"
              @click="showLess = false"
            >
              {{ labelshowAll }}
            </span>
            <span
              v-else
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
      sortedItems: [],
      listDatasets: [],
      currentDatasetSlug: null,
      showMaxKeys: 10,
      showLess: null,
      activeDatasetColumns: {},
      showToggle: null,
      labelSets: I18n.t("gobierto_data.projects.sets"),
      labelQueries: I18n.t("gobierto_data.projects.queries"),
      labelCategories: I18n.t("gobierto_data.projects.categories"),
      labelshowAll: I18n.t("gobierto_data.projects.showAll"),
      labelshowLess: I18n.t("gobierto_data.projects.showLess")
    }
  },
  computed: {
    activeDatasetVisibleColumns() {
      if (this.showLess && Object.keys(this.activeDatasetColumns).length) {
       return Object.keys(this.activeDatasetColumns).slice(0, this.showMaxKeys).reduce((result, key) => {
          result[key] = this.activeDatasetColumns[key];
          return result;
        }, {});
      } else {
        return this.activeDatasetColumns;
      }
    }
  },
  watch: {
    currentDatasetSlug (newSlug) {
      this.showLess = true;
      if (this.sortedItems.length && newSlug) {
        this.activeDatasetColumns = this.sortedItems.find(({ attributes: { slug } = {} }) => slug === newSlug).attributes.columns || {}
        this.showToggle = Object.keys(this.activeDatasetColumns).length > this.showMaxKeys
      }
    }
  },
  created() {
    // TODO Datasets should be order in filter mixin
    this.sortedItems = this.items.sort(({ attributes: { name: a } = {} }, { attributes: { name: b } = {} }) => a.localeCompare(b));

    let { id } = this.$route.params
    this.selectCurrentDataset(id)
  },
  methods: {
    selectCurrentDataset(selectedDatasetSlug) {
      if (!selectedDatasetSlug && this.sortedItems.length) {
        selectedDatasetSlug = this.sortedItems[0].attributes.slug
      }
      if (selectedDatasetSlug) {
        const selectedDataset = this.sortedItems.find(({ attributes: { slug } = {} }) => slug === selectedDatasetSlug)
        const filteredArray = this.sortedItems.filter(({ attributes: { slug } = {} }) => slug !== selectedDatasetSlug)
        this.listDatasets = [selectedDataset].concat(filteredArray)
        this.currentDatasetSlug = selectedDatasetSlug
      }
    },
    handleToggle(slug) {
      if (slug !== this.currentDatasetSlug) {
        this.currentDatasetSlug = slug
      } else {
        this.currentDatasetSlug = ''
      }
    }
  }
};
</script>
