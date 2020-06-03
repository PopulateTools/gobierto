<template>
  <div v-if="items.length">
    <TableHeader>
      <router-link
        :to="{ name: 'Home'}"
        class="gobierto-dashboards-table-header--link-top"
        tag="a"
      >
        <i class="fas fa-chevron-left"/>
        {{ labelSeeAll }}
      </router-link>
    </TableHeader>
    <TableSubHeader />
    <div
      v-for="{ nomact, codiact, cost_directe_2018, cost_indirecte_2018, cost_total_2018, total, index, cost_per_habitant, ingressos, act_intermedia, respecte_ambit, agrupacio } in dataActIntermediaTotal"
      :key="nomact"
      class="gobierto-dashboards-table--header gobierto-dashboards-tablerow--header"
      :class="{'act-has-children': hasChildren(total)}"
    >
      <template v-if="total > 0">
        <div
          class="gobierto-dashboards-table-header--nav"
          @click="handleToggle(act_intermedia)"
        >
          <span class="gobierto-dashboards-table-header--nav-text">{{ nomact }}</span>
          ({{ total }} {{ labelActivities }})
        </div>
      </template>
      <template v-else>
        <div class="gobierto-dashboards-table-header--nav">
          <router-link
            :to="{ name: 'TableItem', params: { item: codiact, id: agrupacio } }"
            class="gobierto-dashboards-table-header--link"
            tag="a"
          >
            <span class="gobierto-dashboards-table-header--nav-text">{{ nomact }}</span>
          </router-link>
        </div>
      </template>
      <div class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-direct">
        <span>{{ cost_directe_2018 | money }}</span>
      </div>
      <div class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-indirect">
        <span>{{ cost_indirecte_2018 | money }}</span>
      </div>
      <div class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-total">
        <span>{{ cost_total_2018 | money }}</span>
      </div>
      <div class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-inhabitant">
        <span>{{ cost_per_habitant | money }}</span>
      </div>
      <div class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-income">
        <span>{{ ingressos | money }}</span>
      </div>
      <div class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-coverage">
        <span>{{ (respecte_ambit) | money }}%</span>
      </div>
      <template v-if="total > 0 && selectedToggle === act_intermedia && selectedToggle !== null">
        <div class="gobierto-dashboards-table--secondlevel">
          <div
            v-for="{ nomact, codiact, cost_directe_2018, cost_indirecte_2018, cost_total_2018, total, index, cost_per_habitant, ingressos, respecte_ambit, agrupacio } in dataGroupIntermedia"
            :key="nomact"
            class="gobierto-dashboards-table--header gobierto-dashboards-tablerow--header"
          >
            <div class="gobierto-dashboards-table--secondlevel-elements gobierto-dashboards-table-header--nav">
              <router-link
                :to="{ name: 'TableItem', params: { item: codiact, id: agrupacio } }"
                class="gobierto-dashboards-table-header--link"
                tag="a"
              >
                <span class="gobierto-dashboards-table-header--nav-text">{{ nomact }}</span>
              </router-link>
            </div>
            <div class="gobierto-dashboards-table-header--elements gobierto-dashboards-table--secondlevel-elements gobierto-dashboards-table-color-direct">
              <span>{{ cost_directe_2018 | money }}</span>
            </div>
            <div class="gobierto-dashboards-table-header--elements gobierto-dashboards-table--secondlevel-elements gobierto-dashboards-table-color-indirect">
              <span>{{ cost_indirecte_2018 | money }}</span>
            </div>
            <div class="gobierto-dashboards-table-header--elements gobierto-dashboards-table--secondlevel-elements gobierto-dashboards-table-color-total">
              <span>{{ cost_total_2018 | money }}</span>
            </div>
            <div class="gobierto-dashboards-table-header--elements gobierto-dashboards-table--secondlevel-elements gobierto-dashboards-table-color-inhabitant">
              <span>{{ cost_per_habitant | money }}</span>
            </div>
            <div class="gobierto-dashboards-table-header--elements gobierto-dashboards-table--secondlevel-elements gobierto-dashboards-table-color-income">
              <span>{{ ingressos | money }}</span>
            </div>
            <div class="gobierto-dashboards-table-header--elements gobierto-dashboards-table--secondlevel-elements gobierto-dashboards-table-color-coverage">
              <span>{{ (respecte_ambit).toFixed(0) }}%</span>
            </div>
          </div>
        </div>
      </template>
    </div>
  </div>
</template>
<script>
import TableHeader from './TableHeader.vue'
import TableSubHeader from './TableSubHeader.vue'
import { VueFiltersMixin } from "lib/shared"

export default {
  name: "TableSecondLevel",
  mixins: [VueFiltersMixin],
  components: {
    TableHeader,
    TableSubHeader
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
      labelActivities: I18n.t("gobierto_dashboards.dashboards.costs.activities") || "",
      labelSeeAll: I18n.t("gobierto_dashboards.dashboards.costs.see_all") || "",
      dataActIntermediaTotal: [],
      items: this.$root.$data.costData,
      theadData: [],
      selectedToggle: null,
    }
  },
  created() {
    this.intermediaData()
    this.theadData = [ this.labelCostDirect, this.labelCostIndirect, this.labelTotal, this.labelCostInhabitant, this.labelIncome, this.labelCoverage]
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
