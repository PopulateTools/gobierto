<template>
  <div>
    <TableHeader>
      <router-link
        :to="{ path:`/dashboards/costes/${$route.params.year}`}"
        class="gobierto-dashboards-table-header--link-top"
        tag="a"
        @click.native="loadTable(0)"
      >
        <i class="fas fa-chevron-left" />
        {{ labelSeeAll }}
      </router-link>
    </TableHeader>
    <TableSubHeader :items="itemsFilter" />
    <table class="gobierto-dashboards-table">
      <template v-for="{ nomact, codiact, cost_directe, cost_indirecte, cost_total, total, index, cost_per_habitant, ingressos, act_intermedia, agrupacio, ordre_agrupacio, totalPerHabitant, year } in dataActIntermediaTotal">
        <tr
          :key="nomact"
          class="gobierto-dashboards-tablerow--header"
          :class="{'act-has-children': hasChildren(total)}"
        >
          <template v-if="total > 0">
            <td
              class="gobierto-dashboards-table-header--nav"
              @click="handleToggle(act_intermedia)"
            >
              <span class="gobierto-dashboards-table-header--nav-text">{{ nomact }}</span>
              <span>({{ total }} {{ labelActivities }})</span>
            </td>
          </template>
          <template v-else>
            <td class="gobierto-dashboards-table-header--nav">
              <router-link
                :to="{ name: 'TableItem', params: { item: codiact, id: ordre_agrupacio, section: agrupacio, year: year, description: nomact } }"
                class="gobierto-dashboards-table-header--link"
                tag="a"
                @click.native="loadTable(2)"
              >
                <span class="gobierto-dashboards-table-header--nav-text">{{ nomact }}</span>
              </router-link>
            </td>
          </template>
          <td :data-th="labelCostDirect" class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-direct">
            <span>{{ cost_directe | money }}</span>
          </td>
          <td :data-th="labelCostIndirect" class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-indirect">
            <span>{{ cost_indirecte | money }}</span>
          </td>
          <td :data-th="labelCostTotal" class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-total">
            <span>{{ cost_total | money }}</span>
          </td>
          <template v-if="total > 0">
            <td :data-th="labelCostInhabitant" class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-inhabitant">
              <span>{{ totalPerHabitant | money }}</span>
            </td>
          </template>
          <template v-else>
            <td :data-th="labelCostInhabitant" class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-inhabitant">
              <span>{{ cost_per_habitant | money }}</span>
            </td>
          </template>
          <td :data-th="labelIncome" class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-income">
            <span>{{ ingressos | money }}</span>
          </td>
          <td :data-th="labelCoverage" class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-coverage">
            <span>{{ ((ingressos * 100) / cost_total).toFixed(0) }}%</span>
          </td>
        </tr>
        <transition
          :key="codiact"
          name="fade"
          mode="out-in"
        >
          <template v-if="total > 0 && selectedToggle === act_intermedia && selectedToggle !== null">
            <tbody
              :key="codiact"
              class="gobierto-dashboards-table--secondlevel gobierto-dashboards-table--secondlevel-nested"
            >
              <tr
                v-for="{ nomact, codiact, cost_directe, cost_indirecte, cost_total, total, index, cost_per_habitant, ingressos, coverage, agrupacio, ordre_agrupacio, year } in dataGroupIntermedia"
                :key="codiact"
                class="gobierto-dashboards-tablerow--header"
              >
                <td class="gobierto-dashboards-table--secondlevel-elements gobierto-dashboards-table-header--nav">
                  <router-link
                    :to="{ name: 'TableItem', params: { item: codiact, id: ordre_agrupacio, section: agrupacio, year: year, description: nomact } }"
                    class="gobierto-dashboards-table-header--link"
                    tag="a"
                    @click.native="loadTable(2)"
                  >
                    <span class="gobierto-dashboards-table-header--nav-text">{{ nomact }}</span>
                  </router-link>
                </td>
                <td :data-th="labelCostDirect" class="gobierto-dashboards-table-header--elements gobierto-dashboards-table--secondlevel-elements gobierto-dashboards-table-color-direct">
                  <span>{{ cost_directe | money }}</span>
                </td>
                <td :data-th="labelCostIndirect" class="gobierto-dashboards-table-header--elements gobierto-dashboards-table--secondlevel-elements gobierto-dashboards-table-color-indirect">
                  <span>{{ cost_indirecte | money }}</span>
                </td>
                <td :data-th="labelCostTotal" class="gobierto-dashboards-table-header--elements gobierto-dashboards-table--secondlevel-elements gobierto-dashboards-table-color-total">
                  <span>{{ cost_total | money }}</span>
                </td>
                <td :data-th="labelCostInhabitant" class="gobierto-dashboards-table-header--elements gobierto-dashboards-table--secondlevel-elements gobierto-dashboards-table-color-inhabitant">
                  <span>{{ cost_per_habitant | money }}</span>
                </td>
                <td :data-th="labelIncome" class="gobierto-dashboards-table-header--elements gobierto-dashboards-table--secondlevel-elements gobierto-dashboards-table-color-income">
                  <span>{{ ingressos | money }}</span>
                </td>
                <td :data-th="labelCoverage" class="gobierto-dashboards-table-header--elements gobierto-dashboards-table--secondlevel-elements gobierto-dashboards-table-color-coverage">
                  <span>{{ ((ingressos * 100) / cost_total).toFixed(0) }}%</span>
                </td>
              </tr>
            </tbody>
          </template>
        </transition>
      </template>
    </table>
  </div>
</template>
<script>
import TableHeader from './TableHeader.vue'
import TableSubHeader from './TableSubHeader.vue'
import { VueFiltersMixin } from "lib/shared"

export default {
  name: "TableSecondLevel",
  components: {
    TableHeader,
    TableSubHeader
  },
  mixins: [VueFiltersMixin],
  props: {
    items: {
      type: Array,
      default: () => []
    },
    itemsFilter: {
      type: Array,
      default: () => []
    },
    year: {
      type: String,
      default: ''
    }
  },
  data() {
    return {
      labelTotal: I18n.t("gobierto_dashboards.dashboards.costs.total") || "",
      labelCostPerInhabitant: I18n.t("gobierto_dashboards.dashboards.costs.cost_per_inhabitant") || "",
      labelCostDirect: I18n.t("gobierto_dashboards.dashboards.costs.cost_direct") || "",
      labelCostIndirect: I18n.t("gobierto_dashboards.dashboards.costs.cost_indirect") || "",
      labelCostInhabitant: I18n.t("gobierto_dashboards.dashboards.costs.cost_inhabitant") || "",
      labelCostTotal: I18n.t("gobierto_dashboards.dashboards.costs.total") || "",
      labelIncome: I18n.t("gobierto_dashboards.dashboards.costs.income") || "",
      labelCoverage: I18n.t("gobierto_dashboards.dashboards.costs.coverage") || "",
      labelActivities: I18n.t("gobierto_dashboards.dashboards.costs.activities") || "",
      labelSeeAll: I18n.t("gobierto_dashboards.dashboards.costs.see_all") || "",
      dataActIntermediaTotal: [],
      selectedToggle: null
    }
  },
  watch: {
    $route(to) {
      if (to.name === 'TableSecondLevel') {
        this.intermediaData()
      }
    }
  },
  created() {
    this.intermediaData()
  },
  mounted() {
    const el = this.$el.getElementsByClassName('gobierto-dashboards-table-header--nav')[0];
    if (el) {
      el.scrollIntoView({ behavior: "smooth" });
    }
  },
  methods: {
    intermediaData() {
      const filterActIntermedia = this.$route.params.id
      let dataAgrupacio = this.items.filter(element => element.ordre_agrupacio === filterActIntermedia)
      let dataActIntermedia = dataAgrupacio.filter(element => element.act_intermedia !== '')
      let dataActIntermediaValues = [...dataActIntermedia.reduce((r, o) => {
        let key = o.act_intermedia

        const item = r.get(key) || Object.assign({}, o, {
          cost_directe: 0,
          cost_indirecte: 0,
          cost_total: 0,
          ingressos: 0,
          total: 0,
          nomact: '',
          totalPerHabitant: 0
        });

        item.cost_directe += o.cost_directe
        item.cost_indirecte += o.cost_indirecte
        item.cost_total += o.cost_total
        item.ingressos += o.ingressos
        item.total += (o.total || 0) + 1
        item.nomact = o.act_intermedia
        item.totalPerHabitant = item.cost_total / o.population

        return r.set(key, item);
      }, new Map).values()];

      const dataActIntermediaWithoutValues = dataAgrupacio.filter(element => element.act_intermedia === '')
      dataActIntermediaValues = dataActIntermediaValues.sort((a, b) => (a.cost_total > b.cost_total) ? -1 : 1)
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
    },
    loadTable(value) {
      this.$emit('changeTableHandler', value)
    }
  }
}
</script>
