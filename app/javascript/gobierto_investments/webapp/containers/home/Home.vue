<template>
  <Loading
    v-if="isFetchingData"
    :message="labelLoading"
    class="investments--loading"
  />
  <div
    v-else
    class="investments"
  >
    <div class="pure-g gutters m_b_1">
      <div class="pure-u-1 pure-u-lg-1-4">
        <div
          v-if="isFiltering"
          class="investments-home-nav--reset"
        >
          <transition
            name="fade"
            mode="out-in"
          >
            <a @click="cleanFilters">{{ labelReset }}</a>
          </transition>
        </div>
      </div>
      <div class="pure-u-1 pure-u-lg-3-4">
        <Nav
          :active-tab="activeTabIndex"
          @active-tab="setActiveTab"
        />
      </div>
    </div>

    <div class="pure-g gutters m_b_4">
      <div class="pure-u-1 pure-u-lg-1-4">
        <Aside
          v-slot="{ filter }"
          :filters="filters"
        >
          <!-- Filter type: calendar -->
          <template v-if="filter.type === 'daterange'">
            <Calendar
              class="investments-home-aside--calendar-button"
              :saved-start-date="filter.savedStartDate"
              :saved-end-date="filter.savedEndDate"
              @calendar-change="e => handleCalendarFilter({ ...e, filter })"
            />
          </template>

          <!-- Filter type: checkbox -->
          <template v-else-if="filter.type === 'vocabulary_options'">
            <BlockHeader
              :title="filter.title"
              :label-alt="filter.isEverythingChecked"
              class="investments-home-aside--block-header"
              see-link
              @select-all="e => handleIsEverythingChecked({ ...e, filter })"
            />
            <Checkbox
              v-for="option in filter.options"
              :id="option.id"
              :key="option.id"
              :title="option.title"
              :checked="option.isOptionChecked"
              :counter="option.counter"
              class="investments-home-aside--checkbox"
              @checkbox-change="e => handleCheckboxStatus({ ...e, filter })"
            />
          </template>

          <!-- Filter type: numeric range -->
          <template v-else-if="filter.type === 'numeric'">
            <BlockHeader
              :title="filter.title"
              class="investments-home-aside--block-header"
            />
            <RangeBars
              :histogram="
                (filter.histogram || []).map((item, i) => ({
                  ...item,
                  id: item.bucket || i
                }))
              "
              :min="Math.floor(+filter.min)"
              :max="Math.ceil(parseFloat(filter.max))"
              :saved-min="filter.savedMin"
              :saved-max="filter.savedMax"
              :total-items="parseFloat(filter.count)"
              @range-change="e => handleRangeFilter({ ...e, filter })"
            />
          </template>
        </Aside>
      </div>
      <div class="pure-u-1 pure-u-lg-3-4">
        <Main
          v-if="items.length"
          :active-tab="activeTabIndex"
          :items="subsetItems"
        />
      </div>
    </div>

    <article>
      <h3 class="investments-home-article--header">
        {{ labelSummary }}
      </h3>

      <Article :phases="phases" />
    </article>
  </div>
</template>

<script>
import Aside from './Aside.vue';
import Main from './Main.vue';
import Nav from './Nav.vue';
import Article from './Article.vue';
import axios from 'axios';

import { BlockHeader, Calendar, Loading, Checkbox, RangeBars } from '../../../../lib/vue/components';
import { Middleware } from '../../../../lib/shared';
import { CommonsMixin, baseUrl } from '../../mixins/common.js';
import { store } from '../../mixins/store';

// TODO: This configuration should come from API request, not from file
import CONFIGURATION from '../../conf/mataro.conf.js';

export default {
  name: "Home",
  components: {
    Aside,
    Main,
    Nav,
    Article,
    Loading,
    Calendar,
    BlockHeader,
    Checkbox,
    RangeBars
  },
  mixins: [CommonsMixin],
  data() {
    return {
      items: store.state.items || [],
      subsetItems: [],
      filters: store.state.filters || [],
      phases: store.state.phases || [],
      activeTabIndex: store.state.currentTab || 0,
      labelSummary: "",
      labelReset: "",
      labelLoading: "",
      activeFilters: store.state.activeFilters || new Map(),
      defaultFilters: store.state.defaultFilters || new Map(),
      isFetchingData: false,
      isFiltering: false
    };
  },
  async created() {
    this.labelSummary = I18n.t("gobierto_investments.projects.summary");
    this.labelReset = I18n.t("gobierto_investments.projects.reset");
    this.labelLoading = I18n.t("gobierto_investments.projects.loading");

    if (this.items.length) {
      this.updateDOM();
    } else {
      this.isFetchingData = true;

      const { items, phases, filters } = await this.getItems();

      this.isFetchingData = false;

      this.items = items;
      this.phases = phases;
      this.defaultFilters = this.clone(filters);
      this.filters = filters;

      this.updateDOM();
    }
  },
  methods: {
    setActiveTab(value) {
      this.activeTabIndex = value;
      store.addCurrentTab(value);
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
        axios.get(baseUrl),
        axios.get(`${baseUrl}/meta?stats=true`)
      ]);

      const { availableFilters } = CONFIGURATION
      // Middleware receives both the dictionary of all possible attributes, and the selected filters for the site
      this.middleware = new Middleware({
        dictionary: attributesDictionary,
        filters: availableFilters
      });

      let items = this.setData(__items__);
      let phases = [];
      let filters = [];

      if (filtersFromConfiguration) {
        // get the phases
        const __phases__ = this.getPhases(filtersFromConfiguration);
        // append what items are in that phase
        phases = __phases__.map(phase => ({
          ...phase,
          items: items.filter(d =>
            d.phases.length ? d.phases[0].id === phase.id : false
          )
        }));
        // save the phases
        store.addPhases(phases);

        // Add dictionary of phases in order to fulfill project page
        items = items.map(item => ({ ...item, phasesDictionary: __phases__ }));

        filters = this.middleware.getFilters(filtersFromConfiguration) || [];

        if (filters.length) {
          this.activeFilters = new Map();

          // initialize active filters
          filters.forEach(filter =>
            this.activeFilters.set(filter.key, undefined)
          );

          // save the filters
          store.addFilters(filters);
          store.addDefaultFilters(this.clone(filters));
        }
      }

      this.subsetItems = items;

      // save the items
      store.addItems(items);

      return {
        phases,
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
        attrs[key] && this.convertToArrayOfIds(attrs[key]).find(d => checkboxesSelected.get(+d));

      const callback = size ? checkboxFilterFn : undefined;
      this.filterItems(callback, key);
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
    handleCalendarFilter({ start, end, filter }) {
      const { key, startKey, endKey } = filter;
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
    clone(data) {
      return JSON.parse(JSON.stringify(data));
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
    }
  }
};
</script>
