<template>
  <div
    v-if="isFetchingData"
    class="gobierto-data"
  >
    <LayoutTabs
      :filters="filters"
      :all-datasets="subsetItems"
      :current-view="currentView"
      :current-tab="currentTab"
      :active-dataset-tab="activeDatasetTab"
    />
  </div>
</template>

<script>
import LayoutTabs from "./../layouts/LayoutTabs.vue";
import { Middleware } from "lib/shared";
import { categoriesMixin, baseUrl } from "./../../lib/commons"
import { store } from "./../../lib/store";
import CONFIGURATION from "./../../lib/gobierto-data.conf.js";
import axios from "axios";

export default {
  name: "Home",
  components: {
    LayoutTabs
  },
  mixins: [categoriesMixin],
  props: {
    currentComponent: {
      type: String,
      required: true,
      default: ''
    },
    activateTabSidebar: {
      type: Number,
      default: 0
    }
  },
  beforeRouteEnter (to, from, next) {
    next((vm) => {
      if (to.name === 'resumen') {
        vm.activeDatasetTab = 0
      } else if (to.name === 'editor') {
        vm.activeDatasetTab = 1
      } else if (to.name === 'consultas') {
        vm.activeDatasetTab = 2
      } else if (to.name === 'visualizaciones') {
        vm.activeDatasetTab = 3
      } else if (to.name === 'descarga') {
        vm.activeDatasetTab = 4
      }
    })
  },
  beforeRouteUpdate (to, from, next) {
    if (to.name === 'resumen') {
      this.activeDatasetTab = 0
    } else if (to.name === 'editor') {
      this.activeDatasetTab = 1
    } else if (to.name === 'consultas') {
      this.activeDatasetTab = 2
    } else if (to.name === 'visualizaciones') {
      this.activeDatasetTab = 3
    } else if (to.name === 'descarga') {
      this.activeDatasetTab = 4
    }
    next()
  },
  data() {
    return {
      items: store.state.items || [],
      subsetItems: [],
      currentView: '',
      currentTab: 0,
      filters: store.state.filters || [],
      activeFilters: store.state.activeFilters || new Map(),
      defaultFilters: store.state.defaultFilters || new Map(),
      isFetchingData: false
    }
  },
  async created() {
    this.currentView = this.currentComponent
    if (this.$route.params.tabSidebar === 0) {
      this.currentTab = this.$route.params.tabSidebar
    } else {
      this.currentTab = this.activateTabSidebar
    }
    this.$root.$on("sendCheckbox", this.handleCheckboxStatus)
    this.$root.$on("selectAll", this.handleIsEverythingChecked)
    if (this.items.length) {
      this.updateDOM();
    } else {

      const { items, filters } = await this.getItems();

      this.isFetchingData = true;

      this.items = items;

      this.defaultFilters = filters
      this.filters = filters;

      this.updateDOM();
    }
    this.isFetchingData = true;
  },
  methods: {
    setCurrentView() {
      this.currentView = 'DataSets'
    },
    async getItems() {
      const [
        {
          data: { data: __items__ = [] }
        },
        {
          data: {
            data: attributesDictionary = [],
            meta: filtersFromConfiguration
          }
        }
      ] = await axios.all([
        axios.get(`${baseUrl}/datasets`),
        axios.get(`${baseUrl}/datasets/meta?stats=true`)
      ]);

      const { availableFilters } = CONFIGURATION
      // Middleware receives both the dictionary of all possible attributes, and the selected filters for the site
      this.middleware = new Middleware({
        dictionary: attributesDictionary,
        filters: availableFilters
      });
      store.addDatasets(__items__);
      let items = this.setData(__items__);
      let filters = [];

      if (filtersFromConfiguration) {

        items = items.map(item => ({ ...item }));

        filters = this.middleware.getFilters(filtersFromConfiguration) || [];

        if (filters.length) {
          this.activeFilters = new Map();

          // initialize active filters
          filters.forEach(filter =>
            this.activeFilters.set(filter.key, undefined)
          );

          // save the filters
          store.addFilters(filters);
          store.addDefaultFilters(filters);
        }
      }

      // Assign this object BEFORE next function for better performance
      this.subsetItems = items;

      return {
        filters,
        items
      };
    },
    filterItems(filter, key) {
      this.activeFilters.set(key, filter);
      this.updateDOM();
      // save the selected filters
      store.addActiveFilters(this.activeFilters);
    },
    updateDOM() {
      this.subsetItems = this.applyFiltersCallbacks(this.activeFilters);
      this.filters.forEach(filter => this.calculateOptionCounters(filter));
      this.isFiltering =
        [...this.activeFilters.values()].filter(Boolean).length > 0;
    },
    applyFiltersCallbacks(activeFilters) {
      let results = this.items;
      activeFilters.forEach(activeFn => {
        if (activeFn) {
          results = results.filter(d => activeFn(d.attributes));
        }
      });

      return results;
    },
    cleanFilters() {
      this.filters.splice(
        0,
        this.filters.length,
        ...this.clone(this.defaultFilters)
      );
      this.activeFilters.clear();
      this.updateDOM();
    },
    handleIsEverythingChecked({ filter }) {
      filter.isEverythingChecked = !filter.isEverythingChecked;
      filter.options.map(d => (d.isOptionChecked = filter.isEverythingChecked));
      this.handleCheckboxFilter(filter);
    },
    handleCheckboxStatus({ id, value, filter }) {
      const index = filter.options.findIndex(d => d.id === id);
      filter.options[index].isOptionChecked = value;
      this.handleCheckboxFilter(filter);
    },
    handleCheckboxFilter(filter) {
      this.updateHome()
      const { key, options } = filter;
      const checkboxesSelected = new Map();
      options.forEach(({ id, isOptionChecked }) =>
        checkboxesSelected.set(id, isOptionChecked)
      );

      const size = [...checkboxesSelected.values()].filter(Boolean).length;
      // Update the property when all isEverythingChecked
      if (size === options.length) {
        filter.isEverythingChecked = true;
      }

      // Update the property when none isEverythingChecked
      if (size === 0) {
        filter.isEverythingChecked = false;
      }

      const index = this.filters.findIndex(d => d.key === key);
      this.filters.splice(index, 1, filter); // To detect array mutations

      const checkboxFilterFn = attrs =>
        attrs[key].find(d => checkboxesSelected.get(+d.id));

      const callback = size ? checkboxFilterFn : undefined;
      this.filterItems(callback, key);
    },
    calculateOptionCounters(filter) {
      const counter = ({ key, id }) => {
        // Clone current filters
        const __activeFilters__ = new Map(this.activeFilters);
        // Ignore same key callbacks (as if none of the same category are selected)
        __activeFilters__.set(key, undefined);
        // Get the items based on these new active filters
        const __items__ = this.applyFiltersCallbacks(__activeFilters__);

        return __items__.filter(({ attributes }) =>
          attributes[key].map(g => g.id).includes(id)
        ).length;
      };
      const { key, options = [] } = filter;
      if (options.length) {
        filter.options = options.map(o => ({
          ...o,
          counter: counter({ id: o.id, key })
        }));
        const index = this.filters.findIndex(d => d.key === key);
        this.filters.splice(index, 1, filter);
      }
    },
    updateHome() {
      this.$router.push({
        name: "home",
        params: {
          tabSidebar: 0,
          currentComponent: 'InfoList'
        }
      // eslint-disable-next-line no-unused-vars
      }).catch(err => {})
    }
  }
}
</script>
