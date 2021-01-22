<template>
  <div>
    <Table
      :data="items"
      :order-column="'final_amount_no_taxes'"
      :columns="contractsColumns"
      :show-columns="showColumns"
      @update-show-columns="updateShowColumns"
    >
      <template
        #columns="{ toggleVisibility }"
      >
        <TableColumnsSelector
          :columns="contractsColumns"
          :show-columns="showColumns"
          @toggle-visibility="toggleVisibility"
        />
      </template>
    </Table>
  </div>
</template>

<script>
import { Table, TableColumnsSelector } from "lib/vue-components";
import { EventBus } from "../../mixins/event_bus";
import { contractsColumns } from "../../lib/config/contracts.js";

export default {
  name: 'ContractsIndex',
  components: {
    Table,
    TableColumnsSelector
  },
  data() {
    return {
      contractsData: this.$root.$data.contractsData,
      contractsColumns: contractsColumns,
      tableData: [],
      items: [],
      showColumns: [],
      columns: [],
      allColumns: []
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
    this.showColumns = ['assignee', 'title', 'award_date', 'final_amount_no_taxes']
  },
  beforeDestroy(){
    EventBus.$off('refresh-summary-data');
  },
  methods: {
    updateFilteredItems(value) {
      this.value = value || ''

      this.items = this.contractsData.filter(contract => contract.assignee.toLowerCase().includes(this.value.toLowerCase()) || contract.title.toLowerCase().includes(this.value.toLowerCase()))
    },
    updateShowColumns(values) {
      this.showColumns = values
    }
  }
}
</script>
