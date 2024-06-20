<template>
  <nav
    class="visualizations-home-nav"
    role="navigation"
    aria-label="tabs navigation"
  >
    <ul>
      <router-link
        :to="{ name: 'summary' }"
        :class="{ 'is-active': activeTab === 0 }"
        tag="li"
        class="visualizations-home-nav--tab"
        @click.native="markTabAsActive(0, true)"
      >
        <i class="fas fa-chart-bar" />
        <i class="far fa-chart-bar" />
        <span>{{ labelSummary }}</span>
      </router-link>
      <router-link
        :to="{ name: 'contracts_index' }"
        :class="{ 'is-active': activeTab === 1 }"
        tag="li"
        class="visualizations-home-nav--tab"
        @click.native="markTabAsActive(1, true)"
      >
        <i class="fas fa-clone" />
        <i class="far fa-clone" />
        <span>{{ labelContracts }}</span>
      </router-link>
    </ul>
  </nav>
</template>

<script>
import { EventBus } from '../../lib/mixins/event_bus';

export default {
  name: 'Nav',
  props: {
    activeTab: {
      type: Number,
      default: 0
    }
  },
  data() {
    return {
      labelSummary: I18n.t("gobierto_visualizations.visualizations.contracts.nav.summary"),
      labelContracts: I18n.t("gobierto_visualizations.visualizations.contracts.nav.contracts"),
      labelTenders: I18n.t("gobierto_visualizations.visualizations.contracts.nav.tenders")
    }
  },
  routesToNavBarMapping: {
    'summary': 0,
    'contracts_index': 1,
    'contracts_show': 1,
    'assignees_show': 1,
    'tenders_index': 2,
    'tenders_show': 2,
  },
  created(){
    EventBus.$on('refresh-active-tab', () => this.refreshActiveTab());
    this.refreshActiveTab();
  },
  beforeUnmount(){
    EventBus.$off('refresh-active-tab');
  },
  methods: {
    refreshActiveTab() {
      const currentTabIndex = this.tabIndexFromRouteName();
      this.markTabAsActive(currentTabIndex, false);
    },
    markTabAsActive(index, scrollTo) {
      this.$emit("active-tab", index);
      if (scrollTo) this.scrollBehavior();
    },
    tabIndexFromRouteName(name=this.$router.currentRoute.name){
      return this.$options.routesToNavBarMapping[name];
    },
    scrollBehavior() {
      const selector = "gobierto-visualizations-contracts-app";
      const element = document.getElementById(selector);
      window.scrollTo({ top: element.offsetTop, behavior: "smooth" });
    }
  }
}
</script>
