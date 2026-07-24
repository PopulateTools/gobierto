<template>
  <Table
    :data="items"
    :sort-column="'final_amount_no_taxes'"
    :sort-direction="'desc'"
    :columns="contractsColumns"
    :show-columns="showColumns"
    :href-builder="rowHref"
    class="gobierto-table-margin-top gobierto-table-scroll"
    @on-href-click="goesToTableItem"
  />
</template>

<script>
import { Table } from '../../../../lib/vue/components';
import { EventBus } from '../../lib/mixins/event_bus';
import { getContractsColumns } from '../../lib/config/contracts.js';

export default {
  name: 'ContractsIndex',
  components: {
    Table
  },
  data() {
    return {
      contractsData: this.$root.$data.contractsData,
      contractsColumns: getContractsColumns(),
      items: [],
      showColumns: [],
      columns: []
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

    // Keep the frozen rows as-is (no per-row href clone); the link is built
    // on demand via rowHref, so Object.freeze keeps working on the full dataset.
    this.items = this.contractsData
    this.columns = getContractsColumns();
    this.showColumns = ['assignee', 'title', 'gobierto_start_date', 'final_amount_no_taxes']
  },
  beforeUnmount(){
    EventBus.$off('refresh-summary-data');
  },
  methods: {
    updateFilteredItems(value) {
      this.value = value || ''
      // Lowercase the query once instead of per row (see SearchFilter).
      const query = this.value.toLowerCase()

      this.items = this.contractsData
        .filter(contract => contract.assignee.toLowerCase().includes(query)
          || contract.title.toLowerCase().includes(query)
          || (contract.document_number || '').toLowerCase().includes(query))
    },
    rowHref(item) {
      return `${location.origin}/visualizaciones/contratos/adjudicaciones/${item.id}`
    },
    goesToTableItem(item) {
      const { id: routingId } = item
      this.$router.push({ name: 'contracts_show', params: { id: routingId } })
    }
  }
}
</script>
