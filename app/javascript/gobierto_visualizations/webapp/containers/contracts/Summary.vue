<template>
  <div>
    <CategoriesTreeMapNested
      v-if="activeTab === 0"
      id="gobierto-visualizations-treemap-categories"
      :data="visualizationsDataExcludeNoCategory"
    />
    <EntityTreeMapNested
      v-if="activeTab === 0"
      id="gobierto-visualizations-treemap-entity"
      :data="visualizationsDataEntity"
      class="mt4"
    />
    <div id="gobierto-visualizations-beeswarm">
      <h3 class="mt4 graph-title">
        {{ labelBeesWarm }}
      </h3>
      <BeesWarmChart
        v-if="activeTab === 0"
        :data="visualizationsDataExcludeMinorContract"
        :radius-property="'final_amount_no_taxes'"
        :x-axis-prop="'gobierto_start_date'"
        :y-axis-prop="'contract_type'"
        @showTooltip="showTooltipBeesWarm"
        @goesToItem="goesToItem"
      />
    </div>
    <div
      id="tendersContractsSummary"
      class="metric_boxes mt4"
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
          <div id="contract-type-bars" />
        </div>

        <div>
          <h3 class="mt1 graph-title">
            {{ labelProcessType }}
          </h3>
          <div id="process-type-bars" />
        </div>
      </div>

      <div class="pure-u-1 pure-u-lg-1-2 header_block_inline">
        <div>
          <h3 class="mt1 graph-title">
            {{ labelAmountDistribution }}
          </h3>
          <div id="amount-distribution-bars" />
        </div>
      </div>
    </div>

    <div class="m_t_4">
      <h3 class="mt1 graph-title">
        {{ labelMainAssignees }}
      </h3>
      <Table
        :data="tableItems"
        :order-column="'count'"
        :columns="assigneesColumns"
        :show-columns="showColumns"
        class="gobierto-table-margin-top"
        @on-href-click="goesToTableItem"
      />
    </div>
  </div>
</template>
<script>
import { BeesWarmChart, Table } from "lib/vue/components";
import CategoriesTreeMapNested from "./CategoriesTreeMapNested.vue";
import EntityTreeMapNested from "./EntityTreeMapNested.vue";
import { visualizationsMixins } from "../../mixins/visualizations_mixins";
import { assigneesColumns } from "../../lib/config/contracts.js";
import { select, mouse } from 'd3-selection'
import { timeParse } from 'd3-time-format';
import { money } from "lib/vue/filters";

const d3 = { select, mouse, timeParse }

export default {
  name: 'Summary',
  components: {
    Table,
    BeesWarmChart,
    CategoriesTreeMapNested,
    EntityTreeMapNested
  },
  mixins: [visualizationsMixins],
  props: {
    activeTab: {
      type: Number,
      default: 0
    }
  },
  data(){
    return {
      visualizationsData: this.$root.$data.contractsData,
      assigneesColumns: assigneesColumns,
      items: [],
      tableItems: [],
      columns: [],
      showColumns: [],
      value: '',
      labelTenders: I18n.t('gobierto_visualizations.visualizations.contracts.summary.tenders'),
      labelTendersFor: I18n.t('gobierto_visualizations.visualizations.contracts.summary.tenders_for'),
      labelContracts: I18n.t('gobierto_visualizations.visualizations.contracts.summary.contracts'),
      labelContractsFor: I18n.t('gobierto_visualizations.visualizations.contracts.summary.contracts_for'),
      labelMeanAmount: I18n.t('gobierto_visualizations.visualizations.contracts.summary.mean_amount'),
      labelMedianAmount: I18n.t('gobierto_visualizations.visualizations.contracts.summary.median_amount'),
      labelMeanSavings: I18n.t('gobierto_visualizations.visualizations.contracts.summary.mean_savings'),
      labelLessThan1000_1: I18n.t('gobierto_visualizations.visualizations.contracts.summary.label_less_than_1000_1'),
      labelLessThan1000_2: I18n.t('gobierto_visualizations.visualizations.contracts.summary.label_less_than_1000_2'),
      labelLargerContractAmount_1: I18n.t('gobierto_visualizations.visualizations.contracts.summary.label_larger_contract_amount_1'),
      labelLargerContractAmount_2: I18n.t('gobierto_visualizations.visualizations.contracts.summary.label_larger_contract_amount_2'),
      labelHalfSpendingsContracts_1: I18n.t('gobierto_visualizations.visualizations.contracts.summary.label_half_spendings_contracts_1'),
      labelHalfSpendingsContracts_2: I18n.t('gobierto_visualizations.visualizations.contracts.summary.label_half_spendings_contracts_2'),
      labelContractType: I18n.t('gobierto_visualizations.visualizations.contracts.contract_type'),
      labelProcessType: I18n.t('gobierto_visualizations.visualizations.contracts.process_type'),
      labelAmountDistribution: I18n.t('gobierto_visualizations.visualizations.contracts.amount_distribution'),
      labelMainAssignees: I18n.t('gobierto_visualizations.visualizations.contracts.main_assignees'),
      labelBeesWarm: I18n.t('gobierto_visualizations.visualizations.visualizations.title_beeswarm'),
      labelTooltipBeesWarm: I18n.t('gobierto_visualizations.visualizations.visualizations.tooltip_beeswarm')
    }
  },
  computed: {
    visualizationsDataExcludeNoCategory() {
      return this.visualizationsData
        .filter(({ category_id }) => !!category_id)
        .map(d => ({ ...d, href: `${location.origin}${location.pathname}${d.assignee_routing_id}` } ))
    },
    visualizationsDataExcludeMinorContract() {
      return this.visualizationsData
        .filter(({ minor_contract: minor }) => minor === 'f')
        .map(d => ({ ...d, href: `${location.origin}${location.pathname}${d.assignee_routing_id}` } ))
    },
    visualizationsDataEntity() {
      return this.visualizationsData
        .map(d => ({ ...d, href: `${location.origin}${location.pathname}${d.assignee_routing_id}` } ))
    }
  },
  created() {
    this.columns = assigneesColumns;
    this.showColumns = ['count', 'name', 'sum']
    this.tableItems = this.items.map(d => ({ ...d, href: `${location.origin}${location.pathname}${d.assignee_routing_id}` } ))
  },
  methods: {
    showTooltipBeesWarm(event) {
      const { assignee, final_amount_no_taxes, y } = event
      const tooltip = d3.select('.beeswarm-tooltip')

      const positionTop = `${y}px`
      const positionLeft = '0px'

      tooltip
        .style("opacity", 0)
        .transition()
        .duration(400)
        .style("opacity", 1)

      tooltip
        .style('top', positionTop)
        .style('left', positionLeft)
        .html(`
          <span class="beeswarm-tooltip-header-title">
            ${assignee}
          </span>
          <div class="beeswarm-tooltip-table-element">
            <span class="beeswarm-tooltip-table-element-text">
              ${this.labelTooltipBeesWarm}:
            </span>
            <span class="beeswarm-tooltip-table-element-text">
               <b>${money(final_amount_no_taxes)}</b>
            </span>
          </div>
        `)
    },
    goesToItem(event) {
      const { id } = event
      // eslint-disable-next-line no-unused-vars
      this.$router.push(`/visualizaciones/contratos/adjudicaciones/${id}`).catch(err => {})
    },
    refreshSummaryData() {
      if (!this.value) {
        this.visualizationsData = this.$root.$data.contractsData;
      } else {
        this.visualizationsData = this.$root.$data.contractsData.filter(contract => contract.assignee.toLowerCase().includes(this.value.toLowerCase()))
      }
      this.items = this.buildItems();
      this.tableItems = this.items.map(d => ({ ...d, href: `${location.origin}${location.pathname}${d.assignee_routing_id}` } ))
    },
    buildItems() {
      const groupedByAssignee = {}
      // Group contracts by assignee
      this.visualizationsData.forEach(({ assignee, assignee_routing_id, final_amount_no_taxes }) => {
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
    },
    goesToTableItem(item) {
      const { assignee_routing_id: routingId } = item
      this.$router.push({ name: 'assignees_show', params: { id: routingId } })
    }
  }
}
</script>
