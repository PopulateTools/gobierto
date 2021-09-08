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
  props: {
    noEmptyOptions: {
      type: Boolean,
      default: false
    }
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
        this.updateItems()
      }
    },
    filterItems(filterFn, key) {
      this.isDirty = true
      this.activeFilters.set(key, filterFn);
    },
    updateItems() {
      this.subsetItems = this.applyFiltersCallbacks(this.activeFilters);
      this.filters = this.filters.map(this.calculateOptionCounters);
    },
    initializeFilters() {
      this.isDirty = false
      this.activeFilters.clear()
      this.filters = this.filters.map(filter => {
        const __filter = this.calculateOptionCounters(filter)

        if (this.noEmptyOptions) {
          __filter.options = __filter.options.filter(({ counter }) => counter > 0)
        }

        return __filter
      });
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
    clearFilters() {
      this.filters = []
      this.filters = JSON.parse(JSON.stringify(this.defaultFilters.slice(0)))

      this.initializeFilters()
      this.updateItems();

      const query = { ...this.$route?.query, ...this.filters.reduce((acc, { key }) => ({ ...acc, [key]: undefined }), {}) }
      // "replace" to not trigger the vue-router hooks
      this.$router?.push({ ...this.$route, query })
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
      this.updateItems();

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
    handleRangeFilterStatus({ min, max, filter }) {
      // this function mutates filter, therefore updateURL receives the mutated filter obj
      this.handleRangeFilter({ min, max, filter })
      this.updateItems();

      // url updates must be done only in functions triggered by the user
      this.updateURL(filter)
    },
    handleRangeFilter({ min, max, filter }) {
      const { key, min: __min__, max: __max__ } = filter;
      const rangeFilterFn = attrs => attrs[key] >= min && attrs[key] <= max;

      filter.savedMin = min;
      filter.savedMax = max;

      const index = this.filters.findIndex(d => d.key === key);
      this.filters.splice(index, 1, filter); // To detect array mutations

      const callback =
        Math.floor(min) <= Math.floor(+__min__) &&
        Math.floor(max) >= Math.floor(+__max__)
          ? undefined
          : rangeFilterFn;
      this.filterItems(callback, key);
    },
    handleCalendarFilterStatus({ start, end, filter }) {
      // this function mutates filter, therefore updateURL receives the mutated filter obj
      this.handleCalendarFilter({ start, end, filter })
      this.updateItems();

      // url updates must be done only in functions triggered by the user
      this.updateURL(filter)
    },
    handleCalendarFilter({ start, end, filter }) {
      const { key, startKey = key, endKey = startKey } = filter;
      const calendarFilterFn = attrs => {
        if (start && end && attrs[startKey] && attrs[endKey]) {
          return !(
            end < new Date(attrs[startKey]) || start > new Date(attrs[endKey])
          );
        } else if (start && !end && attrs[endKey]) {
          return !(start > new Date(attrs[endKey]));
        } else if (!start && end && attrs[startKey]) {
          return !(end < new Date(attrs[startKey]));
        } else {
          return false;
        }
      };

      // Update object
      filter.savedStartDate = start;
      filter.savedEndDate = end;

      const index = this.filters.findIndex(d => d.key === key);
      this.filters.splice(index, 1, filter); // To detect array mutations

      const callback = !start && !end ? undefined : calendarFilterFn;
      this.filterItems(callback, key);
    },
    counter({ key, id }) {
      // Clone current filters
      const __activeFilters__ = new Map(this.activeFilters);
      // Ignore same key callbacks (as if none of the same category are selected)
      __activeFilters__.set(key, undefined);
      // Get the items based on these new active filters
      const __items__ = this.applyFiltersCallbacks(__activeFilters__);

      return __items__.filter(({ attributes }) =>
        this.convertToArrayOfIds(attributes[key]).includes(id)
      ).length;
    },
    calculateOptionCounters(filter) {
      const { key, options = [] } = filter;

      if (options.length) {
        filter.options = options.map(o => ({
          ...o,
          counter: this.counter({ id: o.id, key })
        }));
      }

      return filter
    },
    convertToArrayOfIds(items) {
      return Array.isArray(items) ? items.map(item => (+item)) : [+items]
    },
    updateURL(filter = {}) {
      const param = this.$route?.query[filter.key]?.split(",") || []

      if (filter.type === "vocabulary_options") {
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
      }

      if (filter.type === "numeric") {
        param[0] = filter.savedMin
        param[1] = filter.savedMax
      }

      if (filter.type === "date") {
        // set only the date part
        param[0] = filter.savedStartDate?.toISOString().substr(0, 10)
        param[1] = filter.savedEndDate?.toISOString().substr(0, 10)
      }

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
        } else if (filter && filter.type === "numeric") {
          const [min, max] = values.split(",")
          this.handleRangeFilter({ min: +min, max: +max, filter })
        } else if (filter && filter.type === "date") {
          const [start, end] = values.split(",")
          this.handleCalendarFilter({ start: new Date(start), end: end ? new Date(end) : undefined, filter })
        }
      })
    }
  }
}
