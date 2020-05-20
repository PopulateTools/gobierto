<template>
  <main>
    <div class="pure-g gutters m_b_4">
      <Aside />

      <div class="pure-u-1 pure-u-lg-3-4">
        <Nav
          :active-tab="activeTabIndex"
          @active-tab="setActiveTab"
        ></Nav>
        <main class="dashboards-home-main">
          <Summary v-show="isCurrentPath('summary')"/>
          <ContractsIndex v-show="isCurrentPath('contracts_index')"/>
          <ContractsShow v-if="isCurrentPath('contracts_show')"/>
          <TendersIndex v-show="isCurrentPath('tenders_index')"/>
          <TendersShow v-if="isCurrentPath('tenders_show')"/>
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
    }
  },
  methods: {
    setActiveTab(tabIndex) {
      this.activeTabIndex = tabIndex;
      store.addCurrentTab(tabIndex);

      if (this.isSummaryPage(tabIndex)) {
        EventBus.$emit("moved_to_summary");
      }
    },
    isCurrentPath(componentPathName){
      return this.$route.name === componentPathName
    },
    isSummaryPage(tabIndex){
      return tabIndex === 0
    }
  }

}
</script>
