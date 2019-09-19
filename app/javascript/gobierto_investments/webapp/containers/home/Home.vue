<template>
  <div>
    <div class="pure-g m_b_1">
      <div class="pure-u-1 pure-u-lg-1-4" />
      <div class="pure-u-1 pure-u-lg-3-4">
        <Nav @active-tab="activeTabIndex = $event" />
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
      activeTabIndex: 0,
      labelSummary: ""
    };
  },
  created() {
    this.labelSummary = I18n.t("gobierto_investments.projects.summary")

    axios
      .all([
        axios.get(this.$baseUrl),
        axios.get(`${this.$baseUrl}/meta?stats=true`)
      ])
      .then(responses => {
        const [
          {
            data: { data: items = [] }
          },
          {
            data: {
              data: attributesDictionary = [],
              meta: filtersSelected = {}
            }
          }
        ] = responses;

        this.dictionary = attributesDictionary;

        this.items = this.setData(items);
        this.subsetItems = this.items;

        // get the phases, and append the items for that phase
        this.phases = this.getPhases(filtersSelected).map(phase => ({ ...phase, items: this.items.filter(d => d.phases.length ? d.phases[0].id === phase.id : false) }))

        for (const key in filtersSelected) {
          if (Object.prototype.hasOwnProperty.call(filtersSelected, key)) {
            const { field_type: type = "", vocabulary_terms: options = [], name_translations: title = {} } = this.getAttributesByKey(key);
            const element = filtersSelected[key];

            this.filters.push({
              ...element,
              title,
              options,
              type,
              key
            });
          }
        }
      });
  },
  methods: {
    filterItems(filter) {
      this.subsetItems = filter ? this.items.filter(d => filter(d.attributes)) : this.items
    }
  }
};
</script>