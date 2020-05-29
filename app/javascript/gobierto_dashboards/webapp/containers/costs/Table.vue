<template>
  <div v-if="items.length">
    <table>
      <thead>
        <th
          v-for="item in theadData"
          :key="item"
          class="gobierto-dashboards-table-costs--th"
        >
          <span class="gobierto-dashboards-table-costs--th">
            {{ item }}
          </span>
        </th>
      </thead>
    </table>
    <TableRow :items="items" />
  </div>
</template>

<script>
import TableRow from './TableRow.vue'
export default {
  name: 'Table',
  components: {
    TableRow
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
    console.log(this.data)
    this.theadData = [ this.labelCostDirect, this.labelCostIndirect, this.labelTotal, this.labelCostPerInhabitant, this.labelIncome, this.labelCoverage]
  }
}
</script>
