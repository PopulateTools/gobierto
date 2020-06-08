<template>
  <main class="gobierto-dashboards">
    <div class="pure-g gutters m_b_1">
      <Distribution
        :data="groupDataFilter"
        :year="yearFiltered"
      />
      <Table
        :items-filter="groupDataFilter"
        :items="costDataFilter"
        :year="yearFiltered"
      />
    </div>
  </main>
</template>
<script>
import Distribution from './Distribution.vue'
import Table from './table/Table.vue'
export default {
  name: 'Home',
  components: {
    Distribution,
    Table
  },
  data() {
    return {
      costData: this.$root.$data.costData,
      groupData: this.$root.$data.groupData,
      yearFiltered: "2018",
      costDataFilter: [],
      groupDataFilter: []
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
      this.costDataFilter = this.costData.filter(element => element.year === year)
      this.groupDataFilter = this.groupData.filter(element => element.year === year)
    },
  }
}

</script>
