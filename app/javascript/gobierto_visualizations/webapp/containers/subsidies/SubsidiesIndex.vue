<template>
  <Table
    :data="items"
    :sort-column="'call'"
    :columns="subsidiesColumns"
    :show-columns="showColumns"
    class="gobierto-table-margin-top"
    @on-href-click="goesToTableItem"
  />
</template>

<script>
import { Table } from '../../../../lib/vue/components';
import { EventBus } from '../../lib/mixins/event_bus';
import { subsidiesColumns } from '../../lib/config/subsidies.js';

export default {
  name: 'SubsidiesIndex',
  components: {
    Table
  },
  data() {
    return {
      subsidiesData: this.$root.$data.subsidiesData,
      items: [],
      value: '',
      subsidiesColumns: subsidiesColumns,
      showColumns: []
    }
  },
  watch: {
    subsidiesData(newValue, oldValue) {
      if (oldValue !== newValue) {
        this.updateFilteredItems(this.value)
      }
    }
  },
  created() {
    EventBus.$on('refresh-summary-data', () => {
      this.subsidiesData = this.$root.$data.subsidiesData
      this.items = this.subsidiesData.map(d => ({ ...d, href: `${location.origin}${location.pathname}/${d.id}` } ))
    });
    EventBus.$on('filtered-items', (value) => this.updateFilteredItems(value))

    this.items = this.subsidiesData.map(d => ({ ...d, href: `${location.origin}${location.pathname}/${d.id}` } ))
    this.columns = subsidiesColumns;
    this.showColumns = ['beneficiary', 'call','amount', 'grant_date']
  },
  beforeUnmount(){
    EventBus.$off('refresh-summary-data');
  },
  methods: {
    updateFilteredItems(value) {
      this.value = value
      if (!this.value) {
        this.items = this.subsidiesData.filter(({ beneficiary = "" }) => beneficiary.toLowerCase().includes(this.value.toLowerCase()))
      } else {
        this.items = this.subsidiesData.filter(({ beneficiary = "" }) => beneficiary.toLowerCase().includes(this.value.toLowerCase())).slice(0, 25)
      }
      this.items = this.items.map(d => ({ ...d, href: `${location.origin}${location.pathname}/${d.id}` } ))
    },
    goesToTableItem(item) {
      const { id: routingId } = item
      this.$router.push({ name: 'subsidies_show', params: { id: routingId } })
    }
  }
}
</script>
