<template>
  <Table
    :items="items"
    :routing-member="'contracts_show'"
    :columns="columns"
  />
</template>

<script>
import Table from "../../components/Table.vue";
import { EventBus } from "../../mixins/event_bus";
import { contractsColumns } from "../../lib/config/contracts.js";

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
  watch: {
    contractsData(newValue, oldValue) {
      if (oldValue !== newValue) {
        this.updateFilteredItems(this.value)
      }
    }
  },
  created() {
    EventBus.$on('refresh-summary-data', () => {
      this.contractsData = this.$root.$data.contractsData
      this.items = this.contractsData
    });

    EventBus.$on('filtered-items', (value) => this.updateFilteredItems(value))

    this.items = this.contractsData
    this.columns = contractsColumns;
  },
  beforeDestroy(){
    EventBus.$off('refresh-summary-data');
  },
  methods: {
    updateFilteredItems(value) {
      this.value = value
      if (!this.value) {
        this.value = ''
      }
      this.items = this.contractsData.filter(contract => contract.assignee.toLowerCase().includes(this.value.toLowerCase()) || contract.title.toLowerCase().includes(this.value.toLowerCase()))
    }
  }
}
</script>
