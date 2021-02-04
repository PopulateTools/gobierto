<template>
  <Table
    :data="items"
    :order-column="'beneficiary'"
    :columns="subsidiesColumns"
    :show-columns="showColumns"
    :on-row-click="goesToItem"
    class="gobierto-table-margin-top"
  />
</template>

<script>
import { Table } from "lib/vue-components";
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
      this.items = this.subsidiesData
    });
    EventBus.$on('filtered-items', (value) => this.updateFilteredItems(value))

    this.items = this.subsidiesData
    this.columns = subsidiesColumns;
    this.showColumns = ['beneficiary', 'amount', 'grant_date']
  },
  beforeDestroy(){
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
    },
    updateShowColumns(values) {
      this.showColumns = values
    },
    goesToItem(item) {
      const { id: routingId } = item
      this.$router.push({ name: 'subsidies_show', params: { id: routingId } })
    }
  }
}
</script>
