<template>
  <div v-if="items.length">
    <div class="gobierto-dashboards-table--header">
      <div class="gobierto-dashboards-table-header--nav">

      </div>
      <div
        v-for="item in theadData"
        :key="item"
        :class="`gobierto-dashboards-table-header--${item}`"
        class="gobierto-dashboards-table-header--elements"
      >
        <i
          class="far fa-question-circle"
          style="color: var(--color-base)"
        />
        <span class="gobierto-dashboards-header--elements-text">
          {{ item }}
        </span>
      </div>
    </div>
    <TableFirstLevel :items="data" />
  </div>
</template>

<script>
import TableFirstLevel from './TableFirstLevel.vue'
export default {
  name: 'Table',
  components: {
    TableFirstLevel
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
      labelCoverage: I18n.t("gobierto_dashboards.dashboards.costs.coverage") || "",
      theadData: []
    }
  },
  created() {
    this.theadData = [ this.labelCostDirect, this.labelCostIndirect, this.labelTotal, this.labelCostInhabitant, this.labelIncome, this.labelCoverage]
  }
}
</script>
