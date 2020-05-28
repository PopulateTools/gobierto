<template>
  <Table
    :items="items"
    :routing-member="'contracts_show'"
    :columns="columns"
  >
  </Table>
</template>

<script>
import Table from "../../components/Table.vue";
import { EventBus } from "../../mixins/event_bus";
import { contractsColumns } from "../../lib/config.js";

export default {
  name: 'ContractsIndex',
  components: {
    Table
  },
  data() {
    return {
      contractsData: this.$root.$data.contractsData,
      items: []
    }
  },
  created() {
    EventBus.$on('refresh_summary_data', () => {
      this.contractsData = this.$root.$data.contractsData
      this.items = this.contractsData.slice(0, 50);
    });

    this.items = this.contractsData.slice(0, 50);
    this.columns = contractsColumns;
  },
  beforeDestroy(){
    EventBus.$off('refresh_summary_data');
  }
}
</script>
