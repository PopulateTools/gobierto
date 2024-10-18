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
        <HomeNav
          :active-tab="activeTabIndex"
          @active-tab="setActiveTab"
        />
      </div>
    </div>

    <div class="pure-g gutters m_b_4">
      <div class="pure-u-1 pure-u-lg-1-4">
        <aside class="investments-home-aside">
          <Filters
            v-if="items.length"
            :data="items"
            :fields="filters"
            :metadata="metadata"
            :stats="stats"
            :no-empty-options="true"
            @update="handleUpdate"
          />
        </aside>
      </div>
      <div class="pure-u-1 pure-u-lg-3-4">
        <HomeMain
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

      <HomeArticle :phases="phases" />
    </article>
  </div>
</template>

<script>
import HomeMain from './Main.vue';
import HomeNav from './Nav.vue';
import HomeArticle from './Article.vue';

import { Loading, Filters } from '../../../../lib/vue/components';
import { CommonsMixin, baseUrl } from '../../mixins/common.js';
import { store } from '../../mixins/store';

// TODO: This configuration should come from API request, not from file
import CONFIGURATION from '../../conf/mataro.conf.js';

export default {
  name: "HomeHome",
  components: {
    HomeMain,
    HomeNav,
    HomeArticle,
    Loading,
    Filters
  },
  mixins: [CommonsMixin],
  data() {
    return {
      items: store.state.items || [],
      subsetItems: [],
      // filters: store.state.filters || [],
      phases: store.state.phases || [],
      metadata: [],
      stats: {},
      activeTabIndex: store.state.currentTab || 0,
      labelSummary: I18n.t("gobierto_investments.projects.summary") || "",
      labelReset: I18n.t("gobierto_investments.projects.reset") || "",
      labelLoading: I18n.t("gobierto_investments.projects.loading") || "",
      // activeFilters: store.state.activeFilters || new Map(),
      // defaultFilters: store.state.defaultFilters || new Map(),
      isFetchingData: false,
      isFiltering: false
    };
  },
  async created() {
    this.isFetchingData = true;

    const { items, phases, filters, stats, metadata } = await this.getItems();

    this.isFetchingData = false;

    this.items = items;
    this.phases = phases;
    this.stats = stats;
    this.metadata = metadata;
    this.filters = filters;
  },
  methods: {
    setActiveTab(value) {
      this.activeTabIndex = value;
      store.addCurrentTab(value);
    },
    async getItems() {
      const [
        { data: __items__ = [] },
        {
          data: metadata = [],
          meta: stats
        }
      ] = await Promise.all([
        fetch(baseUrl).then(r => r.json()),
        fetch(`${baseUrl}/meta?stats=true`).then(r => r.json()),
      ]);

      const { availableFilters: filters } = CONFIGURATION

      let items = this.setData(__items__, metadata);
      let phases = [];

      if (stats) {
        // get the phases
        const __phases__ = this.getPhases(stats, metadata);
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
      }

      // this.subsetItems = items;

      // save the items
      // store.addItems(items);

      return {
        phases,
        filters,
        items,
        stats,
        metadata
      };
    },
    handleUpdate(items) {
      this.subsetItems = items;
    },
    // filterItems(filter, key) {
    //   this.activeFilters.set(key, filter);
    //   this.updateDOM();
    //   // save the selected filters
    //   store.addActiveFilters(this.activeFilters);
    // },
    // updateDOM() {
    //   this.subsetItems = this.applyFiltersCallbacks(this.activeFilters);
    //   this.filters.forEach(filter => this.calculateOptionCounters(filter));
    //   this.isFiltering =
    //     [...this.activeFilters.values()].filter(Boolean).length > 0;
    // },
    // applyFiltersCallbacks(activeFilters) {
    //   let results = this.items;
    //   activeFilters.forEach(activeFn => {
    //     if (activeFn) {
    //       results = results.filter(d => activeFn(d.attributes));
    //     }
    //   });

    //   return results;
    // },
    // cleanFilters() {
    //   this.filters.splice(
    //     0,
    //     this.filters.length,
    //     ...this.clone(this.defaultFilters)
    //   );
    //   this.activeFilters.clear();
    //   this.updateDOM();
    // },
    // handleIsEverythingChecked({ filter }) {
    //   filter.isEverythingChecked = !filter.isEverythingChecked;
    //   filter.options.map(d => (d.isOptionChecked = filter.isEverythingChecked));
    //   this.handleCheckboxFilter(filter);
    // },
    // handleCheckboxStatus({ id, value, filter }) {
    //   const index = filter.options.findIndex(d => d.id === id);
    //   filter.options[index].isOptionChecked = value;
    //   this.handleCheckboxFilter(filter);
    // },
    // handleCheckboxFilter(filter) {
    //   const { key, options } = filter;
    //   const checkboxesSelected = new Map();
    //   options.forEach(({ id, isOptionChecked }) =>
    //     checkboxesSelected.set(id, isOptionChecked)
    //   );

    //   const size = [...checkboxesSelected.values()].filter(Boolean).length;
    //   // Update the property when all isEverythingChecked
    //   if (size === options.length) {
    //     filter.isEverythingChecked = true;
    //   }

    //   // Update the property when none isEverythingChecked
    //   if (size === 0) {
    //     filter.isEverythingChecked = false;
    //   }

    //   const index = this.filters.findIndex(d => d.key === key);
    //   this.filters.splice(index, 1, filter); // To detect array mutations

    //   const checkboxFilterFn = attrs =>
    //     attrs[key] && this.convertToArrayOfIds(attrs[key]).find(d => checkboxesSelected.get(+d));

    //   const callback = size ? checkboxFilterFn : undefined;
    //   this.filterItems(callback, key);
    // },
    // handleRangeFilter({ min, max, filter }) {
    //   const { key, min: __min__, max: __max__ } = filter;
    //   const rangeFilterFn = attrs => attrs[key] >= min && attrs[key] <= max;

    //   filter.savedMin = min;
    //   filter.savedMax = max;

    //   const index = this.filters.findIndex(d => d.key === key);
    //   this.filters.splice(index, 1, filter); // To detect array mutations

    //   const callback =
    //     Math.floor(min) <= Math.floor(+__min__) &&
    //     Math.floor(max) >= Math.floor(+__max__)
    //       ? undefined
    //       : rangeFilterFn;
    //   this.filterItems(callback, key);
    // },
    // handleCalendarFilter({ start, end, filter }) {
    //   const { key, startKey, endKey } = filter;
    //   const calendarFilterFn = attrs => {
    //     if (start && end && attrs[startKey] && attrs[endKey]) {
    //       return !(
    //         end < new Date(attrs[startKey]) || start > new Date(attrs[endKey])
    //       );
    //     } else if (start && !end && attrs[endKey]) {
    //       return !(start > new Date(attrs[endKey]));
    //     } else if (!start && end && attrs[startKey]) {
    //       return !(end < new Date(attrs[startKey]));
    //     } else {
    //       return false;
    //     }
    //   };

    //   // Update object
    //   filter.savedStartDate = start;
    //   filter.savedEndDate = end;

    //   const index = this.filters.findIndex(d => d.key === key);
    //   this.filters.splice(index, 1, filter); // To detect array mutations

    //   const callback = !start && !end ? undefined : calendarFilterFn;
    //   this.filterItems(callback, key);
    // },
    // clone(data) {
    //   return JSON.parse(JSON.stringify(data));
    // },
    // calculateOptionCounters(filter) {
    //   const counter = ({ key, id }) => {
    //     // Clone current filters
    //     const __activeFilters__ = new Map(this.activeFilters);
    //     // Ignore same key callbacks (as if none of the same category are selected)
    //     __activeFilters__.set(key, undefined);
    //     // Get the items based on these new active filters
    //     const __items__ = this.applyFiltersCallbacks(__activeFilters__);

    //     return __items__.filter(({ attributes }) =>
    //       this.convertToArrayOfIds(attributes[key]).includes(id)
    //     ).length;
    //   };
    //   const { key, options = [] } = filter;
    //   if (options.length) {
    //     filter.options = options.map(o => ({
    //       ...o,
    //       counter: counter({ id: o.id, key })
    //     }));
    //     const index = this.filters.findIndex(d => d.key === key);
    //     this.filters.splice(index, 1, filter);
    //   }
    // }
  }
};
</script>
