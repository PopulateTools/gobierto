<template>
  <table
    class="gobierto-visualizations-table"
    :class="{'gobierto-visualizations-table--subheader': blueHeader }"
  >
    <template v-for="{ nomact, codiact, costdirecte, costindirecte, costtotal, total, index, costperhabit, ingressos, actintermitja, agrupacio, ordreagrup, totalPerHabitant, any_ } in items">
      <tr
        :key="nomact"
        class="gobierto-visualizations-tablerow--header"
        :class="{'act-has-children': hasChildren(total), 'gobierto-visualizations-tablesecondlevel--header': blueHeader }"
      >
        <template v-if="total > 0 && !tableHeader">
          <td
            class="gobierto-visualizations-table-header--nav"
            @click="handleToggle(actintermitja)"
          >
            <div class="gobierto-visualizations-table-header--nav-has-children">
              <span class="gobierto-visualizations-table-header--nav-text">{{ nomact }}</span>
              <span class="gobierto-visualizations-table-header--nav-text-total">({{ total }} {{ labelActivities }})</span>
            </div>
          </td>
        </template>
        <template v-else-if="tableHeader">
          <td class="gobierto-visualizations-table-header--nav">
            <span class="gobierto-visualizations-table-header--nav-text">{{ agrupacio }}</span>
          </td>
        </template>
        <template v-else-if="tableItem">
          <td class="gobierto-visualizations-table-header--nav">
            <span class="gobierto-visualizations-table-header--nav-text">{{ nomact }}</span>
          </td>
        </template>
        <template v-else>
          <td class="gobierto-visualizations-table-header--nav">
            <router-link
              :to="{ name: 'TableItem', params: { item: codiact, id: ordreagrup, section: agrupacio, year: any_, description: nomact } }"
              class="gobierto-visualizations-table-header--link"
              tag="a"
              @click.native="loadTable(2)"
            >
              <span class="gobierto-visualizations-table-header--nav-text">{{ nomact }}</span>
            </router-link>
          </td>
        </template>
        <td
          :data-th="labelCostDirect"
          class="gobierto-visualizations-table-header--elements gobierto-visualizations-table-color-direct"
        >
          <span>{{ costdirecte | money }}</span>
        </td>
        <td
          :data-th="labelCostIndirect"
          class="gobierto-visualizations-table-header--elements gobierto-visualizations-table-color-indirect"
        >
          <span>{{ costindirecte | money }}</span>
        </td>
        <td
          :data-th="labelCostTotal"
          class="gobierto-visualizations-table-header--elements gobierto-visualizations-table-color-total"
        >
          <span>{{ costtotal | money }}</span>
        </td>
        <template v-if="total > 0">
          <td
            :data-th="labelCostInhabitant"
            class="gobierto-visualizations-table-header--elements gobierto-visualizations-table-color-inhabitant"
          >
            <span>{{ totalPerHabitant | money }}</span>
          </td>
        </template>
        <template v-else>
          <td
            :data-th="labelCostInhabitant"
            class="gobierto-visualizations-table-header--elements gobierto-visualizations-table-color-inhabitant"
          >
            <span>{{ costperhabit | money }}</span>
          </td>
        </template>
        <td
          :data-th="labelIncome"
          class="gobierto-visualizations-table-header--elements gobierto-visualizations-table-color-income"
        >
          <span>{{ ingressos | money }}</span>
        </td>
        <td
          :data-th="labelCoverage"
          class="gobierto-visualizations-table-header--elements gobierto-visualizations-table-color-coverage"
        >
          <span>{{ calculateCoverage(ingressos, costtotal) }}%</span>
        </td>
      </tr>
      <template v-if="showChildren && selectedToggle === actintermitja">
        <tbody
          :key="codiact"
          class="gobierto-visualizations-table--secondlevel gobierto-visualizations-table--secondlevel-nested"
        >
          <tr
            v-for="{ nomact, codiact, costdirecte, costindirecte, costtotal, total, index, costperhabit, ingressos, coverage, agrupacio, ordreagrup, any_ } in subItems"
            :key="codiact"
            class="gobierto-visualizations-tablerow--header"
          >
            <td class="gobierto-visualizations-table--secondlevel-elements gobierto-visualizations-table-header--nav">
              <router-link
                :to="{ name: 'TableItem', params: { item: codiact, id: ordreagrup, section: agrupacio, year: any_, description: nomact } }"
                class="gobierto-visualizations-table-header--link"
                tag="a"
                @click="loadTable(2)"
              >
                <span class="gobierto-visualizations-table-header--nav-text">{{ nomact }}</span>
              </router-link>
            </td>
            <td
              :data-th="labelCostDirect"
              class="gobierto-visualizations-table-header--elements gobierto-visualizations-table--secondlevel-elements gobierto-visualizations-table-color-direct"
            >
              <span>{{ costdirecte | money }}</span>
            </td>
            <td
              :data-th="labelCostIndirect"
              class="gobierto-visualizations-table-header--elements gobierto-visualizations-table--secondlevel-elements gobierto-visualizations-table-color-indirect"
            >
              <span>{{ costindirecte | money }}</span>
            </td>
            <td
              :data-th="labelCostTotal"
              class="gobierto-visualizations-table-header--elements gobierto-visualizations-table--secondlevel-elements gobierto-visualizations-table-color-total"
            >
              <span>{{ costtotal | money }}</span>
            </td>
            <td
              :data-th="labelCostInhabitant"
              class="gobierto-visualizations-table-header--elements gobierto-visualizations-table--secondlevel-elements gobierto-visualizations-table-color-inhabitant"
            >
              <span>{{ costperhabit | money }}</span>
            </td>
            <td
              :data-th="labelIncome"
              class="gobierto-visualizations-table-header--elements gobierto-visualizations-table--secondlevel-elements gobierto-visualizations-table-color-income"
            >
              <span>{{ ingressos | money }}</span>
            </td>
            <td
              :data-th="labelCoverage"
              class="gobierto-visualizations-table-header--elements gobierto-visualizations-table--secondlevel-elements gobierto-visualizations-table-color-coverage"
            >
              <span>{{ calculateCoverage(ingressos, costtotal) }}%</span>
            </td>
          </tr>
        </tbody>
      </template>
    </template>
  </table>
</template>
<script>
import { VueFiltersMixin } from '../../../../../lib/vue/filters'

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
      labelTotal: I18n.t("gobierto_visualizations.visualizations.costs.total") || "",
      labelCostPerInhabitant: I18n.t("gobierto_visualizations.visualizations.costs.cost_per_inhabitant") || "",
      labelCostDirect: I18n.t("gobierto_visualizations.visualizations.costs.cost_direct") || "",
      labelCostIndirect: I18n.t("gobierto_visualizations.visualizations.costs.cost_indirect") || "",
      labelCostInhabitant: I18n.t("gobierto_visualizations.visualizations.costs.cost_inhabitant") || "",
      labelCostTotal: I18n.t("gobierto_visualizations.visualizations.costs.total") || "",
      labelIncome: I18n.t("gobierto_visualizations.visualizations.costs.income") || "",
      labelCoverage: I18n.t("gobierto_visualizations.visualizations.costs.coverage") || "",
      labelActivities: I18n.t("gobierto_visualizations.visualizations.costs.activities") || "",
      labelSeeAll: I18n.t("gobierto_visualizations.visualizations.costs.see_all") || "",
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
      this.$emit('filter-children', this.selectedToggle)
    },
    loadTable(value) {
      this.$emit('load-table', value)
    },
    calculateCoverage(income, cost) {
      let coverage = ((income * 100) / cost).toFixed(2)
      coverage = +coverage
      return coverage === 0 ? coverage.toFixed(0) : coverage.toFixed(2)
    }
  }
}
</script>
