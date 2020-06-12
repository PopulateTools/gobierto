<template>
  <div>
    <TableHeader />
    <table class="gobierto-dashboards-table">
      <tbody>
        <tr
          v-for="{ agrupacio, cost_directe, cost_indirecte, cost_total, cost_per_habitant, ingressos, coverage, ordre_agrupacio, totalPerHabitant, year } in itemsFilter"
          :key="agrupacio"
          class="gobierto-dashboards-tablerow--header"
        >
          <td class="gobierto-dashboards-table-header--nav">
            <router-link
              :to="{ name: 'TableSecondLevel', params: { id: ordre_agrupacio, year: year, description: agrupacio } }"
              class="gobierto-dashboards-table-header--link"
              @click.native="loadTable"
            >
              {{ agrupacio }}
            </router-link>
          </td>
          <td class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-direct">
            <span>{{ cost_directe | money }}</span>
          </td>
          <td class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-indirect">
            <span>{{ cost_indirecte | money }}</span>
          </td>
          <td class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-total">
            <span>{{ cost_total | money }}</span>
          </td>
          <td class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-inhabitant">
            <span>{{ totalPerHabitant | money }}</span>
          </td>
          <td class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-income">
            <span>{{ ingressos | money }}</span>
          </td>
          <td class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-coverage">
            <span>{{ (coverage).toFixed(0) }} %</span>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
<script>
import TableHeader from './TableHeader.vue'
import { VueFiltersMixin } from "lib/shared"
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
  methods: {
    loadTable() {
      this.$emit('changeTableHandler', 1)
    }
  }
}
</script>
