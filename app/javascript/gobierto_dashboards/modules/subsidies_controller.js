import Vue from "vue";
import VueRouter from "vue-router";

import { sum, mean, median, max } from 'd3-array';
import { scaleThreshold } from 'd3-scale';

const d3 = { scaleThreshold, sum, mean, median, max }

import crossfilter from 'crossfilter2'

import { getRemoteData, sortByField } from '../webapp/lib/utils'
import { EventBus } from '../webapp/mixins/event_bus'

import { money } from 'lib/shared'

import { AmountDistributionBars, GroupPctDistributionBars } from "lib/visualizations";

Vue.use(VueRouter);
Vue.config.productionTip = false;

export class SubsidiesController {
  constructor(options) {
    this.charts = {};

    const selector = "gobierto-dashboards-subsidies-app";

    // Mount Vue applications
    const entryPoint = document.getElementById(selector);

    if (entryPoint) {
      const htmlRouterBlock = `<router-view></router-view>`;

      entryPoint.innerHTML = htmlRouterBlock;

      const Home = () => import("../webapp/containers/subsidies/Home.vue");
      const Summary = () => import("../webapp/containers/subsidies/Summary.vue");
      const SubsidiesIndex = () => import("../webapp/containers/subsidies/SubsidiesIndex.vue");
      const SubsidiesShow = () => import("../webapp/containers/subsidies/SubsidiesShow.vue");

      Promise.all([getRemoteData(options.subsidiesEndpoint)]).then((rawData) => {
        this.setGlobalVariables(rawData)

        const router = new VueRouter({
          mode: "history",
          routes: [
            { path: "/dashboards/subvenciones", component: Home, props: { dataDownloadEndpoint: options.dataDownloadEndpoint },
              children: [
                { path: "", name: "summary", component: Summary },
                { path: "subvenciones", name: "subsidies_index", component: SubsidiesIndex },
                { path: "subvenciones/:id", name: "subsidies_show", component: SubsidiesShow },
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

              if (to.name === "subsidies_show") {
                const { item: { title: itemTitle } = {} } = to.params;

                if (itemTitle) {
                  title = `${itemTitle}${baseTitle}`;
                }
              }

              document.title = title;
            })
          );
        });

        this.vueApp = new Vue({
          router,
          data: Object.assign(options, this.data),
        }).$mount(entryPoint);

        EventBus.$on('summary-ready', () => {
          this._renderSummary();
        });

        EventBus.$on('filter-changed', (options) => {
          this._updateChartsFromFilter(options);
        });

        // - dc charts are drawn even if the summary page is not the page where the user lands for the first time
        //   i.e.: they could first land on a subsidy page, but still this page would need to render for the filters to work
        // - dc charts sizes are calculated automatically, but if the page is not visible it won't calculate sizes properly
        // - Given all that: when we go from a page that is not summary to summary for the first time, the sizes must
        //   be calculated and the charts redrawn. This is why this event only needs to be listened once.
        EventBus.$once('moved-to-summary', () => {
          this._redrawCharts();
        });

        const loadingElement = document.querySelector(".js-loading");
        if (loadingElement) {
          loadingElement.classList.add('hidden')
        }
      });
    }
  }

  setGlobalVariables(rawData){
    let subsidiesData = rawData[0];

    // Precalculations and normalizations
    this._amountRange = {
      domain: [501, 1001, 5001, 10001, 15001],
      range: [0, 1, 2, 3, 4, 5]
    };
    var rangeFormat = d3.scaleThreshold().domain(this._amountRange.domain).range(this._amountRange.range);

    for (let i = 0; i < subsidiesData.length; i++){
      const subsidy = subsidiesData[i];
      const amount = subsidy.amount && !Number.isNaN(subsidy.amount) ? parseFloat(subsidy.amount) : 0.0

      let [beneficiary_id, ...beneficiary_name] = subsidy.beneficiary.split(' ')

      subsidy.amount = amount;
      subsidy.range = rangeFormat(+amount);

      subsidy.beneficiary_id = beneficiary_id
      subsidy.beneficiary_name = beneficiary_name.join(' ')
      // it's an individual if the beneficiary id is hidden with asterisks
      subsidy.isIndividual = (/\*+/).test(beneficiary_id)

      if (!subsidy.id) {
        subsidy.id = `${subsidy.grant_date.replace(/\D+/g,'')}${subsidy.beneficiary_id.replace(/\D+/g, '')}${parseInt(subsidy.amount) || 0}`;
      }
    }

    this.data = {
      subsidiesData: subsidiesData.sort(sortByField('grant_date')),
    }
  }

  _renderSummary(){
    this.ndx = crossfilter(this._currentDataSource().subsidiesData);

    this._renderSubsidiesMetricsBox();

    this._renderByAmountsChart();
    this._renderCategoryChart();
    this._renderDateChart();
  }

  _refreshData(reducedSubsidiesData){
    this.reduced = { subsidiesData: reducedSubsidiesData };

    this.vueApp.subsidiesData = reducedSubsidiesData;
    EventBus.$emit('refresh-summary-data');

    this._renderSubsidiesMetricsBox();
  }

  _renderSubsidiesMetricsBox(){
    const subsidiesData = this._currentDataSource().subsidiesData;

    const individualsData = subsidiesData.filter(subsidy => subsidy.isIndividual);
    const collectivesData = subsidiesData.filter(subsidy => !subsidy.isIndividual);

    // Calculations
    const amountsArray = subsidiesData.map(({ amount = 0 }) => parseFloat(amount) );
    const amountsIndividualsArray = individualsData.map(({ amount = 0 }) => parseFloat(amount) );
    const amountsCollectivesArray = collectivesData.map(({ amount = 0 }) => parseFloat(amount) );
    const sortedAmountsArray = amountsArray.sort((a, b) => b - a);

    // Calculations box items
    const numberSubsidies = subsidiesData.length;
    const sumSubsidies = d3.sum(amountsArray);
    const meanSubsidies = d3.mean(amountsArray) || 0;
    const medianSubsidies = d3.median(amountsArray) || 0;

    const pctCollectivesSubsidies = parseFloat(collectivesData.length)/numberSubsidies;
    const sumCollectivesSubsidies = d3.sum(amountsCollectivesArray);
    const meanCollectivesSubsidies = d3.mean(amountsCollectivesArray) || 0;
    const medianCollectivesSubsidies = d3.median(amountsCollectivesArray) || 0;

    const pctIndividualsSubsidies = parseFloat(individualsData.length)/numberSubsidies;
    const sumIndividualsSubsidies = d3.sum(amountsIndividualsArray);
    const meanIndividualsSubsidies = d3.mean(amountsIndividualsArray) || 0;
    const medianIndividualsSubsidies = d3.median(amountsIndividualsArray) || 0;

    // Calculations headlines
    const lessThan1000Total = subsidiesData.filter(({ amount = 0 }) => parseFloat(amount) < 1000).length;
    const lessThan1000Pct = lessThan1000Total/numberSubsidies;

    const largerSubsidyAmount = d3.max(subsidiesData, ({ amount = 0 }) => parseFloat(amount));
    const largerSubsidyAmountPct = largerSubsidyAmount / sumSubsidies;

    let iteratorAmountsSum = 0, numberSubsidiesHalfSpendings = 0;
    for (let i= 0; i < sortedAmountsArray.length; i++){
      iteratorAmountsSum += sortedAmountsArray[i];
      numberSubsidiesHalfSpendings++;

      if (iteratorAmountsSum > (sumSubsidies/2) ) { break; }
    }
    const halfSpendingsSubsidiesPct = numberSubsidiesHalfSpendings / numberSubsidies;

    // Updating the DOM
    document.getElementById("number-subsidies").innerText = numberSubsidies.toLocaleString();
    document.getElementById("sum-subsidies").innerText = money(sumSubsidies);
    document.getElementById("mean-subsidies").innerText = money(meanSubsidies);
    document.getElementById("median-subsidies").innerText = money(medianSubsidies);

    document.getElementById("pct-collectives-subsidies").innerText = pctCollectivesSubsidies.toLocaleString(I18n.locale, {
      style: 'percent',
      minimumFractionDigits: 2
    });
    document.getElementById("sum-collectives-subsidies").innerText = money(sumCollectivesSubsidies);
    document.getElementById("mean-collectives-subsidies").innerText = money(meanCollectivesSubsidies);
    document.getElementById("median-collectives-subsidies").innerText = money(medianCollectivesSubsidies);

    document.getElementById("pct-individuals-subsidies").innerText = pctIndividualsSubsidies.toLocaleString(I18n.locale, {
      style: 'percent',
      minimumFractionDigits: 2
    });
    document.getElementById("sum-individuals-subsidies").innerText = money(sumIndividualsSubsidies);
    document.getElementById("mean-individuals-subsidies").innerText = money(meanIndividualsSubsidies);
    document.getElementById("median-individuals-subsidies").innerText = money(medianIndividualsSubsidies);

    document.getElementById("less-than-1000-pct").innerText = lessThan1000Pct.toLocaleString(I18n.locale, {
      style: 'percent'
    });
    document.getElementById("larger-subsidy-amount-pct").innerText = largerSubsidyAmountPct.toLocaleString(I18n.locale, {
      style: 'percent'
    });
    document.getElementById("half-spendings-subsidies-pct").innerText = halfSpendingsSubsidiesPct.toLocaleString(I18n.locale, {
      style: 'percent'
    });
  }

  _renderByAmountsChart(){
    const dimension = this.ndx.dimension(subsidy => subsidy.range);

    const renderOptions = {
      containerSelector: "#amount-distribution-bars",
      dimension: dimension,
      range: this._amountRange,
      labelMore: I18n.t('gobierto_dashboards.dashboards.subsidies.more'),
      labelFromTo: I18n.t('gobierto_dashboards.dashboards.subsidies.fromto'),
      onFilteredFunction: (chart, filter) => {
        this._refreshData(dimension.top(Infinity))
      }
    }

    this.charts['amount_distribution'] = new AmountDistributionBars(renderOptions);
  }

  _renderCategoryChart(){
    const dimension = this.ndx.dimension(subsidy => subsidy.category)

    const renderOptions = {
      containerSelector: "#category-bars",
      dimension: dimension,
      onFilteredFunction: (chart, filter) => {
        this._refreshData(dimension.top(Infinity))
        EventBus.$emit('dc-filter-selected', { title: filter, id: 'categories' })
      }
    }

    this.charts['categories'] = new GroupPctDistributionBars(renderOptions);
  }

  _renderDateChart(){
    const dimension = this.ndx.dimension(subsidy => subsidy.year)

    const renderOptions = {
      containerSelector: "#date-bars",
      dimension: dimension,
      onFilteredFunction: (chart, filter) => {
        this._refreshData(dimension.top(Infinity))
        EventBus.$emit('dc-filter-selected', { title: filter, id: 'dates' })
      }
    }

    this.charts['dates'] = new GroupPctDistributionBars(renderOptions);
  }

  _updateChartsFromFilter(options){
    const container = this.charts[options.id].container;

    // https://dc-js.github.io/dc.js/docs/html/BaseMixin.html#filter__anchor
    // - filter(null) removes any existing filter.
    // - If all filters are set at one (options.all), we first remove the existing ones
    // - Note: when you add more than 1 filter, you need to add an array within an array
    if (options.all) {
      container.filter(null);
      container.filter([options.titles]);
    } else {
      container.filter(options.title);
    }

    Object.values(this.charts).forEach((chart) => chart.container.redraw());
  }

  _redrawCharts(){
    Object.values(this.charts).forEach((chart) => {
      chart.setContainerSize();
      chart.container.redraw();
    });
  }

  _currentDataSource(){
    return this.reduced || this.data
  }

}
