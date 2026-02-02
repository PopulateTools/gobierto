<template>
  <Table
    :data="items"
    :sort-column="'final_amount_no_taxes'"
    :sort-direction="'desc'"
    :columns="contractsColumns"
    :show-columns="showColumns"
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

    this.items = this.contractsData.map(d => ({ ...d, href: `${location.origin}${location.pathname}/${d.id}` } ))
    this.columns = getContractsColumns();
    this.showColumns = ['assignee', 'title', 'gobierto_start_date', 'final_amount_no_taxes']
  },
  beforeUnmount(){
    EventBus.$off('refresh-summary-data');
  },
  methods: {
    updateFilteredItems(value) {
      this.value = value || ''

      this.items = this.contractsData
        .filter(contract => contract.assignee.toLowerCase()
        .includes(this.value.toLowerCase()) || contract.title.toLowerCase()
        .includes(this.value.toLowerCase()))
        .map(d => ({ ...d, href: `${location.origin}/visualizaciones/contratos/adjudicaciones/${d.id}` } ))
    },
    goesToTableItem(item) {
      const { id: routingId } = item
      this.$router.push({ name: 'contracts_show', params: { id: routingId } })
    }
  }
}
</script>
