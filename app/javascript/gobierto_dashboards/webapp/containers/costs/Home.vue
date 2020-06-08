<template>
  <main class="gobierto-dashboards">
    <div class="pure-g gutters m_b_1">
      <Header />
      <Distribution :data="costData" />
      <Table :data="costData" />
    </div>
  </main>
</template>

<script>
import Header from './Header.vue'
import Distribution from './Distribution.vue'
import Table from './Table.vue'
export default {
  name: 'Home',
  components: {
    Header,
    Distribution,
    Table
  },
  data() {
    return {
      costData: this.$root.$data.costData
    }
  }
}
</script>
