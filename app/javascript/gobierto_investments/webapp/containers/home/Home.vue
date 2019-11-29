<template>
  <Loading v-if="isFetchingData" />
  <div
    v-else
    class="investments"
  >
    <div class="pure-g gutters m_b_1">
      <div class="pure-u-1 pure-u-lg-1-4">
        <div class="investments-home-nav--reset">
          <transition
            name="fade"
            mode="out-in"
          >
            <a
              v-if="isFiltering"
              @click="cleanFilters"
            >{{ labelReset }}</a>
          </transition>
        </div>
      </div>
      <div class="pure-u-1 pure-u-lg-3-4">
        <Nav
          :active-tab="activeTabIndex"
          @active-tab="activeTabIndex = $event"
        />
      </div>
    </div>

    <div class="pure-g gutters m_b_4">
      <div class="pure-u-1 pure-u-lg-1-4">
        <Aside
          v-slot="{ filter }"
          :filters="filters"
        >
          <!-- Filter type: date -->
          <template v-if="filter.type === 'range'">
            <Calendar
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
              @checkbox-change="e => handleCheckboxStatus({ ...e, filter })"
            />
          </template>

          <!-- Filter type: range -->
          <template v-else-if="filter.type === 'numeric'">
            <BlockHeader :title="filter.title" />
            <RangeBars
              :range-bars="
                (filter.histogram || []).map((item, i) => ({
                  ...item,
                  id: item.bucket || i
                }))
              "
              :min="Math.floor(+filter.min)"
              :max="Math.ceil(parseFloat(filter.max))"
              :saved-min="filter.savedMin"
              :saved-max="filter.savedMax"
              :total="parseFloat(filter.count)"
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
import Aside from "./Aside.vue";
import Main from "./Main.vue";
import Nav from "./Nav.vue";
import Article from "./Article.vue";
import Loading from "../../components/Loading.vue";
import Calendar from "../../components/Calendar.vue";
import BlockHeader from "../../components/BlockHeader.vue";
import Checkbox from "../../components/Checkbox.vue";
import RangeBars from "../../components/RangeBars.vue";
import axios from "axios";
import { CommonsMixin, baseUrl } from "../../mixins/common.js";
import { store } from "../../mixins/store";

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
      items: [],
      subsetItems: [],
      dictionary: [],
      filters: [],
      phases: [],
      activeTabIndex: 0,
      labelSummary: "",
      labelReset: "",
      activeFilters: new Map(),
      activeFiltersSelection: new Map(),
      isFetchingData: false,
      isFiltering: false
    };
  },
  async created() {
    this.labelSummary = I18n.t("gobierto_investments.projects.summary");
    this.labelReset = I18n.t("gobierto_investments.projects.reset");

    const {
      items,
      phases,
      filters,
      activeFilters,
      activeFiltersSelection
    } = store.state;

    if (items.length) {
      this.items = items;
      this.phases = phases;
      this.filters = filters;

      if (activeFilters) {
        this.subsetItems = this.applyFilters(activeFilters);
        this.activeFiltersSelection = activeFiltersSelection;
      }
    } else {
      this.isFetchingData = true;
      const { items, phases, filters } = await this.getItems();
      this.isFetchingData = false;

      this.items = items;
      this.phases = phases;
      this.filters = filters;
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
        axios.get(baseUrl),
        axios.get(`${baseUrl}/meta?stats=true`)
      ]);

      this.dictionary = attributesDictionary;

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

        filters = this.getFilters(filtersFromConfiguration) || [];

        if (filters.length) {
          this.activeFilters = new Map();
          this.activeFiltersSelection = new Map();
          filters.forEach(f => {
            // initialize active filters
            this.activeFilters.set(f.key, undefined);

            if (f.type === "vocabulary_options") {
              // Add a counter for each option
              f.options = f.options.map(opt => ({
                ...opt,
                counter: items.filter(i =>
                  i.attributes[f.key].map(g => g.id).includes(opt.id)
                ).length
              }));
            }
          });

          // save the filters
          store.addFilters(filters);
        }
      }

      // Assign this object BEFORE next function for better performance
      this.subsetItems = items;

      // Optional callback to update data in background, setup in CONFIGURATION object
      // eslint-disable-next-line require-atomic-updates
      items = await this.alterDataObjectOptional(items);

      // Once items is updated, assign again the result
      this.subsetItems = items;

      // save the items
      store.addItems(items);

      return {
        phases,
        filters,
        items
      };
    },
    filterItems(filter, key, values) {
      this.activeFilters.set(key, filter);
      this.activeFiltersSelection.set(key, values);

      this.setVisibleItems();
    },
    setVisibleItems() {
      this.subsetItems = this.applyFilters(this.activeFilters);

      // save the selected filters
      store.addActiveFilters(this.activeFilters);
      store.addActiveFiltersSelection(this.activeFiltersSelection);

      this.handleIsFiltering();
    },
    applyFilters(activeFilters) {
      let results = this.items;
      activeFilters.forEach(activeFn => {
        if (activeFn) {
          results = results.filter(d => activeFn(d.attributes));
        }
      });

      return results;
    },
    cleanFilters() {
      this.activeFilters.clear();
      this.activeFiltersSelection.clear();
      this.setVisibleItems();
    },
    handleIsFiltering() {
      this.isFiltering =
        [...store.state.activeFilters.values()].filter(Boolean).length > 0;
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

      const index = this.filters.findIndex(d => d.key === key)
      this.filters.splice(index, 1, filter) // To detect array mutations

      const checkboxFilterFn = attrs =>
        attrs[key].find(d => checkboxesSelected.get(+d.id));

      const callback = size ? checkboxFilterFn : undefined;
      this.filterItems(callback, key, checkboxesSelected);
    },
    handleRangeFilter({ min, max, filter }) {
      const { key, min: __min__, max: __max__ } = filter;
      const rangeFilterFn = attrs => attrs[key] >= min && attrs[key] <= max;

      const callback =
        Math.floor(min) <= Math.floor(+__min__) &&
        Math.floor(max) >= Math.floor(+__max__)
          ? undefined
          : rangeFilterFn;
      this.filterItems(callback, key, { min, max });
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

      const callback = !start && !end ? undefined : calendarFilterFn;
      this.filterItems(callback, key, { start, end });
    },
    handleFilterSelections() {
      const { activeFiltersSelection } = store.state;
      const { type, options = [], key, max, min } = this.filter;

      if (type === "vocabulary_options" && options.length) {
        options.map(
          d =>
            (d.isOptionChecked = activeFiltersSelection.has(key)
              ? activeFiltersSelection.get(key).get(d.id)
              : false)
        );
      }

      if (
        type === "numeric" &&
        (max !== undefined || min !== undefined) &&
        activeFiltersSelection.has(key)
      ) {
        const { min: __min__, max: __max__ } = activeFiltersSelection.get(key);

        this.filter.savedMin = __min__;
        this.filter.savedMax = __max__;
      }

      if (type === "range" && activeFiltersSelection.has(key)) {
        const { start, end } = activeFiltersSelection.get(key);

        this.filter.savedStartDate = start;
        this.filter.savedEndDate = end;
      }
    }
  }
};
</script>
