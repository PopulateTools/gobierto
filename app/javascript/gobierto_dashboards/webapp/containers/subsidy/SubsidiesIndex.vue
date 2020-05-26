<template>
  <Table
    :items="items"
    :routing-member="'subsidies_show'"
    :columns="columns"
  >
  </Table>
</template>

<script>
import Table from "../../components/Table.vue";
import { EventBus } from "../../mixins/event_bus";
import { subsidiesColumns } from "../../lib/config.js";

export default {
  name: 'SubsidiesIndex',
  components: {
    Table
  },
  data() {
    return {
      subsidiesData: this.$root.$data.subsidiesData,
      items: []
    }
  },
  created() {
    EventBus.$on('refresh_summary_data', () => {
      this.subsidiesData = this.$root.$data.subsidiesData
      this.items = this.subsidiesData.slice(0, 50);
    });

    this.items = this.subsidiesData.slice(0, 50);
    this.columns = subsidiesColumns;
  }
}
</script>
