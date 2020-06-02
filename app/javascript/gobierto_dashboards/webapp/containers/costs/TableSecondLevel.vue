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
      v-for="{ agrupacio, cost_directe_2018, cost_indirecte_2018, cost_total_2018, cost_per_habitant, ingressos, respecte_ambit } in dataGroup"
      :key="agrupacio"
      class="gobierto-dashboards-table--header gobierto-dashboards-tablesecondlevel--header"
    >
      <div class="gobierto-dashboards-table-header--nav">
        {{ agrupacio }}
      </div>
      <div class="gobierto-dashboards-table-header--elements">
        <span>{{ cost_directe_2018.toFixed(0) }}</span>
      </div>
      <div class="gobierto-dashboards-table-header--elements">
        <span>{{ cost_indirecte_2018.toFixed(0) }}</span>
      </div>
      <div class="gobierto-dashboards-table-header--elements">
        <span>{{ cost_total_2018.toFixed(0) }}</span>
      </div>
      <div class="gobierto-dashboards-table-header--elements">
        <span>{{ cost_per_habitant.toFixed(2) }}</span>
      </div>
      <div class="gobierto-dashboards-table-header--elements">
        <span>{{ ingressos.toFixed(0) }}</span>
      </div>
      <div class="gobierto-dashboards-table-header--elements">
        <span>{{ (respecte_ambit).toFixed(2) }}%</span>
      </div>
    </div>
    <div
      v-for="{ nomact, cost_directe_2018, cost_indirecte_2018, cost_total_2018, total, index, cost_per_habitant, ingressos, act_intermedia, respecte_ambit } in dataActIntermediaTotal"
      :key="nomact"
      class="gobierto-dashboards-table--header gobierto-dashboards-tablerow--header"
      :class="{'act-has-children': hasChildren(total)}"
    >
      <template v-if="total > 0">
        <div
          class="gobierto-dashboards-table-header--nav"
          @click="handleToggle(act_intermedia)"
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
        <span>{{ cost_directe_2018.toFixed(0) }}</span>
      </div>
      <div class="gobierto-dashboards-table-header--elements">
        <span>{{ cost_indirecte_2018.toFixed(0) }}</span>
      </div>
      <div class="gobierto-dashboards-table-header--elements">
        <span>{{ cost_total_2018.toFixed(0) }}</span>
      </div>
      <div class="gobierto-dashboards-table-header--elements">
        <span>{{ cost_per_habitant.toFixed(2) }}</span>
      </div>
      <div class="gobierto-dashboards-table-header--elements">
        <span>{{ ingressos.toFixed(0) }}</span>
      </div>
      <div class="gobierto-dashboards-table-header--elements">
        <span>{{ (respecte_ambit).toFixed(2) }}%</span>
      </div>
      <template v-if="total > 0 && selectedToggle === act_intermedia && selectedToggle !== null">
        <div class="gobierto-dashboards-table--secondlevel">
          <div
            v-for="{ nomact, cost_directe_2018, cost_indirecte_2018, cost_total_2018, total, index, cost_per_habitant, ingressos, respecte_ambit } in dataGroupIntermedia"
            :key="nomact"
            class="gobierto-dashboards-table--header gobierto-dashboards-tablerow--header"
          >
            <div class="gobierto-dashboards-table--secondlevel-elements gobierto-dashboards-table-header--nav">
              <p>
                <span class="gobierto-dashboards-table-header--nav-text">{{ nomact }}</span>
              </p>
            </div>
            <div class="gobierto-dashboards-table-header--elements gobierto-dashboards-table--secondlevel-elements">
              <span>{{ cost_directe_2018.toFixed(0) }}</span>
            </div>
            <div class="gobierto-dashboards-table-header--elements gobierto-dashboards-table--secondlevel-elements">
              <span>{{ cost_indirecte_2018.toFixed(0) }}</span>
            </div>
            <div class="gobierto-dashboards-table-header--elements gobierto-dashboards-table--secondlevel-elements">
              <span>{{ cost_total_2018.toFixed(0) }}</span>
            </div>
            <div class="gobierto-dashboards-table-header--elements gobierto-dashboards-table--secondlevel-elements">
              <span>{{ cost_per_habitant.toFixed(2) }}</span>
            </div>
            <div class="gobierto-dashboards-table-header--elements gobierto-dashboards-table--secondlevel-elements">
              <span>{{ ingressos.toFixed(0) }}</span>
            </div>
            <div class="gobierto-dashboards-table-header--elements gobierto-dashboards-table--secondlevel-elements">
              <span>{{ (respecte_ambit).toFixed(2) }}%</span>
            </div>
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
      selectedToggle: null,
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
      const filterActIntermedia = this.$route.params.id
      let dataAgrupacio = this.items.filter(element => element.agrupacio === filterActIntermedia)
      let dataActIntermedia = dataAgrupacio.filter(element => element.act_intermedia !== '')

      let dataActIntermediaValues = [...dataActIntermedia.reduce((r, o) => {
        let key = o.act_intermedia

        const item = r.get(key) || Object.assign({}, o, {
          cost_directe_2018: 0,
          cost_indirecte_2018: 0,
          cost_total_2018: 0,
          ingressos: 0,
          respecte_ambit: 0,
          total: 0,
          nomact: ''
        });

        item.cost_directe_2018 += o.cost_directe_2018
        item.cost_indirecte_2018 += o.cost_indirecte_2018
        item.cost_total_2018 += o.cost_total_2018
        item.ingressos += o.ingressos
        item.respecte_ambit += o.respecte_ambit
        item.total += (o.total || 0) + 1
        item.nomact = o.act_intermedia
        item.respecte_ambit += o.respecte_ambit

        return r.set(key, item);
      }, new Map).values()];

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
          respecte_ambit: 0,
          total: 0,
          cost_per_habitant: 0
        });

        item.cost_directe_2018 += o.cost_directe_2018
        item.cost_indirecte_2018 += o.cost_indirecte_2018
        item.cost_total_2018 += o.cost_total_2018
        item.ingressos += o.ingressos
        item.total += (o.total || 0) + 1
        item.respecte_ambit += o.respecte_ambit
        item.cost_per_habitant += o.cost_per_habitant

        return r.set(key, item);
      }, new Map).values()];
      this.dataGroup = this.dataGroup.filter(element => element.agrupacio === id)
    },
    agrupacioDataFilter(actIntermedia) {
      this.dataGroupIntermedia = this.items.filter(element => element.act_intermedia === actIntermedia)
    },
    hasChildren(value) {
      if (value > 0) {
        return true
      }
    },
    handleToggle(item) {
      this.agrupacioDataFilter(item)
      if (this.selectedToggle !== item){
        this.selectedToggle = item
      } else {
        this.selectedToggle = ''
      }
    }
  }
}
</script>
