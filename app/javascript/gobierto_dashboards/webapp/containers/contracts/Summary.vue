<template>
  <div>
    <TreeMap />
    <BeesWarmChart
      v-if="dataBeesWarm"
      :data="dataBeesWarm"
      :height="600"
      :radius-property="'initial_amount_no_taxes'"
      :scale-x-property="'start_date'"
      :scale-y-property="'contract_type'"
      @showTooltip="showTooltip"
      @goesToItem="goesToItem"
    />
    <MultipleLineChart
      v-if="dataLineChart"
      :data="dataLineChart"
      :height="600"
      :array-line-values="valuesForLineChart"
      :array-circle-values="valuesForCircleChart"
      :show-right-labels="false"
      :values-legend="valuesLegendObject"
    />
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
import { BeesWarmChart, MultipleLineChart } from "lib/vue-components";
import TreeMap from "../../visualizations/treeMap.vue";
import { getDataMixin } from "../../lib/getData";
import Table from "../../components/Table.vue";
import { dashboardsMixins } from "../../mixins/dashboards_mixins";
import { assigneesColumns } from "../../lib/config/contracts.js";
import { select } from 'd3-selection'

const d3 = { select }

export default {
  name: 'Summary',
  components: {
    Table,
    TreeMap,
    BeesWarmChart,
    MultipleLineChart
  },
  mixins: [dashboardsMixins, getDataMixin],
  data(){
    return {
      dashboardsData: this.$root.$data.contractsData,
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
      queryBeesWarmChart:"?sql=SELECT EXTRACT(YEAR FROM start_date), initial_amount_no_taxes, final_amount_no_taxes, contract_type, id, assignee, start_date FROM contratos WHERE contract_type != 'Patrimonial'",
      queryLineChart: "?sql=SELECT final_amount_no_taxes, status, initial_amount_no_taxes, start_date FROM contratos WHERE contract_type != 'Patrimonial'",
      dataBeesWarm: undefined,
      dataLineChart: undefined,
      valuesForLineChart: undefined,
      valuesForCircleChart: undefined
    }
  },
  async created() {
    this.columns = assigneesColumns;
    const { data: { data: dataBeesWarm } } = await this.getData(this.queryBeesWarmChart)
    this.dataBeesWarm = dataBeesWarm

    const { data: { data: dataLineChart } } = await this.getData(this.queryLineChart)
    this.transformDataContractsLine(dataLineChart)

  },
  methods: {
    transformDataContractsLine(data) {
      data.forEach(d => {
        d.final_amount_no_taxes = +d.final_amount_no_taxes
        d.initial_amount_no_taxes = +d.initial_amount_no_taxes
        //Calculate percentage median between initial amount and final amount to obtain the difference.
        d.year = new Date(d.start_date).getFullYear()

        if (d.status === "Formalizado" || d.status === "Adjudicado") {
          d.formalized = 1
        } else {
          d.formalized = 0
        }

        if (d.status === "Desierto") {
          d.anulled = 1
        } else {
          d.anulled = 0
        }

        if (d.final_amount_no_taxes === 0) {
          d.formalized = 0
          d.anulled = 1
        }
      })

      //JS convert null years to 1970
      data = data.filter(({ year }) => year !== 1970 && year !== 2021)

      let dataFormalizeContracts = data.filter(({ formalized }) => formalized === 1)
      dataFormalizeContracts.forEach(d => {
        d.percentage_total = Math.abs(((d.final_amount_no_taxes - d.initial_amount_no_taxes) / d.initial_amount_no_taxes) * 100)
      })
      //We need to group and sum by year and value
      const finalAmountTotal = this.sumDataByGroupKey(data, 'year', 'final_amount_no_taxes')
      const formalizedTotal = this.sumDataByGroupKey(data, 'year', 'formalized')
      const anulledTotal = this.sumDataByGroupKey(data, 'year', 'anulled')
      const initialAmountTotal = this.sumDataByGroupKey(data, 'year', 'initial_amount_no_taxes')
      const percentageTotal = this.sumDataByGroupKey(dataFormalizeContracts, 'year', 'percentage_total')

      //Create a new object with the sum of the properties
      let dataContractsLine = finalAmountTotal.map((item, i) => Object.assign({}, item, initialAmountTotal[i], percentageTotal[i], formalizedTotal[i], anulledTotal[i]));

      dataContractsLine.forEach(d => {
        //Get the total of contracts
        d.total_contracts = (d.anulled + d.formalized)

        d.percentage_year = (d.percentage_total / d.total_contracts)
      })

      this.dataLineChart = dataContractsLine

      //Values for build lines in the chart
      this.valuesForLineChart = ['formalized', 'percentage_year', 'total_contracts']

      this.valuesLegendObject = [{
        key: 'formalized',
        legend:'<span class="first-row">${d[value]} ADJUDICACIONES</span><span class="second-row">por importe de ${localeFormat((d["final_amount_no_taxes"] / 1000000))}M</span>'
      },
      {
        key: 'total_contracts',
        legend:'<span class="title">EN LO QUE VA DE 2020</span><span class="first-row">${d[value]} LICITACIONES</span><span class="second-row">por importe de ${localeFormat((d["initial_amount_no_taxes"] / 1000000))}M</span>'
      },
      {
        key: 'percentage_year',
        legend:'<span class="first-row">% DIFERENCIA IMPORTE </span><span class="first-row">LICITACIÓN/adjudicación</span><span class="second-row">${d["percentage_year"].toFixed(0)}%</span>'
      }
      ]
      //Values for build circles in the chart
      this.valuesForCircleChart = ['formalized', 'total_contracts']
    },
    sumDataByGroupKey(data, group, value) {
      let counts = data.reduce((prev, curr) => {
        let count = prev.get(curr[group]) || 0;
        prev.set(curr[group], curr[value] + count);
        return prev;
      }, new Map());

      let reducedArray = [...counts].map(([key, val]) => {
        return { [group]: key, [value]: val }
      })

      return reducedArray
    },
    showTooltip(event) {

      const { assignee, final_amount_no_taxes, initial_amount_no_taxes, x, y } = event
      const tooltip = d3.select('.beeswarm-tooltip')

      tooltip
        .style("display", "block")
        .style('left', `${x}px`)
        .style('top', `${y}px`)
        .html(`
          <span class="beeswarm-tooltip-header-title">
            ${assignee}
          </span>
          <div class="beeswarm-tooltip-table-element">
            <span class="beeswarm-tooltip-table-element-text">
              Importe inicial:
            </span>
            <span class="beeswarm-tooltip-table-element-text">
              ${initial_amount_no_taxes}
            </span>
          </div>
          <div class="beeswarm-tooltip-table-element">
            <span class="beeswarm-tooltip-table-element-text">
              Importe final:
            </span>
            <span class="beeswarm-tooltip-table-element-text">
              ${final_amount_no_taxes}
            </span>
          </div>
        `)
    },
    goesToItem(d) {
      const { id } = d
      this.$router.push(`adjudicaciones/${id}`).catch(err => {})
    },
    refreshSummaryData() {
      if (!this.value) {
        this.dashboardsData = this.$root.$data.contractsData;
      } else {
        this.dashboardsData = this.$root.$data.contractsData.filter(contract => contract.assignee.toLowerCase().includes(this.value.toLowerCase()))
      }
      this.items = this.buildItems();
    },
    buildItems() {
      const groupedByAssignee = {}
      // Group contracts by assignee
      this.dashboardsData.forEach(({ assignee, assignee_routing_id, final_amount_no_taxes }) => {
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
