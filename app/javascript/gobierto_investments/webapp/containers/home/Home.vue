<template>
  <div class="investments">
    <div class="pure-g gutters m_b_1">
      <div class="pure-u-1 pure-u-lg-1-4" />
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
import axios from "axios";
import { CommonsMixin } from "../../mixins/common.js";

export default {
  name: "Home",
  components: {
    Aside,
    Main,
    Nav,
    Article
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
      labelSummary: ""
    };
  },
  created() {
    this.labelSummary = I18n.t("gobierto_investments.projects.summary");

    axios.all([axios.get(this.$baseUrl), axios.get(`${this.$baseUrl}/meta?stats=true`)]).then(responses => {
      const [
        {
          data: { data: items = [] }
        },
        {
          data: { data: attributesDictionary = [], meta: filtersFromConfiguration }
        }
      ] = responses;

      this.dictionary = attributesDictionary;
      this.items = this.setData(items);

      if (filtersFromConfiguration) {
        // get the phases, and append what items are in that phase
        const phases = this.getPhases(filtersFromConfiguration)
        this.phases = phases.map(phase => ({
          ...phase,
          items: this.items.filter(d => (d.phases.length ? d.phases[0].id === phase.id : false))
        }));

        // Add dictionary of phases in order to fulfill project page
        this.items = this.items.map(item => ({ ...item, phasesDictionary: phases }))

        this.filters = this.getFilters(filtersFromConfiguration) || [];

        if (this.filters.length) {
          this.activeFilters = new Map();
          this.filters.forEach(f => {
            // initialize active filters
            this.activeFilters.set(f.key, undefined);

            if (f.type === "vocabulary_options") {
              // Add a counter for each option
              f.options = f.options.map(opt => ({ ...opt, counter: this.items.filter(i => i.attributes[f.key].map(g => g.id).includes(opt.id)).length }))
            }
          });
        }
      }

      this.subsetItems = this.items;
    })
  },
  methods: {
    filterItems(filter, key) {
      this.activeFilters.set(key, filter);

      let results = this.items
      this.activeFilters.forEach(activeFn => {
        if (activeFn) {
          results = results.filter(d => activeFn(d.attributes));
        }
      });

      this.subsetItems = results;
    }
  }
};
</script>
