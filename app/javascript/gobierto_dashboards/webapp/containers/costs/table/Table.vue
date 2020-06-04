<template>
  <div v-if="items.length">
    <component
      :is="currentComponent"
      :items="items"
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
      currentComponent: 0,
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
