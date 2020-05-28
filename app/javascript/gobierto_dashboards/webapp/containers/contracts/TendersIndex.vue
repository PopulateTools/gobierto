<template>
  <Table
    :items="items"
    :routing-member="'tenders_show'"
    :columns="columns"
  >
  </Table>
</template>

<script>
import Table from "../../components/Table.vue";
import { tendersColumns } from "../../lib/config/contracts.js";

export default {
  name: 'TendersIndex',
  components: {
    Table
  },
  data() {
    return {
      tendersData: this.$root.$data.tendersData,
      items: []
    }
  },
  created() {
    this.items = this.tendersData.slice(0, 50);
    this.columns = tendersColumns;
  }
}
</script>
