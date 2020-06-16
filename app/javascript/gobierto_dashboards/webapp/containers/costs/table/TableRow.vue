<template>
  <table
    class="gobierto-dashboards-table"
    :class="{'gobierto-dashboards-table--subheader': blueHeader }"
  >
    <template v-for="{ nomact, codiact, cost_directe, cost_indirecte, cost_total, total, index, cost_per_habitant, ingressos, act_intermedia, agrupacio, ordre_agrupacio, totalPerHabitant, year } in items">
      <tr
        :key="nomact"
        class="gobierto-dashboards-tablerow--header"
        :class="{'act-has-children': hasChildren(total), 'gobierto-dashboards-tablesecondlevel--header': blueHeader }"
      >
        <template v-if="total > 0 && !tableHeader">
          <td
            class="gobierto-dashboards-table-header--nav"
            @click="handleToggle(act_intermedia)"
          >
            <span class="gobierto-dashboards-table-header--nav-text">{{ nomact }}</span>
            <span>({{ total }} {{ labelActivities }})</span>
          </td>
        </template>
        <template v-else-if="tableHeader">
          <td class="gobierto-dashboards-table-header--nav">
            <span class="gobierto-dashboards-table-header--nav-text">{{ agrupacio }}</span>
          </td>
        </template>
        <template v-else-if="tableItem">
          <td class="gobierto-dashboards-table-header--nav">
            <span class="gobierto-dashboards-table-header--nav-text">{{ nomact }}</span>
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
        <td
          :data-th="labelCostDirect"
          class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-direct"
        >
          <span>{{ cost_directe | money }}</span>
        </td>
        <td
          :data-th="labelCostIndirect"
          class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-indirect"
        >
          <span>{{ cost_indirecte | money }}</span>
        </td>
        <td
          :data-th="labelCostTotal"
          class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-total"
        >
          <span>{{ cost_total | money }}</span>
        </td>
        <template v-if="total > 0">
          <td
            :data-th="labelCostInhabitant"
            class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-inhabitant"
          >
            <span>{{ totalPerHabitant | money }}</span>
          </td>
        </template>
        <template v-else>
          <td
            :data-th="labelCostInhabitant"
            class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-inhabitant"
          >
            <span>{{ cost_per_habitant | money }}</span>
          </td>
        </template>
        <td
          :data-th="labelIncome"
          class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-income"
        >
          <span>{{ ingressos | money }}</span>
        </td>
        <td
          :data-th="labelCoverage"
          class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-coverage"
        >
          <span>{{ calculateCoverage(ingressos, cost_total) }}%</span>
        </td>
      </tr>
      <template v-if="showChildren && selectedToggle === act_intermedia">
        <tbody
          :key="codiact"
          class="gobierto-dashboards-table--secondlevel gobierto-dashboards-table--secondlevel-nested"
        >
          <tr
            v-for="{ nomact, codiact, cost_directe, cost_indirecte, cost_total, total, index, cost_per_habitant, ingressos, coverage, agrupacio, ordre_agrupacio, year } in subItems"
            :key="codiact"
            class="gobierto-dashboards-tablerow--header"
          >
            <td class="gobierto-dashboards-table--secondlevel-elements gobierto-dashboards-table-header--nav">
              <router-link
                :to="{ name: 'TableItem', params: { item: codiact, id: ordre_agrupacio, section: agrupacio, year: year, description: nomact } }"
                class="gobierto-dashboards-table-header--link"
                tag="a"
                @click="loadTable(2)"
              >
                <span class="gobierto-dashboards-table-header--nav-text">{{ nomact }}</span>
              </router-link>
            </td>
            <td
              :data-th="labelCostDirect"
              class="gobierto-dashboards-table-header--elements gobierto-dashboards-table--secondlevel-elements gobierto-dashboards-table-color-direct"
            >
              <span>{{ cost_directe | money }}</span>
            </td>
            <td
              :data-th="labelCostIndirect"
              class="gobierto-dashboards-table-header--elements gobierto-dashboards-table--secondlevel-elements gobierto-dashboards-table-color-indirect"
            >
              <span>{{ cost_indirecte | money }}</span>
            </td>
            <td
              :data-th="labelCostTotal"
              class="gobierto-dashboards-table-header--elements gobierto-dashboards-table--secondlevel-elements gobierto-dashboards-table-color-total"
            >
              <span>{{ cost_total | money }}</span>
            </td>
            <td
              :data-th="labelCostInhabitant"
              class="gobierto-dashboards-table-header--elements gobierto-dashboards-table--secondlevel-elements gobierto-dashboards-table-color-inhabitant"
            >
              <span>{{ cost_per_habitant | money }}</span>
            </td>
            <td
              :data-th="labelIncome"
              class="gobierto-dashboards-table-header--elements gobierto-dashboards-table--secondlevel-elements gobierto-dashboards-table-color-income"
            >
              <span>{{ ingressos | money }}</span>
            </td>
            <td
              :data-th="labelCoverage"
              class="gobierto-dashboards-table-header--elements gobierto-dashboards-table--secondlevel-elements gobierto-dashboards-table-color-coverage"
            >
              <span>{{ calculateCoverage(ingressos, cost_total) }}%</span>
            </td>
          </tr>
        </tbody>
      </template>
    </template>
  </table>
</template>
<script>
import { VueFiltersMixin } from "lib/shared"
export default {
  name: "TableRow",
  mixins: [VueFiltersMixin],
  props: {
    items: {
      type: Array,
      default: () => []
    },
    subItems: {
      type: Array,
      default: () => []
    },
    totalItems: {
      type: Number,
      default: 0
    },
    tableHeader: {
      type: Boolean,
      default: false
    },
    tableItem: {
      type: Boolean,
      default: false
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
      selectedToggle: null,
      valueActIntermedia: null
    }
  },
  computed: {
    showChildren() {
      return this.totalItems > 0 && this.selectedToggle !== null
    },
    blueHeader() {
      return this.tableHeader || this.tableItem
    }
  },
  methods: {
    hasChildren(value) {
      if (value > 0) {
        return true
      }
    },
    handleToggle(item) {
      if (this.selectedToggle !== item){
        this.selectedToggle = item
      } else {
        this.selectedToggle = ''
      }
      this.valueActIntermedia = this.selectedToggle
      this.$emit('filterChildren', this.selectedToggle)
    },
    loadTable(value) {
      this.$emit('loadTable', value)
    },
    calculateCoverage(income, cost) {
      return ((income * 100) / cost).toFixed(0)
    }
  }
}
</script>
