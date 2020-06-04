<template>
  <main class="gobierto-dashboards">
    <div
      v-if="dataGroup"
      class="pure-g gutters m_b_1"
    >
      <Distribution :data="dataGroup" />
      <Detail :items="dataGroup" />
    </div>
  </main>
</template>
<script>
import Distribution from './Distribution.vue'
import Detail from './Detail.vue'
export default {
  name: 'Home',
  components: {
    Distribution,
    Detail
  },
  data() {
    return {
      costData: this.$root.$data.costData,
      dataGroup: []
    }
  },
  created() {
    this.groupData()
  },
  methods: {
    groupData() {
      //reduce to sum all values for agrupacio
      this.dataGroup = [...this.costData.reduce((r, o) => {
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
      this.dataGroup = this.dataGroup.filter(element => element.agrupacio !== '')
    }
  }
}

</script>
