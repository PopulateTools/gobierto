<template>
  <div class="pure-u-1 gutters m_b_1">
    <TableHeader />
    <!-- TODO: dynamic components -->
    <TableFirstLevel :items="data" />
  </div>
</template>

<script>
import TableFirstLevel from './TableFirstLevel.vue'
import TableHeader from './TableHeader.vue'
export default {
  name: 'Table',
  components: {
    TableFirstLevel,
    TableHeader
  },
  props: {
    items: {
      type: Array,
      default: () => []
    },
    data: {
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
      labelCoverage: I18n.t("gobierto_dashboards.dashboards.costs.coverage") || ""
    }
  }
}
</script>
