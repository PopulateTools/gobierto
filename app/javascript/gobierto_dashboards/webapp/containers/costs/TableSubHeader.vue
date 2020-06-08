<template>
  <table class="gobierto-dashboards-table gobierto-dashboards-table--subheader">
    <tbody>
      <tr
        v-for="{ agrupacio, cost_directe_2018, cost_indirecte_2018, cost_total_2018, cost_per_habitant, ingressos, respecte_ambit } in dataGroup"
        :key="agrupacio"
        class="gobierto-dashboards-tablerow--header gobierto-dashboards-tablesecondlevel--header"
      >
        <td class="gobierto-dashboards-table-header--nav">
          <span>{{ agrupacio }}</span>
        </td>
        <td class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-direct">
          <span>{{ cost_directe_2018 | money }}</span>
        </td>
        <td class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-indirect">
          <span>{{ cost_indirecte_2018 | money }}</span>
        </td>
        <td class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-total">
          <span>{{ cost_total_2018 | money }}</span>
        </td>
        <td class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-inhabitant">
          <span>{{ cost_per_habitant | money }}</span>
        </td>
        <td class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-income">
          <span>{{ ingressos | money }}</span>
        </td>
        <td class="gobierto-dashboards-table-header--elements">
          <span>{{ (respecte_ambit).toFixed(0) }}%</span>
        </td>
      </tr>
    </tbody>
  </table>
</template>
<script>
import { VueFiltersMixin } from "lib/shared"
export default {
  name: "TableSubHeader",
  mixins: [VueFiltersMixin],
  data() {
    return {
      dataGroup: [],
      groupData: this.$root.$data.agrupacioData
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
      this.dataGroup = this.groupData.filter(element => element.ordre_agrupacio === id)
    }
  }
}
</script>
