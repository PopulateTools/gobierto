<template>
  <div class="pure-u-1 m_b_1">
    <h2
      id="gobierto-dashboards-title-detail"
      class="gobierto-dashboards-title"
    >
      {{ labelDetail }}
    </h2>
    <component
      :is="currentComponent"
      :items="items"
      :items-filter="itemsFilter"
      :year="year"
      @changeTableHandler="changeTableComponent"
    />
  </div>
</template>
<script>
const COMPONENTS_TABLE = [
  () => import("./TableFirstLevel.vue"),
  () => import("./TableSecondLevel.vue"),
  () => import("./TableItem.vue")
];

export default {
  name: 'Table',
  props: {
    items: {
      type: Array,
      default: () => []
    },
    itemsFilter: {
      type: Array,
      default: () => []
    },
    year: {
      type: String,
      default: ''
    }
  },
  data() {
    return {
      labelTotal: I18n.t("gobierto_dashboards.dashboards.costs.total") || "",
      labelCostPerInhabitant: I18n.t("gobierto_dashboards.dashboards.costs.cost_per_inhabitant") || "",
      labelCostDirect: I18n.t("gobierto_dashboards.dashboards.costs.cost_direct") || "",
      labelCostIndirect: I18n.t("gobierto_dashboards.dashboards.costs.cost_indirect") || "",
      labelCostInhabitant: I18n.t("gobierto_dashboards.dashboards.costs.cost_inhabitant") || "",
      labelIncome: I18n.t("gobierto_dashboards.dashboards.costs.income") || "",
      labelCoverage: I18n.t("gobierto_dashboards.dashboards.costs.coverage") || "",
      labelDetail: I18n.t("gobierto_dashboards.dashboards.costs.detail") || "",
      currentComponent: 0,
    }
  },
  watch: {
    $route(to) {
      if (to.name === 'TableSecondLevel') {
        this.currentComponent = COMPONENTS_TABLE[1];
      } else if ( to.name === 'TableItem') {
        this.currentComponent = COMPONENTS_TABLE[2];
      } else {
        this.currentComponent = COMPONENTS_TABLE[0];
      }
    }
  },
  created(){
    this.currentComponent = COMPONENTS_TABLE[0];

    const {
      name: nameComponent
    } = this.$route;

    if (nameComponent === 'TableSecondLevel') {
      this.currentComponent = COMPONENTS_TABLE[1];
    } else if ( nameComponent === 'TableItem') {
      this.currentComponent = COMPONENTS_TABLE[2];
    } else {
      this.currentComponent = COMPONENTS_TABLE[0];
    }
  },
  methods: {
    changeTableComponent(value) {
      this.currentComponent = COMPONENTS_TABLE[value];
    },
  }
}
</script>
