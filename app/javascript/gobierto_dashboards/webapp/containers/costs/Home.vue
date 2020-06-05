<template>
  <main class="gobierto-dashboards">
    <div
      v-if="dataGroup"
      class="pure-g gutters m_b_1"
    >
      <Distribution
        :data="dataGroup"
        :year="yearFiltered"
      />
      <Detail
        :items="dataGroup"
        :year="yearFiltered"
      />
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
      dataGroup: [],
      yearFiltered: "2018"
    }
  },
  created() {
    this.onChangeFilterYear(this.yearFiltered)
  },
  methods: {
    onChangeFilterYear(value) {
      let year
      if (value === '2018') {
        year = value
      } else {
        year = value.target.value
        this.yearFiltered = value.target.value
      }
      this.itemsFilterYear = this.costData.filter(element => element.year === year)
      this.groupData()
    },
    groupData() {
      //reduce to sum all values for agrupacio
      this.dataGroup = [...this.itemsFilterYear.reduce((r, o) => {
        const key = o.agrupacio

        const item = r.get(key) || Object.assign({}, o, {
          cost_directe: 0,
          cost_indirecte: 0,
          cost_total: 0,
          ingressos: 0,
          respecte_ambit: 0,
          total: 0,
          totalPerHabitant: 0
        });

        item.cost_directe += o.cost_directe
        item.cost_indirecte += o.cost_indirecte
        item.cost_total += o.cost_total
        item.ingressos += o.ingressos
        //New item with the sum of values of each agrupacio
        item.total += (o.total || 0) + 1
        item.respecte_ambit += o.respecte_ambit
        item.totalPerHabitant = item.cost_total / o.population

        return r.set(key, item);
      }, new Map).values()];
      this.dataGroup = this.dataGroup.filter(element => element.agrupacio !== '')
    }
  }
}

</script>
