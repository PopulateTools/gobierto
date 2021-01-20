<template>
  <div>
    <Table
      :data="tableData"
      :visibility-columns="showColumns"
      :order-column="'award_date'"
      :columns="columns"
      @updateShowColumns="updateShowColumns"
    >
      <template
        #columns="{ toggleVisibility }"
      >
        <TableColumnsSelector
          :data="tableData"
          :visibility-columns="showColumns"
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
      tableData: [],
      items: [],
      showColumns: [],
      columns: {}
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
    this.createTypesForTable()
    this.showColumns = ['assignee', 'award_date', 'final_amount_no_taxes']
  },
  beforeDestroy(){
    EventBus.$off('refresh-summary-data');
  },
  methods: {
    updateFilteredItems(value) {
      this.value = value || ''

      this.items = this.contractsData.filter(contract => contract.assignee.toLowerCase().includes(this.value.toLowerCase()) || contract.title.toLowerCase().includes(this.value.toLowerCase()))
    },
    createTypesForTable() {
      const typesLinks = ['id', 'permalink']
      const typesDates = ['award_date', 'end_date', 'open_proposals_date', 'submission_date', 'start_date']
      const typesMoney = ['final_amount', 'final_amount_no_taxes', 'initial_amount_no_taxes', 'initial_amount']
      this.tableData = JSON.parse(JSON.stringify(this.contractsData));
      this.tableData.forEach(contract => {
        Object.keys(contract).forEach((key) => {
          if (typesLinks.includes(key)) {
            contract.[key] = {
              "type": "link",
              "cssClass": "table-th-link",
              "value": contract[key]
            }
          }

          if (typesDates.includes(key)) {
            contract.[key] = {
              "type": "date",
              "cssClass": "table-th-date",
              "value": contract[key] || ''
            }
          }

          if (typesMoney.includes(key)) {
            contract.[key] = {
              "type": "money",
              "cssClass": "table-th-money",
              "value": +contract[key]
            }
          }
        })
      })
    },
    updateShowColumns(value) {
      this.showColumns = value
    }
  }
}
</script>
