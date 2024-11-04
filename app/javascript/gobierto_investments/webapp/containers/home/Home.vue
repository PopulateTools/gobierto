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
      items: [],
      subsetItems: [],
      phases: [],
      metadata: [],
      stats: {},
      activeTabIndex: 0,
      labelSummary: I18n.t("gobierto_investments.projects.summary") || "",
      labelReset: I18n.t("gobierto_investments.projects.reset") || "",
      labelLoading: I18n.t("gobierto_investments.projects.loading") || "",
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

      // get the phases
      const phases = this.getPhases(stats, metadata)
        // append what items are in that phase
        .map(phase => ({
          ...phase,
          items: items.filter(d =>
            d.phases.length ? d.phases[0].id === phase.id : false
          )
        }));

      // Add dictionary of phases in order to fulfill project page
      items = items.map(item => ({ ...item, phasesDictionary: phases }));

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
  }
};
</script>
