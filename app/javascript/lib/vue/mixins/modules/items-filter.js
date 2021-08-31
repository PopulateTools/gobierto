import { Middleware } from "lib/shared";

export const ItemsFilterMixin = {
  data() {
    return {
      items: [],
      subsetItems: [],
      filters: [],
      activeFilters: new Map(),
      defaultFilters: new Map(),
      isDirty: false
    }
  },
  watch: {
    items() {
      // when the array of items is informed (usually delayed due to XHR)
      // set both subset (equal to items at startup) and the counters
      this.updateItems()
    },
  },
  methods: {
    createFilters({ filters, dictionary, stats = {} }) {
      // Middleware receives both the dictionary of all possible attributes, and the selected filters for the site
      const middleware = new Middleware({ dictionary, filters });

      this.filters = middleware.getFilters(stats) || [];
      this.defaultFilters = JSON.parse(JSON.stringify(this.filters.slice(0)));

      if (filters.length) {
        this.activeFilters = new Map();
        this.initializeFilters()
        this.parseQueryParams(this.$route)
      }
    },
    filterItems(filterFn, key) {
      this.isDirty = true
      this.activeFilters.set(key, filterFn);
      this.updateItems();
    },
    updateItems() {
      this.subsetItems = this.applyFiltersCallbacks(this.activeFilters);
      this.filters.forEach(filter => this.calculateOptionCounters(filter));
    },
    initializeFilters() {
      this.isDirty = false
      this.filters.forEach(({ key }) => this.activeFilters.set(key, undefined));
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
      this.filters = []
      this.filters = JSON.parse(JSON.stringify(this.defaultFilters))

      this.initializeFilters()
      this.updateItems();
    },
    handleIsEverythingChecked({ filter }) {
      filter.isEverythingChecked = !filter.isEverythingChecked;
      filter.options.map(d => (d.isOptionChecked = filter.isEverythingChecked));
      this.handleCheckboxFilter(filter);

      // url updates must be done only in functions triggered by the user
      this.updateURL(filter)
    },
    handleCheckboxStatus({ id, value, filter }) {
      const index = filter.options.findIndex(d => d.id === id);
      filter.options[index].isOptionChecked = value;
      this.handleCheckboxFilter(filter);

      // url updates must be done only in functions triggered by the user
      this.updateURL(filter)
    },
    handleCheckboxFilter(filter) {
      const { key, options } = filter;
      const checkboxesSelected = new Map();
      options.forEach(({ id, isOptionChecked }) =>
        checkboxesSelected.set(id, isOptionChecked)
      );

      const size = [...checkboxesSelected.values()].filter(Boolean).length;
      // Filter by those that have at least one element
      const optionsActive = options.filter(({ counter = 0 }) => counter > 0 );
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
    },
    updateURL(filter = {}) {
      const param = this.$route?.query[filter.key]?.split(",") || []

      filter.options.forEach(({ slug, isOptionChecked }) => {
        if (isOptionChecked) {
          // when value is true, ignore param if exists, otherwise append it
          if (!param.includes(slug)) {
            param.push(slug)
          }
        } else if (param.includes(slug)) {
          // remove param if false
          param.splice(param.indexOf(slug), 1)
        }
      })

      const query = { ...this.$route?.query, [filter.key]: param.length ? param.join(",") : undefined }
      // "replace" to not trigger the vue-router hooks
      this.$router?.replace({ ...this.$route, query })
    },
    parseQueryParams({ query }) {
      Object.entries(query).forEach(([k, values]) => {
        const ix = this.filters.findIndex(({ key }) => k === key)
        const filter = this.filters[ix]

        if (filter && filter.type === "vocabulary_options") {
          values.split(",").forEach(x => {
            const idx = filter.options.findIndex(({ slug }) => x === slug)
            filter.options[idx].isOptionChecked = true
          })
          this.filters.splice(ix, 1, filter)
          this.handleCheckboxFilter(filter)
        }

        // TODO: faltaría completar los que no son checkboxes
      })
    }
  }
}
