<template>
  <main>
    <div class="pure-g gutters m_b_4">
      <Aside
        :subsidies-data="subsidiesData"
        :data-download-endpoint="dataDownloadEndpoint"
      />

      <div class="pure-u-1 pure-u-lg-3-4">
        <Nav
          :active-tab="activeTabIndex"
          @active-tab="setActiveTab"
        />
        <div class="visualizations-home-main">
          <Summary v-show="isSummary" />
          <SubsidiesIndex v-show="isSubsidiesIndex" />
          <SubsidiesShow v-if="isSubsidiesShow" />
        </div>
      </div>
    </div>
  </main>
</template>

<script>
import Nav from "./Nav.vue";
import Aside from "./Aside.vue";
import Summary from "./Summary.vue";
import SubsidiesIndex from "./SubsidiesIndex.vue";
import SubsidiesShow from "./SubsidiesShow.vue";

import { EventBus } from "../../mixins/event_bus";
import { store } from "../../mixins/store";

export default {
  name: 'Home',
  components: {
    Aside,
    Nav,
    Summary,
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
