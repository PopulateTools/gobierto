<template>
  <nav class="dashboards-home-nav">
    <ul>
      <li
        :class="{ 'is-active': activeTab === 0 }"
        class="dashboards-home-nav--tab"
        @click="activateTab(0)"
      >
        <i class="fas fa-chart-bar" />
        <i class="far fa-chart-bar" />
        <span>{{ labelSummary }}</span>
      </li>
      <li
        :class="{ 'is-active': activeTab === 1 }"
        class="dashboards-home-nav--tab"
        @click="activateTab(1)"
      >
        <i class="fas fa-clone" />
        <i class="far fa-clone" />
        <span>{{ labelContracts }}</span>
      </li>
      <li
        :class="{ 'is-active': activeTab === 2 }"
        class="dashboards-home-nav--tab"
        @click="activateTab(2)"
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
      labelSummary: '',
      labelContracts: '',
      labelTenders: ''
    }
  },
  routesMapping: ['summary', 'contracts_index', 'tenders_index'],
  created() {
    this.labelSummary = I18n.t("gobierto_dashboards.dashboards.contracts.summary");
    this.labelContracts = I18n.t("gobierto_dashboards.dashboards.contracts.contracts");
    this.labelTenders = I18n.t("gobierto_dashboards.dashboards.contracts.tenders");

    this.activateTab(this.tabIndexFromRouteName(this.$router.currentRoute.name));
  },
  methods: {
    activateTab(index) {
      this.$emit("active-tab", index);

      const newRoute = this.routeNameFromTabIndex(index);
      if (newRoute !== this.$router.currentRoute.name) {
        this.$router.push({ name: newRoute });
      }
    },
    routeNameFromTabIndex(index){
      return this.$options.routesMapping[index];
    },
    tabIndexFromRouteName(name){
      return this.$options.routesMapping.indexOf(name);
    }
  }
}
</script>
