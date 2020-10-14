<template>
  <TableRow
    :items="dataGroup"
    :table-header="showTableHeader"
  />
</template>
<script>
import { VueFiltersMixin } from "lib/shared"
import TableRow from './TableRow.vue'
export default {
  name: "TableSubHeader",
  components: {
    TableRow
  },
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
      showTableHeader: true
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
      this.dataGroup = this.items.filter(element => element.ordreagrup === id)
    }
  }
}
</script>
