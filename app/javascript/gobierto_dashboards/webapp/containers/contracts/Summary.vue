<template>
  <div>
    <div
      id="tendersContractsSummary"
      class="metric_boxes"
    >
      <div class="metric_box">
        <div class="inner nomargin ">
          <div class="pure-g p_1">
            <div class="pure-u-1 pure-u-lg-1-3">
              <h3>{{ labelTenders }}</h3>

              <div class="metric m_b_1">
                <span id="number-tenders" />
              </div>
              <p class="m_t_0">
                {{ labelTendersFor }}
              </p>
              <div class="metric m_b_1">
                <small><span id="sum-tenders" /></small>
              </div>

              <div class="pure-g">
                <div class="pure-u-1-2 explanation explanation--relative">
                  {{ labelMeanAmount }}
                  <strong class="d_block"><span id="mean-tenders" /></strong>
                </div>

                <div class="pure-u-1-2 explanation explanation--relative">
                  {{ labelMedianAmount }}
                  <strong class="d_block"><span id="median-tenders" /></strong>
                </div>
              </div>
            </div> <!-- tenders block -->

            <div class="pure-u-1 pure-u-lg-2-3">
              <h3>{{ labelContracts }}</h3>

              <div class="metric m_b_1">
                <span id="number-contracts" />
              </div>
              <div class="pure-g">
                <div class="pure-u-1-2">
                  <p class="m_t_0">
                    {{ labelContractsFor }}
                  </p>
                  <div class="metric m_b_1">
                    <small><span id="sum-contracts" /></small>
                  </div>

                  <div class="pure-g">
                    <div class="pure-u-1-2 explanation explanation--relative">
                      {{ labelMeanAmount }}
                      <strong class="d_block">
                        <span id="mean-contracts" />
                      </strong>
                    </div>

                    <div class="pure-u-1-2 explanation explanation--relative">
                      {{ labelMedianAmount }}
                      <strong class="d_block">
                        <span id="median-contracts" />
                      </strong>
                    </div>
                  </div>
                </div>
              </div>
            </div> <!-- contracts -->
          </div>
        </div>
      </div> <!-- metric_box -->
    </div> <!-- metrix_boxes -->

    <div
      id="dccharts"
      class="pure-g block m_b_3"
    >
      <div class="pure-u-1 pure-u-lg-1-3 p_h_r_3 header_block_inline">
        <p class="decorator">
          {{ labelLessThan1000_1 }}<strong><span id="less-than-1000-pct" /></strong>{{ labelLessThan1000_2 }}<strong>1.000 €</strong>
        </p>
      </div>

      <div class="pure-u-1 pure-u-lg-1-3 p_h_r_3 header_block_inline">
        <p class="decorator">
          {{ labelLargerContractAmount_1 }}<strong><span id="larger-contract-amount-pct" /></strong>{{ labelLargerContractAmount_2 }}
        </p>
      </div>

      <div class="pure-u-1 pure-u-lg-1-3 p_h_r_3 header_block_inline">
        <p class="decorator">
          {{ labelHalfSpendingsContracts_1 }}<strong><span id="half-spendings-contracts-pct" /></strong>{{ labelHalfSpendingsContracts_2 }}
        </p>
      </div>
    </div>

    <div class="pure-g block">
      <div class="pure-u-1 pure-u-lg-1-2 p_h_r_3">
        <div class="m_b_3">
          <h3 class="mt1 graph-title">
            {{ labelContractType }}
          </h3>
          <div id="contract-type-bars"></div>
        </div>

        <div>
          <h3 class="mt1 graph-title">
            {{ labelProcessType }}
          </h3>
          <div id="process-type-bars"></div>
        </div>
      </div>

      <div class="pure-u-1 pure-u-lg-1-2 header_block_inline">
        <div>
          <h3 class="mt1 graph-title">
            {{ labelAmountDistribution }}
          </h3>
          <div id="amount-distribution-bars"></div>
        </div>
        <div>
          <div
            id="date-bars"
            class="hidden"
          >
          </div>
        </div>
      </div>
    </div>

    <div class="m_t_4">
      <h3 class="mt1 graph-title">
        {{ labelMainAssignees }}
      </h3>
      <Table
        :items="items"
        :columns="columns"
        :routing-member="'assignees_show'"
        :routing-attribute="'assignee_routing_id'"
      />
    </div>
  </div>
</template>

<script>
import Table from "../../components/Table.vue";
import { EventBus } from "../../mixins/event_bus";
import { assigneesColumns } from "../../lib/config/contracts.js";

export default {
  name: 'Summary',
  components: {
    Table
  },
  data(){
    return {
      contractsData: this.$root.$data.contractsData,
      items: [],
      columns: [],
      value: '',
      labelTenders: I18n.t('gobierto_dashboards.dashboards.contracts.summary.tenders'),
      labelTendersFor: I18n.t('gobierto_dashboards.dashboards.contracts.summary.tenders_for'),
      labelContracts: I18n.t('gobierto_dashboards.dashboards.contracts.summary.contracts'),
      labelContractsFor: I18n.t('gobierto_dashboards.dashboards.contracts.summary.contracts_for'),
      labelMeanAmount: I18n.t('gobierto_dashboards.dashboards.contracts.summary.mean_amount'),
      labelMedianAmount: I18n.t('gobierto_dashboards.dashboards.contracts.summary.median_amount'),
      labelMeanSavings: I18n.t('gobierto_dashboards.dashboards.contracts.summary.mean_savings'),
      labelLessThan1000_1: I18n.t('gobierto_dashboards.dashboards.contracts.summary.label_less_than_1000_1'),
      labelLessThan1000_2: I18n.t('gobierto_dashboards.dashboards.contracts.summary.label_less_than_1000_2'),
      labelLargerContractAmount_1: I18n.t('gobierto_dashboards.dashboards.contracts.summary.label_larger_contract_amount_1'),
      labelLargerContractAmount_2: I18n.t('gobierto_dashboards.dashboards.contracts.summary.label_larger_contract_amount_2'),
      labelHalfSpendingsContracts_1: I18n.t('gobierto_dashboards.dashboards.contracts.summary.label_half_spendings_contracts_1'),
      labelHalfSpendingsContracts_2: I18n.t('gobierto_dashboards.dashboards.contracts.summary.label_half_spendings_contracts_2'),
      labelContractType: I18n.t('gobierto_dashboards.dashboards.contracts.contract_type'),
      labelProcessType: I18n.t('gobierto_dashboards.dashboards.contracts.process_type'),
      labelAmountDistribution: I18n.t('gobierto_dashboards.dashboards.contracts.amount_distribution'),
      labelMainAssignees: I18n.t('gobierto_dashboards.dashboards.contracts.main_assignees'),
    }
  },

  mounted() {
    EventBus.$on('refresh-summary-data', () => {
      this.refreshSummaryData();
    });

    EventBus.$emit("summary-ready");
  },
  created() {
    this.items = this.buildItems();
    this.columns = assigneesColumns;

    EventBus.$on('filtered-items-grouped', (data, value) => this.updateItems(data, value))
  },
  beforeDestroy(){
    EventBus.$off('refresh-summary-data');
  },
  methods: {
    updateItems(data, value) {
      this.value = value
      this.contractsData = data
      this.items = this.buildItems();

      EventBus.$emit('send-filtered-items', this.items)
    },
    refreshSummaryData() {
      if (!this.value) {
        this.contractsData = this.$root.$data.contractsData;
      } else {
        this.contractsData = this.$root.$data.contractsData.filter(contract => contract.assignee.toLowerCase().includes(this.value.toLowerCase()))
      }
      this.items = this.buildItems();
    },
    buildItems() {
      const groupedByAssignee = {}
      // Group contracts by assignee
      this.contractsData.forEach(({ assignee, assignee_routing_id, final_amount_no_taxes }) => {
        if (assignee === '' || assignee === undefined) {
          return;
        }

        if (groupedByAssignee[assignee] === undefined) {
          groupedByAssignee[assignee] = {
            name: assignee,
            assignee_routing_id: assignee_routing_id,
            sum: 0,
            count: 0
          }
        }

        groupedByAssignee[assignee].sum += parseFloat(final_amount_no_taxes)
        groupedByAssignee[assignee].count++;
      });


      // Sort grouped elements by number of contracts
      const sortedAndGrouped = Object.values(groupedByAssignee).sort((a, b) => { return a.count < b.count ? 1 : -1 });

      // The id must be unique so when data changes vue knows how to refresh the table accordingly.
      sortedAndGrouped.forEach(contract => contract.id = `${contract.name}-${contract.count}`)

      return sortedAndGrouped.slice(0, 30);
    }
  }
}
</script>
