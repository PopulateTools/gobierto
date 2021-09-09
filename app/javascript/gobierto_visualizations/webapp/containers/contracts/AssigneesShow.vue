<template>
  <div>
    <div class="pure-g p_2 bg-gray">
      <div class="pure-u-1 pure-u-lg-1-2">
        <label class="soft">{{ labelContractsAsignedTo }}</label>
        <div class="">
          <strong class="d_block">{{ assignee }}</strong>
          <span v-if="assignee_id">
            {{ assignee_id }}
          </span>
        </div>
      </div>
    </div>

    <div class="m_t_4">
      <Table
        :data="tableItems"
        :sort-column="'title'"
        :columns="assigneesShowColumns"
        :show-columns="showColumns"
        @on-href-click="goesToTableItem"
      />
    </div>
  </div>
</template>

<script>
import { VueFiltersMixin } from "lib/vue/filters"
import { Table } from "lib/vue/components";
import { EventBus } from "../../lib/mixins/event_bus";
import { assigneesShowColumns } from "../../lib/config/contracts.js";

export default {
  name: 'AssigneesShow',
  components: {
    Table
  },
  mixins: [VueFiltersMixin],
  data() {
    return {
      contractsData: this.$root.$data.contractsData,
      assigneesShowColumns: assigneesShowColumns,
      items: [],
      tableItems: [],
      columns: [],
      showColumns: [],
      labelContractsAsignedTo: I18n.t('gobierto_visualizations.visualizations.contracts.contracts_assigned_to'),
    }
  },
  created() {
    EventBus.$on('refresh-summary-data', () => {
      this.contractsData = this.$root.$data.contractsData
      this.buildItems()
    });

    EventBus.$emit("refresh-active-tab");

    this.buildItems();
    this.showColumns = ['title', 'final_amount_no_taxes', 'gobierto_start_date',]
  },
  methods: {
    buildItems(){
      const assigneeRoutingId = this.$route.params.id;
      const contracts = this.contractsData.filter(({ assignee_routing_id }) => assignee_routing_id === assigneeRoutingId ) || [];

      this.items = contracts
      this.columns = assigneesShowColumns;
      this.tableItems = this.items.map(d => ({ ...d, href: `${location.origin}/visualizaciones/contratos/adjudicaciones/${d.id}` } ))

      if (contracts.length > 0) {
        const contract = contracts[0]
        this.assignee = contract.assignee
        this.assignee_id = contract.assignee_id
      }
    },
    goesToTableItem(item) {
      const { id: routingId } = item
      this.$router.push({ name: 'contracts_show', params: { id: routingId } })
    }
  }
}
</script>
