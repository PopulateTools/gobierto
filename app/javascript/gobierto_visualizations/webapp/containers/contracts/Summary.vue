<template>
  <div>
    <AssigneesTreeMapNested
      :data="visualizationsData"
    />
    <h3 class="mt4 graph-title">
      {{ labelBeesWarm }}
    </h3>
    <BeesWarmChart
      v-if="dataBeesWarmFilter"
      :data="dataBeesWarmFilter"
      :height="600"
      :radius-property="'final_amount_no_taxes'"
      :x-axis-prop="'start_date'"
      :y-axis-prop="'contract_type'"
      @showTooltip="showTooltipBeesWarm"
      @goesToItem="goesToItem"
    />
    <h3 class="mt4 graph-title">
      {{ labelMultipleLine }}
    </h3>
    <MultipleLineChart
      v-if="dataLineChart"
      :data="dataLineChart"
      :height="350"
      :array-line-values="valuesForLineChart"
      :array-circle-values="valuesForCircleChart"
      :show-right-labels="true"
      :values-legend="valuesLegendObject"
      @showTooltip="showTooltipMultipleLine"
    />
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
import AssigneesTreeMapNested from "./AssigneesTreeMapNested.vue";
import Table from "../../components/Table.vue";
import { visualizationsMixins } from "../../mixins/visualizations_mixins";
import { assigneesColumns } from "../../lib/config/contracts.js";
import { select, mouse } from 'd3-selection'
import { timeParse } from 'd3-time-format';
import { getQueryData, sumDataByGroupKey } from "../../lib/utils";
import { money } from "lib/shared";

const d3 = { select, mouse, timeParse }

export default {
  name: 'Summary',
  components: {
    Table,
    BeesWarmChart,
    MultipleLineChart,
    AssigneesTreeMapNested
  },
  mixins: [visualizationsMixins],
  data(){
    return {
      visualizationsData: this.$root.$data.contractsData,
      items: [],
      columns: [],
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
      labelTooltipBeesWarm: I18n.t('gobierto_visualizations.visualizations.visualizations.tooltip_beeswarm'),
      labelMultipleLine: I18n.t('gobierto_visualizations.visualizations.visualizations.title_multiple'),
      queryLineChart: "?sql=SELECT final_amount_no_taxes, status, initial_amount_no_taxes, start_date FROM contratos WHERE contract_type != 'Patrimonial'",
      dataBeesWarm: undefined,
      dataBeesWarmFilter: undefined,
      dataLineChart: undefined,
      valuesForLineChart: undefined,
      valuesForCircleChart: undefined
    }
  },
  watch: {
    visualizationsData(newValue, oldValue) {
      if (newValue !== oldValue) {
        this.updateDataBeesWarm(newValue)
      }
    }
  },
  async created() {
    this.columns = assigneesColumns;
    this.dataBeesWarmFilter = JSON.parse(JSON.stringify(this.visualizationsData));

    const { data: { data: dataLineChart } } = await getQueryData(this.queryLineChart)
    this.transformDataContractsLine(dataLineChart)
  },
  methods: {
    updateDataBeesWarm(data){
      const dataBeesWarm = JSON.parse(JSON.stringify(data));
      this.dataBeesWarmFilter = dataBeesWarm
    },
    transformDataContractsLine(data) {
      const parseTime = d3.timeParse('%Y');
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
      const NEXT_YEAR = new Date().getFullYear() + 1
      data = data.filter(({ year }) => year !== 1970 && year !== NEXT_YEAR)

      let dataFormalizeContracts = data.filter(({ formalized }) => formalized === 1)
      dataFormalizeContracts.forEach(d => {
        d.percentage_total = d.initial_amount_no_taxes > 0 ? Math.abs(((d.final_amount_no_taxes - d.initial_amount_no_taxes) / d.initial_amount_no_taxes) * 100) : ''
      })
      //We need to group and sum by year and value
      const finalAmountTotal = sumDataByGroupKey(data, 'year', 'final_amount_no_taxes')
      const formalizedTotal = sumDataByGroupKey(data, 'year', 'formalized')
      const anulledTotal = sumDataByGroupKey(data, 'year', 'anulled')
      const initialAmountTotal = sumDataByGroupKey(data, 'year', 'initial_amount_no_taxes')
      const percentageTotal = sumDataByGroupKey(dataFormalizeContracts, 'year', 'percentage_total')

      //Create a new object with the sum of the properties
      let dataContractsLine = finalAmountTotal.map((item, i) => Object.assign({}, item, initialAmountTotal[i], percentageTotal[i], formalizedTotal[i], anulledTotal[i]));

      dataContractsLine.forEach(d => {
        //Get the total of contracts
        d.total_contracts = (d.anulled + d.formalized)

        d.percentage_year = d.total_contracts ? (d.percentage_total / d.total_contracts) : 0

        d.year = parseTime(d.year)
      })

      this.dataLineChart = dataContractsLine

      //Values for build lines in the chart
      this.valuesForLineChart = ['formalized', 'percentage_year', 'total_contracts']

      this.valuesLegendObject = [
      {
        key: 'total_contracts',
        legend:'<span class="title">${I18n.t("gobierto_visualizations.visualizations.visualizations.title_legend")}</span><span class="first-row">${d[value]} ${I18n.t("gobierto_visualizations.visualizations.contracts.summary.tenders")}</span><span class="second-row">${I18n.t("gobierto_visualizations.visualizations.visualizations.by_amount")} ${localeFormat((d["initial_amount_no_taxes"] / 1000000))}M</span>'
      },
      {
        key: 'formalized',
        legend:'<span class="first-row">${d[value]} ${I18n.t("gobierto_visualizations.visualizations.visualizations.contracts")}</span><span class="second-row">${I18n.t("gobierto_visualizations.visualizations.visualizations.by_amount")} ${localeFormat((d["final_amount_no_taxes"] / 1000000))}M</span>'
      },
      {
        key: 'percentage_year',
        legend:'<span class="first-row">% ${I18n.t("gobierto_visualizations.visualizations.visualizations.difference_import")} </span><span class="first-row">${I18n.t("gobierto_visualizations.visualizations.contracts.summary.tenders")}/${I18n.t("gobierto_visualizations.visualizations.visualizations.contracts")}</span><span class="second-row">${d["percentage_year"].toFixed(0)}%</span>'
      }
      ]
      //Values for build circles in the chart
      const valuesForCircleChart = ['formalized', 'total_contracts']
      this.valuesForCircleChart = valuesForCircleChart
    },
    showTooltipMultipleLine(d, e, event) {
      const { total_contracts, formalized, final_amount_no_taxes, year } = d
      const getRect = event[e]
      const x = getRect.getBBox().x
      const y = getRect.getBBox().y
      const tooltip = d3.select('.multiple-line-tooltip-bars')
      const container = document.getElementsByClassName('multiple-line-chart-container')[0];
      const containerWidth = container.offsetWidth
      const tooltipWidth = 300
      const positionWidthTooltip = x + tooltipWidth
      const positionTop = `${y - 20}px`
      const positionLeft = `${x + 10}px`
      const positionRight = `${x - tooltipWidth - 30}px`

      tooltip
        .style("display", "block")
        .style('top', positionTop)
        .style('left', positionWidthTooltip > containerWidth ? positionRight : positionLeft)
        .html(`
          <span class="beeswarm-tooltip-header-title">
            ${year.getFullYear()}
          </span>
          <span class="multiple-line-tooltip-bars-text">Total de licitaciones: <b>${total_contracts}</b></span>
          <span class="multiple-line-tooltip-bars-text">Total de adjudicaciones: <b>${formalized}</b></span>
          <span class="multiple-line-tooltip-bars-text">Importe total de las adjudicaciones: <b>${money(final_amount_no_taxes)}</b></span>
        `)

    },
    showTooltipBeesWarm(event) {
      const { assignee, final_amount_no_taxes } = event
      const tooltip = d3.select('.beeswarm-tooltip')

      const positionTop = '-10'
      const positionLeft = '110'

      tooltip
        .style("display", "block")
        .style('top', `${positionTop}px`)
        .style('left', `${positionLeft}px`)
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
      this.$router.push(`adjudicaciones/${id}`).catch(err => {})
    },
    refreshSummaryData() {
      if (!this.value) {
        this.visualizationsData = this.$root.$data.contractsData;
      } else {
        this.visualizationsData = this.$root.$data.contractsData.filter(contract => contract.assignee.toLowerCase().includes(this.value.toLowerCase()))
      }
      this.items = this.buildItems();
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
    }
  }
}
</script>
