<template>
  <div>
    <div class="pure-g m_b_1">
      <div class="pure-u-1 pure-u-lg-1-4" />
      <div class="pure-u-1 pure-u-lg-3-4">
        <Nav
          :active-tab="activeTabIndex"
          @active-tab="activeTabIndex = $event"
        />
      </div>
    </div>

    <div class="pure-g m_b_4">
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
      activeTabIndex: 1,
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
          data: { data: attributesDictionary = [], meta: filtersSelected }
        }
      ] = responses;

      this.dictionary = attributesDictionary;

      this.items = this.setData(items);
      this.subsetItems = this.items;

      if (filtersSelected) {
        // get the phases, and append the items for that phase
        this.phases = this.getPhases(filtersSelected).map(phase => ({
          ...phase,
          items: this.items.filter(d => (d.phases.length ? d.phases[0].id === phase.id : false))
        }));

        this.filters = this.getFilters(filtersSelected) || [];

        if (this.filters.length) {
          this.activeFilters = new Map();
          this.filters.forEach(f => this.activeFilters.set(f.key, undefined));
        }
      }
    });
  },
  methods: {
    filterItems(filter, key) {
      this.activeFilters.set(key, filter);

      let a = this.items
      this.activeFilters.forEach(activeFn => {
        if (activeFn) {
          a = a.filter(d => activeFn(d.attributes));
        }
      });

      console.log(a);

      this.subsetItems = a

    }
  }
};
</script>
