<template>
  <div>
    <div
      v-for="{ agrupacio, cost_directe_2018, cost_indirecte_2018, cost_total_2018, cost_per_habitant, ingressos, respecte_ambit, total } in groupData" :key="agrupacio"
      class="gobierto-dashboards-table--header gobierto-dashboards-tablerow--header"
    >
      <div class="gobierto-dashboards-table-header--nav">
        <router-link
          :to="{ name: 'TableSecondLevel', params: { items: items, id: agrupacio} }"
          class="gobierto-dashboards-table-header--link"
        >
          {{ agrupacio }}
        </router-link>
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
  </div>
</template>
<script>
import { money } from 'lib/shared'
export default {
  name: "TableFirstLevel",
  props: {
    items: {
      type: Array,
      default: () => []
    }
  },
  computed: {
    groupData() {
      let dataGroup = [...this.items.reduce((r, o) => {
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
      dataGroup = dataGroup.filter(element => element.agrupacio !== '')
      return dataGroup
    },

  }
}
</script>
