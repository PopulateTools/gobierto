<template>
  <div class="pure-g gutters m_b_4">
    <AsideComponent
      :contracts-data="contractsData"
      :data-download-endpoint="dataDownloadEndpoint"
    />

    <div class="pure-u-1 pure-u-md-3-4">
      <NavComponent
        :active-tab="activeTabIndex"
        @active-tab="setActiveTab"
      />
      <div class="visualizations-home-main">
        <SummaryComponent
          v-show="isSummary"
          :active-tab="activeTabIndex"
        />
        <ContractsIndex v-show="isContractsIndex" />
        <ContractsShow v-if="isContractsShow" />
        <AssigneesShow v-if="isAssigneesShow" />
      </div>
    </div>
  </div>
</template>
<script>
import Nav from './Nav.vue';
import Aside from './Aside.vue';
import Summary from './Summary.vue';
import ContractsIndex from './ContractsIndex.vue';
import ContractsShow from './ContractsShow.vue';
import AssigneesShow from './AssigneesShow.vue';

import { EventBus } from '../../lib/mixins/event_bus';
import { store } from '../../lib/mixins/store';

export default {
  name: 'HomeComponent',
  components: {
    AsideComponent: Aside,
    NavComponent: Nav,
    SummaryComponent: Summary,
    ContractsIndex,
    ContractsShow,
    AssigneesShow,
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
      contractsData: this.$root.$data.contractsData,
    }
  },
  computed: {
    isSummary() { return this.$route.name === 'summary' },
    isContractsIndex() { return this.$route.name === 'contracts_index' },
    isContractsShow() { return this.$route.name === 'contracts_show' },
    isAssigneesShow() { return this.$route.name === 'assignees_show' },
  },
  created(){
    EventBus.$on('refresh-summary-data', () => {
      this.contractsData = this.$root.$data.contractsData;
    });
    EventBus.$on("update-filters", () => this.updateFilters());
    EventBus.$on("update-tab", () => this.updateTab());
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
    isSummaryPage(tabIndex){
      return tabIndex === 0
    },
    updateFilters() {
      const { name } = this.$route
      const components = ['contracts_show', 'assignees_show']
      if (components.includes(name)) {
        this.updateTab()
      }
    },
    updateTab() {
      // eslint-disable-next-line no-unused-vars
      this.$router.replace('/visualizaciones/contratos/adjudicaciones').catch(err => {})
      this.activeTabIndex = 1
    }
  }
}
</script>
