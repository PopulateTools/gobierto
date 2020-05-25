<template>
  <main>
    <div class="pure-g gutters m_b_4">
      <Aside
        :contracts-data="contractsData"
      />

      <div class="pure-u-1 pure-u-lg-3-4">
        <Nav
          :active-tab="activeTabIndex"
          @active-tab="setActiveTab"
        ></Nav>
        <main class="dashboards-home-main">
          <Summary v-show="isSummary"/>
          <ContractsIndex v-show="isContractsIndex"/>
          <ContractsShow v-if="isContractsShow"/>
          <TendersIndex v-show="isTendersIndex"/>
          <TendersShow v-if="isTendersShow"/>
        </main>
      </div>
    </div>
  </main>
</template>

<script>
import Nav from "./Nav.vue";
import Aside from "./Aside.vue";
import Summary from "./../summary/Summary.vue";
import ContractsIndex from "./../contract/ContractsIndex.vue";
import ContractsShow from "./../contract/ContractsShow.vue";
import TendersIndex from "./../tender/TendersIndex.vue";
import TendersShow from "./../tender/TendersShow.vue";

import { EventBus } from "../../mixins/event_bus";
import { store } from "../../mixins/store";

export default {
  name: 'Home',
  components: {
    Aside,
    Nav,
    Summary,
    ContractsIndex,
    ContractsShow,
    TendersIndex,
    TendersShow
  },
  data() {
    return {
      activeTabIndex: store.state.currentTab || 0,
      contractsData: this.$root.$data.contractsData,
    }
  },
  computed: {
    isSummary: function() { return this.$route.name === 'summary' },
    isContractsIndex: function() { return this.$route.name === 'contracts_index' },
    isContractsShow: function() { return this.$route.name === 'contracts_show' },
    isTendersIndex: function() { return this.$route.name === 'tenders_index' },
    isTendersShow: function() { return this.$route.name === 'tenders_show' },
  },
  created(){
    EventBus.$on('refresh_summary_data', () => {
      this.contractsData = this.$root.$data.contractsData;
    });
  },
  methods: {
    setActiveTab(tabIndex) {
      this.activeTabIndex = tabIndex;
      store.addCurrentTab(tabIndex);

      if (this.isSummaryPage(tabIndex)) {
        EventBus.$emit("moved_to_summary");
      }
    },
    isSummaryPage(tabIndex){
      return tabIndex === 0
    }
  }

}
</script>
