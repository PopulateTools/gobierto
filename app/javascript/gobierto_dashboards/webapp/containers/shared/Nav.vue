<template>
  <nav class="dashboards-home-nav">
    <ul>
      <router-link
        :to="{ name: 'summary' }"
        :class="{ 'is-active': activeTab === 0 }"
        tag="li"
        class="dashboards-home-nav--tab"
        @click.native="markTabAsActive(0)"
      >
        <i class="fas fa-chart-bar" />
        <i class="far fa-chart-bar" />
        <span>{{ labelSummary }}</span>
      </router-link>
      <router-link
        :to="{ name: 'contracts_index' }"
        :class="{ 'is-active': activeTab === 1 }"
        tag="li"
        class="dashboards-home-nav--tab"
        @click.native="markTabAsActive(1)"
      >
        <i class="fas fa-clone" />
        <i class="far fa-clone" />
        <span>{{ labelContracts }}</span>
      </router-link>
    </ul>
  </nav>
</template>

<script>
import { EventBus } from "../../mixins/event_bus";

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
      labelSummary: I18n.t("gobierto_dashboards.dashboards.contracts.nav.summary"),
      labelContracts: I18n.t("gobierto_dashboards.dashboards.contracts.nav.contracts"),
      labelTenders: I18n.t("gobierto_dashboards.dashboards.contracts.nav.tenders")
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
  beforeDestroy(){
    EventBus.$off('refresh-active-tab');
  },
  methods: {
    refreshActiveTab(index) {
      const currentTabIndex = this.tabIndexFromRouteName();
      this.markTabAsActive(currentTabIndex);
    },
    markTabAsActive(index) {
      this.$emit("active-tab", index);
    },
    tabIndexFromRouteName(name=this.$router.currentRoute.name){
      return this.$options.routesToNavBarMapping[name];
    }
  }
}
</script>
