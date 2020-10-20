import axios from "axios"
import { Middleware } from "lib/shared";
import { store } from "../store"
import { baseUrl } from "../commons"
import CONFIGURATION from "../filters.conf"

export const FiltersMixin = {
  data() {
    return {
      items: store.state.items || [],
      subsetItems: [],
      filters: store.state.filters || [],
      activeFilters: store.state.activeFilters || new Map(),
      defaultFilters: store.state.defaultFilters || new Map(),
    }
  },
  async created() {
    if (this.items.length) {
      this.updateDOM();
    } else {
      const { items, filters } = await this.getItems();

      this.items = items;
      this.defaultFilters = filters;
      this.filters = filters;

      this.updateDOM();
    }
  },
  methods: {
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

      const { availableFilters } = CONFIGURATION;
      // Middleware receives both the dictionary of all possible attributes, and the selected filters for the site
      this.middleware = new Middleware({
        dictionary: attributesDictionary,
        filters: availableFilters
      });
      store.addDatasets(__items__);
      let items = __items__;
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
      const { key, options } = filter;
      const checkboxesSelected = new Map();
      options.forEach(({ id, isOptionChecked }) =>
        checkboxesSelected.set(id, isOptionChecked)
      );

      const size = [...checkboxesSelected.values()].filter(Boolean).length;
      //Filter by those that have at least one element
      const optionsActive = options.filter(({ counter: element = 0 }) => element > 0 );
      // Update the property when all isEverythingChecked
      if (size === optionsActive.length) {
        filter.isEverythingChecked = true;
      }

      // Update the property when none isEverythingChecked
      if (size === 0) {
        filter.isEverythingChecked = false;
      }

      const index = this.filters.findIndex(d => d.key === key);
      this.filters.splice(index, 1, filter); // To detect array mutations

      const checkboxFilterFn = attrs =>
        attrs[key] && this.convertToArrayOfIds(attrs[key]).find(d => checkboxesSelected.get(+d));

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
          this.convertToArrayOfIds(attributes[key]).includes(id)
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
    convertToArrayOfIds(items) {
      return Array.isArray(items) ? items.map(item => (+item)) : [+items]
    }
  }
}
