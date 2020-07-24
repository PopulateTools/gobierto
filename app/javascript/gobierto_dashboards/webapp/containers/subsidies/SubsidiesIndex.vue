<template>
  <Table
    :items="items"
    :routing-member="'subsidies_show'"
    :columns="columns"
  />
</template>

<script>
import Table from "../../components/Table.vue";
import { EventBus } from "../../mixins/event_bus";
import { subsidiesColumns } from "../../lib/config/subsidies.js";

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
    EventBus.$on('refresh-summary-data', () => {
      this.subsidiesData = this.$root.$data.subsidiesData
      this.items = this.subsidiesData.slice(0, 50);
    });
    EventBus.$on('filtered-items-subsidies', (data) => {
      /*this.items = data.filter(item => item.year === '2019')*/
    })

    this.items = this.subsidiesData.slice(0, 50);
    this.columns = subsidiesColumns;
  },
  beforeDestroy(){
    EventBus.$off('refresh-summary-data');
  }
}
</script>
