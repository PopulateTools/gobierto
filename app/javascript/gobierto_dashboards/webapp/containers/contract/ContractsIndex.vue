<template>
  <div>
    <Table
      :items="items"
      :routing-member="'contracts_show'"
      :columns="columns"
    />
  </div>
</template>

<script>
import ContractsShow from "./ContractsShow.vue";
import Table from "../../components/Table.vue";

export default {
  name: 'ContractsIndex',
  components: {
    ContractsShow,
    Table
  },
  data() {
    return {
      contractsData: this.$root.$data.contractsData,
      items: [],
      columns: [
        {field: 'assignee', translation: I18n.t('gobierto_dashboards.dashboards.contracts.assignee')},
        {field: 'contractor', translation: I18n.t('gobierto_dashboards.dashboards.contracts.contractor')},
        {field: 'final_amount', translation: I18n.t('gobierto_dashboards.dashboards.contracts.final_amount')},
        {field: 'end_date', translation: I18n.t('gobierto_dashboards.dashboards.contracts.end_date')},
      ]
    }
  },
  created() {
    this.items = this.contractsData.slice(0, 50);
  }
}
</script>
