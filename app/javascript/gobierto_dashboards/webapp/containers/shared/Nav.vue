<template>
  <nav class="dashboards-home-nav">
    <ul>
      <li
        :class="{ 'is-active': activeTab === 0 }"
        class="dashboards-home-nav--tab"
        @click="navigateToTab(0)"
      >
        <i class="fas fa-chart-bar" />
        <i class="far fa-chart-bar" />
        <span>{{ labelSummary }}</span>
      </li>
      <li
        :class="{ 'is-active': activeTab === 1 }"
        class="dashboards-home-nav--tab"
        @click="navigateToTab(1)"
      >
        <i class="fas fa-clone" />
        <i class="far fa-clone" />
        <span>{{ labelContracts }}</span>
      </li>
      <li
        :class="{ 'is-active': activeTab === 2 }"
        class="dashboards-home-nav--tab"
        @click="navigateToTab(2)"
      >
        <i class="fas fa-clone" />
        <i class="far fa-clone" />
        <span>{{ labelTenders }}</span>
      </li>
    </ul>
  </nav>
</template>

<script>
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
      labelSummary: I18n.t("gobierto_dashboards.dashboards.contracts.summary"),
      labelContracts: I18n.t("gobierto_dashboards.dashboards.contracts.contracts"),
      labelTenders: I18n.t("gobierto_dashboards.dashboards.contracts.tenders")
    }
  },
  routesToNavBarMapping: {
    'summary': 0,
    'contracts_index': 1,
    'contracts_show': 1,
    'tenders_index': 2,
    'tenders_show': 2
  },
  navBarNavigationMapping: [
    'summary',
    'contracts_index',
    'tenders_index'
  ],
  created(){
    const currentTabIndex = this.tabIndexFromRouteName();
    this.markTabAsActive(currentTabIndex);
  },
  methods: {
    navigateToTab(index) {
      this.markTabAsActive(index);

      const newRoute = this.routeNameFromTabIndex(index);
      if (newRoute !== this.$router.currentRoute.name) {
        this.$router.push({ name: newRoute });
      }
    },
    markTabAsActive(index) {
      this.$emit("active-tab", index);
    },
    routeNameFromTabIndex(index){
      return this.$options.navBarNavigationMapping[index];
    },
    tabIndexFromRouteName(name=this.$router.currentRoute.name){
      return this.$options.routesToNavBarMapping[name];
    }
  }
}
</script>
