<template>
  <div>
    <Table
      :items="items"
      :routing-member="'tenders_show'"
      :columns="columns"
    />
  </div>
</template>

<script>
import ContractsShow from "./TendersShow.vue";
import Table from "../../components/Table.vue";

export default {
  name: 'TendersIndex',
  components: {
    ContractsShow,
    Table
  },
  data() {
    return {
      tendersData: this.$root.$data.tendersData,
      items: [],
      columns: [
        {field: 'contractor', translation: I18n.t('gobierto_dashboards.dashboards.contracts.contractor'), format: null},
        {field: 'status', translation: I18n.t('gobierto_dashboards.dashboards.contracts.status'), format: null},
        {field: 'submission_date', translation: I18n.t('gobierto_dashboards.dashboards.contracts.submission_date'), format: null},
      ]
    }
  },
  created() {
    this.items = this.tendersData.slice(0, 50);
  }
}
</script>
