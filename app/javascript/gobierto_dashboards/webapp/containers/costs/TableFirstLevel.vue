<template>
  <table class="gobierto-dashboards-table">
    <tbody>
      <tr
        v-for="{ agrupacio, cost_directe_2018, cost_indirecte_2018, cost_total_2018, cost_per_habitant, ingressos, respecte_ambit, ordre_agrupacio } in groupData"
        :key="agrupacio"
        class="gobierto-dashboards-tablerow--header"
      >
        <td class="gobierto-dashboards-table-header--nav">
          <router-link
            :to="{ name: 'TableSecondLevel', params: { id: ordre_agrupacio } }"
            class="gobierto-dashboards-table-header--link"
          >
            {{ agrupacio }}
          </router-link>
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
        <td class="gobierto-dashboards-table-header--elements gobierto-dashboards-table-color-coverage">
          <span>{{ respecte_ambit.toFixed(0) }} %</span>
        </td>
      </tr>
    </tbody>
  </table>
</template>
<script>
import { VueFiltersMixin } from "lib/shared"
export default {
  name: "TableFirstLevel",
  mixins: [VueFiltersMixin],
  props: {
    items: {
      type: Array,
      default: () => []
    }
  },
  computed: {
    groupData() {
      //reduce to sum all values for agrupacio
      let dataGroup = []
      dataGroup = [...this.items.reduce((r, o) => {
        const key = o.agrupacio

        const item = r.get(key) || Object.assign({}, o, {
          cost_directe_2018: 0,
          cost_indirecte_2018: 0,
          cost_total_2018: 0,
          ingressos: 0,
          respecte_ambit: 0,
          total: 0
        });

        item.cost_directe_2018 += o.cost_directe_2018
        item.cost_indirecte_2018 += o.cost_indirecte_2018
        item.cost_total_2018 += o.cost_total_2018
        item.ingressos += o.ingressos
        //New item with the sum of values of each agrupacio
        item.total += (o.total || 0) + 1
        item.respecte_ambit += o.respecte_ambit

        return r.set(key, item);
      }, new Map).values()];
      dataGroup = dataGroup.filter(element => element.agrupacio !== '')
      return dataGroup
    },
  }
}
</script>
