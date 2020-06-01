<template>
  <div v-if="items.length">
    <div class="gobierto-dashboards-table--header">
      <div class="gobierto-dashboards-table-header--nav" />
      <div
        v-for="item in theadData"
        :key="item"
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
    <div
      v-for="{ agrupacio, cost_directe_2018, cost_indirecte_2018, cost_total_2018,cost_per_habitant, ingressos, respecte_ambit } in dataGroup"
      :key="agrupacio"
      class="gobierto-dashboards-table--header gobierto-dashboards-tablesecondlevel--header"
    >
      <div class="gobierto-dashboards-table-header--nav">
        {{ agrupacio }}
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
      <div class="gobierto-dashboards-table-header--elements">
        <div>{{ (respecte_ambit).toFixed(2) }}</div>
      </div>
    </div>
    <div
      v-for="{ nomact, cost_directe_2018, cost_indirecte_2018, cost_total_2018, total, index, cost_per_habitant, ingressos, act_intermedia } in dataActIntermediaTotal"
      :key="nomact"
      class="gobierto-dashboards-table--header gobierto-dashboards-tablerow--header"
      :class="{'act-has-children': hasChildren(total)}"
    >
      <template v-if="total > 0">
        <div
          class="gobierto-dashboards-table-header--nav"
          @click="toggleActIntermida(act_intermedia)"
        >
          <p>
            <span class="gobierto-dashboards-table-header--nav-text">{{ nomact }}</span>
            ({{ total }} {{ labelActivities }})
          </p>
        </div>
      </template>
      <template v-else>
        <div class="gobierto-dashboards-table-header--nav">
          <p>
            <span class="gobierto-dashboards-table-header--nav-text">{{ nomact }}</span>
          </p>
        </div>
      </template>
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
      <template v-if="total > 0">
        <div
          v-for="{ nomact, cost_directe_2018, cost_indirecte_2018, cost_total_2018, total, index, cost_per_habitant, ingressos } in dataGroupIntermedia"
          :key="nomact"
          class="toggle-tablerow gobierto-dashboards-table--header gobierto-dashboards-tablerow--header"
        >
          <div class="gobierto-dashboards-table-header--nav">
            <p>
              <span class="gobierto-dashboards-table-header--nav-text">{{ nomact }}</span>
            </p>
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
      </template>
    </div>
  </div>
</template>
<script>
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
      labelActivities: I18n.t("gobierto_dashboards.dashboards.costs.activities") || "",
      dataActIntermediaTotal: [],
      items: this.$root.$data.costData,
      theadData: [],
      dataGroupIntermedia: [],
      dataGroup: [],
      isToggle: false
    }
  },
  created() {
    this.intermediaData()
    this.theadData = [ this.labelCostDirect, this.labelCostIndirect, this.labelTotal, this.labelCostInhabitant, this.labelIncome, this.labelCoverage]
    const {
      params: {
        id: agrupacioId
      }
    } = this.$route
    this.agrupacioData(agrupacioId)
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

      this.dataActIntermediaTotal = [...dataActIntermediaValues, ...dataActIntermediaWithoutValues]
    },
    agrupacioData(id) {
      this.dataGroup = [...this.items.reduce((r, o) => {
        const key = o.agrupacio

        const item = r.get(key) || Object.assign({}, o, {
          cost_directe_2018: 0,
          cost_indirecte_2018: 0,
          cost_total_2018: 0,
          ingressos: 0,
          total: 0
        });

        item.cost_directe_2018 += o.cost_directe_2018
        item.cost_indirecte_2018 += o.cost_indirecte_2018
        item.cost_total_2018 += o.cost_total_2018
        item.ingressos += o.ingressos
        item.total += (o.total || 0) + 1
        item.respecte_ambit += o.respecte_ambit

        return r.set(key, item);
      }, new Map).values()];
      this.dataGroup = this.dataGroup.filter(element => element.agrupacio === id)
    },
    agrupacioDataFilter(actIntermedia) {
      console.log("actIntermedia", actIntermedia);
      this.dataGroupIntermedia = this.items.filter(element => element.act_intermedia === actIntermedia)
    },
    hasChildren(value) {
      if (value > 0) {
        return true
      }
    },
    toggleActIntermida(value) {
      this.agrupacioDataFilter(value)
      this.isToggle = true
    }
  }
}
</script>
