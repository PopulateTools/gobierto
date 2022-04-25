<template>
  <div>
    <div class="pure-g gutters m_b_4">
      <p>Debts</p>
    </div>
    <Table :data="evolutionDebtData" />
  </div>
</template>
<script>

import { EventBus } from "../../lib/mixins/event_bus";
import Table from './Table.vue'
export default {
  name: 'Home',
  components: {
    Table
  },
  data() {
    return {
      debtsData: this.$root.$data.debtsData,
      creditorData: [],
      evolutionDebtData: [],
    }
  },
  mounted() {
    EventBus.$emit("mounted");
  },
  created() {
    this.creditorData = this.debtsData[0]
    this.evolutionDebtData = this.debtsData[2]
  }
}
</script>
