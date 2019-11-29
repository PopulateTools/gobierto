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
          :filters="filters"
          @set-filter="filterItems"
        />
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
    Loading
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
      isFiltering: false,
    };
  },
  async created() {
    this.labelSummary = I18n.t("gobierto_investments.projects.summary");
    this.labelReset = I18n.t("gobierto_investments.projects.reset");

    const { items, phases, filters, activeFilters, activeFiltersSelection } = store.state;

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

      this.handleIsFiltering()
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
      this.isFiltering = [...store.state.activeFilters.values()].filter(Boolean).length > 0
    }
  }
};
</script>
