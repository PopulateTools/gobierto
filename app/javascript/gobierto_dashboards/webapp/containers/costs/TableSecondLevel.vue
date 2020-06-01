<template>
  <div v-if="items.length">
    <div class="gobierto-dashboards-table--header">
      <div class="gobierto-dashboards-table-header--nav">

      </div>
      <div
      v-for="item in theadData"
      :key="item"
      :class="`gobierto-dashboards-table-header--${item}`"
      class="gobierto-dashboards-table-header--elements">
        <i
          class="far fa-question-circle"
          style="color: var(--color-base)"
        />
        <span class="gobierto-dashboards-header--elements-text">
          {{ item }}
        </span>
      </div>
    </div>
    <div v-for="{ nomact, cost_directe_2018, cost_indirecte_2018, cost_total_2018, total, index, cost_per_habitant, ingressos } in dataActIntermediaTotal" :key="nomact"
      class="gobierto-dashboards-table--header gobierto-dashboards-tablerow--header"
    >
      <div class="gobierto-dashboards-table-header--nav">
        <span>
          {{ nomact }} {{ total }}
        </span>
      </div>
      <div class="gobierto-dashboards-table-header--elements">
        <div>{{ cost_directe_2018.toFixed(0) }}</div>
      </div>
      <div class="gobierto-dashboards-table-header--elements">
        <div>{{ cost_indirecte_2018.toFixed(0) }}</div>
      </div>
      <div class="gobierto-dashboards-table-header--elements">
        <div>{{ cost_total_2018.toFixed(0) }}</div>
      </div>
      <div class="gobierto-dashboards-table-header--elements">
        <div>{{ cost_per_habitant.toFixed(2) }}</div>
      </div>
      <div class="gobierto-dashboards-table-header--elements">
        <div>{{ ingressos.toFixed(0) }}</div>
      </div>
    </div>
  </div>
</template>
<script>
import { money } from 'lib/shared'
export default {
  name: "TableSecondLevel",
  data() {
    return {
      labelTotal: I18n.t("gobierto_dashboards.dashboards.costs.total") || "",
      labelCostPerInhabitant: I18n.t("gobierto_dashboards.dashboards.costs.cost_per_inhabitant") || "",
      labelCostDirect: I18n.t("gobierto_dashboards.dashboards.costs.cost_direct") || "",
      labelCostIndirect: I18n.t("gobierto_dashboards.dashboards.costs.cost_indirect") || "",
      labelCostInhabitant: I18n.t("gobierto_dashboards.dashboards.costs.cost_inhabitant") || "",
      labelIncome: I18n.t("gobierto_dashboards.dashboards.costs.income") || "",
      labelCoverage: I18n.t("gobierto_dashboards.dashboards.costs.coverage") || "",
      dataActIntermediaTotal: [],
      items: this.$root.$data.costData,
      theadData: []
    }
  },
  created() {
    this.intermediaData()
    this.theadData = [ this.labelCostDirect, this.labelCostIndirect, this.labelTotal, this.labelCostInhabitant, this.labelIncome, this.labelCoverage]
  },
  methods: {
    intermediaData() {
      this.toggleIntermedia = true
      const filterActIntermedia = this.$route.params.id
      let dataAgrupacio = this.items.filter(element => element.agrupacio === filterActIntermedia)
      let dataActIntermedia = dataAgrupacio.filter(element => element.act_intermedia !== '')

      const dataActIntermediaValues = Object.values(dataActIntermedia.reduce((r, e) => {
        let key = e.act_intermedia
        if (!r[key]) r[key] = e;
        else {
          r[key].cost_directe_2018 += e.cost_directe_2018
          r[key].cost_indirecte_2018 += e.cost_indirecte_2018
          r[key].cost_total_2018 += e.cost_total_2018
          r[key].ingressos += e.ingressos
          r[key].nomact = e.act_intermedia
          r[key].total = (r[key].total || 1) + 1
        }
        return r;
      }, {}))

      const dataActIntermediaWithoutValues = dataAgrupacio.filter(element => element.act_intermedia === '')

      this.dataActIntermediaTotal = [...dataActIntermediaWithoutValues, ...dataActIntermediaValues]
    }
  }
}
</script>
