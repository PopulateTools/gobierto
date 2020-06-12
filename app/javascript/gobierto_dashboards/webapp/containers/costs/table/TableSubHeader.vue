<template>
  <table class="gobierto-dashboards-table gobierto-dashboards-table--subheader">
    <tbody>
      <tr
        v-for="{ agrupacio, cost_directe, cost_indirecte, cost_total, totalPerHabitant, ingressos, coverage } in dataGroup"
        :key="agrupacio"
        class="gobierto-dashboards-tablerow--header gobierto-dashboards-tablesecondlevel--header"
      >
        <td class="gobierto-dashboards-table-header--nav">
          <span>{{ agrupacio }}</span>
        </td>
        <td :data-th="labelCostDirect" class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-direct">
          <span>{{ cost_directe | money }}</span>
        </td>
        <td :data-th="labelCostIndirect" class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-indirect">
          <span>{{ cost_indirecte | money }}</span>
        </td>
        <td :data-th="labelCostTotal" class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-total">
          <span>{{ cost_total | money }}</span>
        </td>
        <td :data-th="labelCostInhabitant" class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-inhabitant">
          <span>{{ totalPerHabitant | money }}</span>
        </td>
        <td :data-th="labelCostIncome" class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-income">
          <span>{{ ingressos | money }}</span>
        </td>
        <td :data-th="labelCostCoverage" class="gobierto-dashboards-table-header--elements">
          <span>{{ (coverage).toFixed(0) }}%</span>
        </td>
      </tr>
    </tbody>
  </table>
</template>
<script>
import { VueFiltersMixin } from "lib/shared"
export default {
  name: "TableSubHeader",
  mixins: [VueFiltersMixin],
  props: {
    items: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      dataGroup: [],
      labelCostDirect: I18n.t("gobierto_dashboards.dashboards.costs.cost_direct") || "",
      labelCostIndirect: I18n.t("gobierto_dashboards.dashboards.costs.cost_indirect") || "",
      labelCostTotal: I18n.t("gobierto_dashboards.dashboards.costs.total") || "",
      labelCostInhabitant: I18n.t("gobierto_dashboards.dashboards.costs.cost_inhabitant") || "",
      labelCostIncome: I18n.t("gobierto_dashboards.dashboards.costs.income") || "",
      labelCostCoverage: I18n.t("gobierto_dashboards.dashboards.costs.coverage") || "",
    }
  },
  watch: {
    $route(to) {
      if (to.name === 'TableSecondLevel') {
        const {
          params: {
            id: agrupacioId
          }
        } = this.$route
        this.agrupacioData(agrupacioId)
      }
    }
  },
  created() {
    const {
      params: {
        id: agrupacioId
      }
    } = this.$route
    this.agrupacioData(agrupacioId)
  },
  methods: {
    agrupacioData(id) {
      this.dataGroup = this.items.filter(element => element.ordre_agrupacio === id)
    }
  }
}
</script>
