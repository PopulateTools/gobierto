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
    this.items = this.contractsData.slice(0, 50);
    this.columns = contractsColumns;
  }
}
</script>
