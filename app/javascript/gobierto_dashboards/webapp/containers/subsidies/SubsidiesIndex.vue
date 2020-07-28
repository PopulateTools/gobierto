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
      items: [],
      value: ''
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
  },
  beforeDestroy(){
    EventBus.$off('refresh-summary-data');
  },
  methods: {
    updateFilteredItems(value) {
      this.value = value
      if (this.value === '') {
        this.items = this.subsidiesData.filter(contract => contract.beneficiary_name.toLowerCase().includes(this.value.toLowerCase()))
      } else {
        this.items = this.subsidiesData.filter(contract => contract.beneficiary_name.toLowerCase().includes(this.value.toLowerCase())).slice(0, 25)
      }
    }
  }
}
</script>
