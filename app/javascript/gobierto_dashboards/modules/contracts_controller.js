import Vue from "vue";
import VueRouter from "vue-router";

import { sum, mean, median, max } from 'd3-array';
import { scaleThreshold } from 'd3-scale';

const d3 = { scaleThreshold, sum, mean, median, max }

import crossfilter from 'crossfilter2'

import { getRemoteData } from '../webapp/lib/utils'
import { EventBus } from '../webapp/mixins/event_bus'
import { money } from 'lib/shared'

import { AmountDistributionBars } from "lib/visualizations";
import { GroupPctDistributionBars } from "lib/visualizations";

Vue.use(VueRouter);
Vue.config.productionTip = false;

// Global variables
let data, reduced, ndx, _amountRange, vueApp, unfilteredTendersData, charts = {};
const tendersFilters = {submission_date: [], process_type: [], contract_type: [] };

export class ContractsController {
  constructor(options) {
    const selector = "gobierto-dashboards-contracts-app";

    // Mount Vue applications
    const entryPoint = document.getElementById(selector);

    if (entryPoint) {
      const htmlRouterBlock = `<router-view></router-view>`;

      entryPoint.innerHTML = htmlRouterBlock;

      const Home = () => import("../webapp/containers/shared/Home.vue");
      const Summary = () => import("../webapp/containers/summary/Summary.vue");
      const ContractsIndex = () => import("../webapp/containers/contract/ContractsIndex.vue");
      const ContractsShow = () => import("../webapp/containers/contract/ContractsShow.vue");
      const TendersIndex = () => import("../webapp/containers/tender/TendersIndex.vue");
      const TendersShow = () => import("../webapp/containers/tender/TendersShow.vue");

      Promise.all([getRemoteData(options.contractsEndpoint), getRemoteData(options.tendersEndpoint)]).then((rawData) => {
        this.setGlobalVariables(rawData)

        const router = new VueRouter({
          mode: "history",
          routes: [
            { path: "/dashboards/contratos", component: Home, props: {dataDownloadEndpoint: options.dataDownloadEndpoint},
              children: [
                { path: "resumen", name: "summary", component: Summary},
                { path: "contratos", name: "contracts_index", component: ContractsIndex },
                { path: "contratos/:id", name: "contracts_show", component: ContractsShow },
              ]
            }

          ],
          scrollBehavior() {
            const element = document.getElementById(selector);
            window.scrollTo({ top: element.offsetTop, behavior: "smooth" });
          }
        });

        const baseTitle = document.title;
        router.afterEach(to => {
          // Wait 2 ticks
          Vue.nextTick(() =>
            Vue.nextTick(() => {
              let title = baseTitle;

              if (to.name === "contracts_show" || to.name === "tenders_show") {
                const { item: { title: itemTitle } = {} } = to.params;

                if (itemTitle) {
                  title = `${itemTitle}${baseTitle}`;
                }
              }

              document.title = title;
            })
          );
        });

        vueApp = new Vue({
          router,
          data: Object.assign(options, data),
        }).$mount(entryPoint);

        EventBus.$on('summary_ready', () => {
          this._renderSummary();
        });

        EventBus.$on('filter_changed', (options) => {
          this._updateChartsFromFilter(options);
        });

        // - dc charts are drawn even if the summary page is not the page where the user lands for the first time
        //   i.e.: they could first land on a contract page, but still this page would need to render for the filters to work
        // - dc charts sizes are calculated automatically, but if the page is not visible it won't calculate sizes properly
        // - Given all that: when we go from a page that is not summary to summary for the first time, the sizes must
        //   be calculated and the charts redrawn. This is why this event only needs to be listened once.
        EventBus.$once('moved_to_summary', () => {
          this._redrawCharts();
        });
      });
    }
  }

  setGlobalVariables(rawData){
    let contractsData, tendersData;
    [contractsData, tendersData] = rawData;

    const sortByField = (dateField) => {
      return function(a, b){
        const aDate = a[dateField],
              bDate = b[dateField];

        if (aDate == '') {
          return 1;
        }

        if (bDate == '') {
          return -1;
        }

        if ( aDate < bDate ){
          return 1;
        } else if ( aDate > bDate ){
          return -1;
        } else {
          return 0;
        }
      }
    }

    // Contracts precalculations and normalizations
    _amountRange = {
      domain: [501, 1001, 5001, 10001, 15001],
      range: [0, 1, 2, 3, 4, 5]
    };
    var rangeFormat = d3.scaleThreshold().domain(_amountRange.domain).range(_amountRange.range);

    for(let i = 0; i < contractsData.length; i++){
      const contract = contractsData[i];
      const final_amount = (contract.final_amount === '' || contract.final_amount === undefined) ? 0.0 : parseFloat(contract.final_amount);
      const initial_amount = (contract.initial_amount === '' || contract.initial_amount === undefined) ? 0.0 : parseFloat(contract.initial_amount);

      contract.final_amount = final_amount;
      contract.initial_amount = initial_amount;
      contract.range = rangeFormat(+final_amount);
      contract.start_date_year = contract.start_date ? (new Date(contract.start_date).getFullYear()) : contract.start_date;
    }

    for(let i = 0; i < tendersData.length; i++){
      const tender = tendersData[i];
      const initial_amount = (tender.initial_amount === '' || tender.initial_amount === undefined) ? 0.0 : parseFloat(tender.initial_amount);

      tender.initial_amount = initial_amount;
      tender.submission_date_year = tender.submission_date != undefined && tender.submission_date != '' ? (new Date(tender.submission_date).getFullYear()) : tender.submission_date;
      if(tender.submission_date_year) { tender.submission_date_year = tender.submission_date_year.toString() }
    }

    unfilteredTendersData = tendersData.sort(sortByField('submission_date'));

    data = {
      contractsData: this._formalizedContractsData(contractsData).sort(sortByField('start_date')),
      tendersData: unfilteredTendersData,
    }
  }

  _renderSummary(){
    ndx = crossfilter(this._currentDataSource().contractsData);

    this._renderTendersMetricsBox();
    this._renderContractsMetricsBox();

    this._renderByAmountsChart();
    this._renderContractTypeChart();
    this._renderProcessTypeChart();
    this._renderDateChart();
  }

  _refreshData(reducedContractsData, filters, tendersAttribute){
    if (filters) {
      this._refreshTendersDataFromFilters(filters, tendersAttribute);
    }
    reduced = {tendersData: data.tendersData, contractsData: reducedContractsData};

    vueApp.contractsData = reducedContractsData;
    EventBus.$emit('refresh_summary_data');

    this._renderTendersMetricsBox();
    this._renderContractsMetricsBox();
  }

  _renderTendersMetricsBox(){
    const _tendersData = this._currentDataSource().tendersData

    // Calculations
    const amountsArray = _tendersData.map(({initial_amount = 0}) => parseFloat(initial_amount) );

    const numberTenders = _tendersData.length;
    const sumTenders = d3.sum(amountsArray);
    const meanTenders = d3.mean(amountsArray);
    const medianTenders = d3.median(amountsArray);

    // Updating the DOM
    document.getElementById("number-tenders").innerText = numberTenders.toLocaleString();
    document.getElementById("sum-tenders").innerText = money(sumTenders);
    document.getElementById("mean-tenders").innerText = money(meanTenders);
    document.getElementById("median-tenders").innerText = money(medianTenders);
  }

  _renderContractsMetricsBox(){
    const _contractsData = this._currentDataSource().contractsData;

    // Calculations
    const amountsArray = _contractsData.map(({final_amount = 0}) => parseFloat(final_amount) );
    const sortedAmountsArray = amountsArray.sort((a, b) => b - a);

    // Calculations box items
    const numberContracts = _contractsData.length;
    const sumContracts = d3.sum(amountsArray);
    const meanContracts = d3.mean(amountsArray);
    const medianContracts = d3.median(amountsArray);

    // Calculations headlines
    const lessThan1000Total = _contractsData.filter(({final_amount = 0}) => parseFloat(final_amount) < 1000).length;
    const lessThan1000Pct = lessThan1000Total/numberContracts;

    const largerContractAmount = d3.max(_contractsData, ({final_amount = 0}) => parseFloat(final_amount));
    const largerContractAmountPct = largerContractAmount / sumContracts;

    let iteratorAmountsSum = 0, numberContractsHalfSpendings = 0;
    for(let i= 0; i < sortedAmountsArray.length; i++){
      iteratorAmountsSum += sortedAmountsArray[i];
      numberContractsHalfSpendings++;

      if (iteratorAmountsSum > (sumContracts/2) ) { break; }
    }
    const halfSpendingsContractsPct = numberContractsHalfSpendings / numberContracts;

    // Updating the DOM
    document.getElementById("number-contracts").innerText = numberContracts.toLocaleString();
    document.getElementById("sum-contracts").innerText = money(sumContracts);
    document.getElementById("mean-contracts").innerText = money(meanContracts);
    document.getElementById("median-contracts").innerText = money(medianContracts);

    document.getElementById("less-than-1000-pct").innerText = lessThan1000Pct.toLocaleString(I18n.locale, {
      style: 'percent'
    });
    document.getElementById("larger-contract-amount-pct").innerText = largerContractAmountPct.toLocaleString(I18n.locale, {
      style: 'percent'
    });
    document.getElementById("half-spendings-contracts-pct").innerText = halfSpendingsContractsPct.toLocaleString(I18n.locale, {
      style: 'percent'
    });;
  }

  _renderByAmountsChart(){
    const dimension = ndx.dimension(contract => contract.range);

    const renderOptions = {
      containerSelector: "#amount-distribution-bars",
      dimension: dimension,
      range: _amountRange,
      labelMore: I18n.t('gobierto_dashboards.dashboards.contracts.more'),
      labelFromTo: I18n.t('gobierto_dashboards.dashboards.contracts.fromto'),
      onFilteredFunction: (chart, filter) => {
        this._refreshData(dimension.top(Infinity))
      }
    }

    charts['amount_distribution'] = new AmountDistributionBars(renderOptions);
  }

  _renderContractTypeChart(){
    const dimension = ndx.dimension(contract => contract.contract_type)

    const renderOptions = {
      containerSelector: "#contract-type-bars",
      dimension: dimension,
      onFilteredFunction: (chart, filter) => {
        this._refreshData(dimension.top(Infinity), chart.filters(), 'contract_type')
        EventBus.$emit('dc_filter_selected', {title: filter, id: 'contract_types'})
      }
    }

    charts['contract_types'] = new GroupPctDistributionBars(renderOptions);
  }

  _renderProcessTypeChart(){
    const dimension = ndx.dimension(contract => contract.process_type)

    const renderOptions = {
      containerSelector: "#process-type-bars",
      dimension: dimension,
      onFilteredFunction: (chart, filter) => {
        this._refreshData(dimension.top(Infinity), chart.filters(), 'process_type')
        EventBus.$emit('dc_filter_selected', {title: filter, id: 'process_types'})
      }
    }

    charts['process_types'] = new GroupPctDistributionBars(renderOptions);
  }

  _renderDateChart(){
    const dimension = ndx.dimension(contract => contract.start_date_year)

    const renderOptions = {
      containerSelector: "#date-bars",
      dimension: dimension,
      onFilteredFunction: (chart, filter) => {
        this._refreshData(dimension.top(Infinity), chart.filters(), 'submission_date_year')
        EventBus.$emit('dc_filter_selected', {title: filter, id: 'dates'})
      }
    }

    charts['dates'] = new GroupPctDistributionBars(renderOptions);
  }

  _updateChartsFromFilter(options){
    const container = charts[options.id].container;

    if (options.all) {
      container.filter(null);
      container.filter([options.titles]);
    } else {
      container.filter(options.title);
    }

    Object.values(charts).forEach((chart) => chart.container.redraw());
  }

  _refreshTendersDataFromFilters(filters, tendersAttribute){
    tendersFilters[tendersAttribute] = filters;
    let filteredTendersData = [...unfilteredTendersData]

    Object.keys(tendersFilters).forEach((key) => {
      if (tendersFilters[key].length > 0) {
        filteredTendersData = filteredTendersData.filter(tender => tendersFilters[key].includes(tender[key]) )
      }
    });

    data.tendersData = filteredTendersData;
  }

  _redrawCharts(){
    Object.values(charts).forEach((chart) => {
      chart.setContainerSize();
      chart.container.redraw();
    });
  }

  _currentDataSource(){
    return reduced || data
  }

  _formalizedContractsData(contractsData){
    return contractsData.filter(({status}) =>
      status === 'Formalizado' || status === 'Adjudicado'
    )
  }

}
