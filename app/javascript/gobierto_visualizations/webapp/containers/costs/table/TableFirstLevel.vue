<template>
  <div>
    <TableHeader />
    <table class="gobierto-visualizations-table gobierto-visualizations-table-first-level">
      <tbody>
        <tr
          v-for="{ agrupacio, costdirecte, costindirecte, costtotal, costperhabit, ingressos, coverage, ordreagrup, totalPerHabitant, any_ } in itemsFilter"
          :key="agrupacio"
          class="gobierto-visualizations-tablerow--header"
        >
          <td class="gobierto-visualizations-table-header--nav">
            <router-link
              :to="{ name: 'TableSecondLevel', params: { id: ordreagrup, year: any_, description: agrupacio } }"
              class="gobierto-visualizations-table-header--link"
              @click.native="loadTable"
            >
              {{ agrupacio }}
            </router-link>
          </td>
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
          <td
            :data-th="labelCostInhabitant"
            class="gobierto-visualizations-table-header--elements gobierto-visualizations-table-color-inhabitant"
          >
            <span>{{ totalPerHabitant | money }}</span>
          </td>
          <td
            :data-th="labelCostIncome"
            class="gobierto-visualizations-table-header--elements gobierto-visualizations-table-color-income"
          >
            <span>{{ ingressos | money }}</span>
          </td>
          <td
            :data-th="labelCostCoverage"
            class="gobierto-visualizations-table-header--elements gobierto-visualizations-table-color-coverage"
          >
            <span>{{ coverageDecimals(coverage) }} %</span>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script>
import TableHeader from './TableHeader.vue'
import { VueFiltersMixin } from '../../../../../lib/vue/filters'

export default {
  name: "TableFirstLevel",
  components: {
    TableHeader
  },
  mixins: [VueFiltersMixin],
  props: {
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
      labelCostDirect: I18n.t("gobierto_visualizations.visualizations.costs.cost_direct") || "",
      labelCostIndirect: I18n.t("gobierto_visualizations.visualizations.costs.cost_indirect") || "",
      labelCostTotal: I18n.t("gobierto_visualizations.visualizations.costs.total") || "",
      labelCostInhabitant: I18n.t("gobierto_visualizations.visualizations.costs.cost_inhabitant") || "",
      labelCostIncome: I18n.t("gobierto_visualizations.visualizations.costs.income") || "",
      labelCostCoverage: I18n.t("gobierto_visualizations.visualizations.costs.coverage") || "",
    }
  },
  methods: {
    loadTable() {
      this.$emit('change-table-handler', 1)
    },
    coverageDecimals(value) {
      return value === 0 ? value.toFixed(0) : value.toFixed(2)
    }
  }
}
</script>
