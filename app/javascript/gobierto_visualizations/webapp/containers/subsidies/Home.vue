<template>
  <div class="pure-g gutters m_b_4">
    <AsideComponent
      :subsidies-data="subsidiesData"
      :data-download-endpoint="dataDownloadEndpoint"
    />

    <div class="pure-u-1 pure-u-lg-3-4">
      <NavComponent
        :active-tab="activeTabIndex"
        @active-tab="setActiveTab"
      />
      <div class="visualizations-home-main">
        <SummaryComponent v-show="isSummary" />
        <SubsidiesIndex v-show="isSubsidiesIndex" />
        <SubsidiesShow v-if="isSubsidiesShow" />
      </div>
    </div>
  </div>
</template>

<script>
import Nav from './Nav.vue';
import Aside from './Aside.vue';
import Summary from './Summary.vue';
import SubsidiesIndex from './SubsidiesIndex.vue';
import SubsidiesShow from './SubsidiesShow.vue';

import { EventBus } from '../../lib/mixins/event_bus';
import { store } from '../../lib/mixins/store';

export default {
  name: 'HomeComponent',
  components: {
    AsideComponent: Aside,
    NavComponent: Nav,
    SummaryComponent: Summary,
    SubsidiesIndex,
    SubsidiesShow
  },
  props: {
    dataDownloadEndpoint: {
      type: String,
      default: null
    }
  },
  data() {
    return {
      activeTabIndex: store.state.currentTab || 0,
      subsidiesData: this.$root.$data.subsidiesData,
    }
  },
  computed: {
    isSummary() { return this.$route.name === 'summary' },
    isSubsidiesIndex() { return this.$route.name === 'subsidies_index' },
    isSubsidiesShow() { return this.$route.name === 'subsidies_show' },
  },
  created() {
    EventBus.$on('refresh-summary-data', () => {
      this.subsidiesData = this.$root.$data.subsidiesData;
    });
    EventBus.$on("update-tab", () => this.updateTab());
    EventBus.$on("update-filters", () => this.updateFilters());
  },
  mounted() {
    EventBus.$emit("mounted");
  },
  methods: {
    setActiveTab(tabIndex) {
      this.activeTabIndex = tabIndex;
      store.addCurrentTab(tabIndex);

      if (this.isSummaryPage(tabIndex)) {
        EventBus.$emit("moved-to-summary");
      }
    },
    isCurrentPath(componentPathName){
      return this.$route.name === componentPathName
    },
    isSummaryPage(tabIndex){
      return tabIndex === 0
    },
    updateFilters() {
      const { name } = this.$route
      const components = ['subsidies_show', 'subsidies_index']
      if (components.includes(name)) {
        this.updateTab()
      }
    },
    updateTab() {
      // eslint-disable-next-line no-unused-vars
      this.$router.replace('/visualizaciones/subvenciones/subvenciones').catch(err => {})
      this.activeTabIndex = 1
    }
  }

}
</script>
