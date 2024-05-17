import crossfilter from 'crossfilter2';
import * as d3 from 'd3';
import Vue from 'vue';
import VueRouter from 'vue-router';
import {
  AmountDistributionBars,
  GroupPctDistributionBars
} from '../../lib/visualizations';
import { checkAndReportAccessibility } from '../../lib/vue/accessibility';
import { money } from '../../lib/vue/filters';
import { EventBus } from '../webapp/lib/mixins/event_bus';
import { calculateSumMeanMedian, getRemoteData, sortByField } from '../webapp/lib/utils';

// ESBuild does not work properly with dynamic components
import Home from '../webapp/containers/subsidies/Home.vue';
import Summary from '../webapp/containers/subsidies/Summary.vue';
import SubsidiesIndex from '../webapp/containers/subsidies/SubsidiesIndex.vue';
import SubsidiesShow from '../webapp/containers/subsidies/SubsidiesShow.vue';
// const Home = () => import('../webapp/containers/subsidies/Home.vue');
// const Summary = () => import('../webapp/containers/subsidies/Summary.vue');
// const SubsidiesIndex = () => import('../webapp/containers/subsidies/SubsidiesIndex.vue');
// const SubsidiesShow = () => import('../webapp/containers/subsidies/SubsidiesShow.vue');

if (Vue.config.devtools) {
  Vue.use(checkAndReportAccessibility)
}

Vue.use(VueRouter);
Vue.config.productionTip = false;

export class SubsidiesController {
  constructor(options) {
    this.charts = {};

    const selector = "gobierto-visualizations-subsidies-app";

    // Mount Vue applications
    const entryPoint = document.getElementById(selector);

    if (entryPoint) {
      const htmlRouterBlock = `<router-view></router-view>`;

      entryPoint.innerHTML = htmlRouterBlock;

      Promise.all([getRemoteData(options.subsidiesEndpoint)]).then(rawData => {
        this.setGlobalVariables(rawData);

        const router = new VueRouter({
          mode: "history",
          routes: [
            {
              path: "/visualizaciones/subvenciones",
              alias: "/",
              component: Home,
              props: { dataDownloadEndpoint: options.dataDownloadEndpoint },
              children: [
                { path: "", name: "summary", component: Summary },
                {
                  path: "subvenciones",
                  name: "subsidies_index",
                  component: SubsidiesIndex
                },
                {
                  path: "subvenciones/:id",
                  name: "subsidies_show",
                  component: SubsidiesShow
                }
              ]
            }
          ],
          scrollBehavior(to) {
            const components = ['subsidies_show']
            if (components.includes(to.name)) {
              const element = document.getElementById(selector);
              window.scrollTo({ top: element.offsetTop, behavior: "smooth" });
            }
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
          data: Object.assign(options, this.data)
        }).$mount(entryPoint);

        EventBus.$on("summary-ready", () => {
          this._renderSummary();
        });

        EventBus.$on("filter-changed", options => {
          this._updateChartsFromFilter(options);
        });

        // - dc charts are drawn even if the summary page is not the page where the user lands for the first time
        //   i.e.: they could first land on a subsidy page, but still this page would need to render for the filters to work
        // - dc charts sizes are calculated automatically, but if the page is not visible it won't calculate sizes properly
        // - Given all that: when we go from a page that is not summary to summary for the first time, the sizes must
        //   be calculated and the charts redrawn. This is why this event only needs to be listened once.
        EventBus.$once("moved-to-summary", () => {
          this._redrawCharts();
        });

        EventBus.$on("mounted", () => {
          // Hide the external loader once the vueApp has been mounted in the DOM
          const loadingElement = document.querySelector(".js-loading");
          if (loadingElement) {
            loadingElement.classList.add("hidden");
          }
        });
      });
    }
  }

  setGlobalVariables(rawData) {
    let subsidiesData = rawData[0];

    // Precalculations and normalizations
    this._amountRange = {
      domain: [501, 1001, 5001, 10001, 15001],
      range: [0, 1, 2, 3, 4, 5]
    };
    var rangeFormat = d3
      .scaleThreshold()
      .domain(this._amountRange.domain)
      .range(this._amountRange.range);

    subsidiesData = subsidiesData.map(({ amount = 0, beneficiary = "", beneficiary_type = "", grant_date, ...rest }, index) => {
      let [beneficiary_id, ...beneficiary_name] = beneficiary.split(" ");

      if (beneficiary === '' && beneficiary_type === 'persona') {
        beneficiary = I18n.t('gobierto_visualizations.visualizations.subsidies.person')
      }

      return {
        amount: amount && !Number.isNaN(amount) ? parseFloat(amount) : 0.0,
        range: rangeFormat(+amount),
        beneficiary,
        beneficiary_type,
        beneficiary_id,
        beneficiary_name: beneficiary_name.join(" "),
        grant_date,
        id: `${grant_date.replace(/\D+/g,"")}${beneficiary_id.replace(/\D+/g, "")}${parseInt(amount) || 0}${index}`,
        ...rest,
      }
    })

    this.data = {
      subsidiesData: subsidiesData.sort(sortByField("grant_date"))
    };
  }

  _renderSummary() {
    this.ndx = crossfilter(this._currentDataSource().subsidiesData);

    this._renderSubsidiesMetricsBox();

    this._renderByAmountsChart();
    this._renderCategoryChart();
    this._renderDateChart();
  }

  _refreshData(reducedSubsidiesData) {
    this.reduced = { subsidiesData: reducedSubsidiesData };

    this.vueApp.subsidiesData = reducedSubsidiesData;
    EventBus.$emit("refresh-summary-data");

    this._renderSubsidiesMetricsBox();
  }

  _renderSubsidiesMetricsBox() {
    const subsidiesData = this._currentDataSource().subsidiesData;

    const individualsData = subsidiesData.filter(
      ({ beneficiary_type }) => beneficiary_type === "persona"
    );
    const collectivesData = subsidiesData.filter(
      ({ beneficiary_type }) => beneficiary_type === "colectivo"
    );

    // Calculations
    const amountsArray = subsidiesData.map(({ amount = 0 }) =>
      parseFloat(amount)
    );
    const amountsIndividualsArray = individualsData.map(({ amount = 0 }) =>
      parseFloat(amount)
    );
    const amountsCollectivesArray = collectivesData.map(({ amount = 0 }) =>
      parseFloat(amount)
    );
    const sortedAmountsArray = amountsArray.sort((a, b) => b - a);

    // Calculations box items
    const numberSubsidies = subsidiesData.length;
    const [ sumSubsidies, meanSubsidies, medianSubsidies ] = calculateSumMeanMedian(amountsArray)

    const pctCollectivesSubsidies = numberSubsidies ? (parseFloat(collectivesData.length) / numberSubsidies) : 0;
    const [ sumCollectivesSubsidies, meanCollectivesSubsidies, medianCollectivesSubsidies ] = calculateSumMeanMedian(amountsCollectivesArray)

    const pctIndividualsSubsidies = numberSubsidies ? (parseFloat(individualsData.length) / numberSubsidies) : 0;
    const [ sumIndividualsSubsidies, meanIndividualsSubsidies, medianIndividualsSubsidies ] = calculateSumMeanMedian(amountsIndividualsArray)

    // Calculations headlines
    const lessThan1000Total = subsidiesData.filter(
      ({ amount = 0 }) => parseFloat(amount) < 1000
    ).length;
    const lessThan1000Pct = numberSubsidies ? (lessThan1000Total / numberSubsidies) : 0;

    const largerSubsidyAmount = d3.max(subsidiesData, ({ amount = 0 }) =>
      parseFloat(amount)
    );

    const largerSubsidyAmountPct = numberSubsidies ? (largerSubsidyAmount / numberSubsidies) : 0;

    let iteratorAmountsSum = 0,
      numberSubsidiesHalfSpendings = 0;
    for (let i = 0; i < sortedAmountsArray.length; i++) {
      iteratorAmountsSum += sortedAmountsArray[i];
      numberSubsidiesHalfSpendings++;

      if (iteratorAmountsSum > sumSubsidies / 2) {
        break;
      }
    }
    const halfSpendingsSubsidiesPct = numberSubsidies ? (numberSubsidiesHalfSpendings / numberSubsidies) : 0;

    // Updating the DOM
    document.getElementById(
      "number-subsidies"
    ).innerText = numberSubsidies.toLocaleString();
    document.getElementById("sum-subsidies").innerText = money(sumSubsidies);
    document.getElementById("mean-subsidies").innerText = money(meanSubsidies);
    document.getElementById("median-subsidies").innerText = money(
      medianSubsidies
    );

    document.getElementById(
      "number-collectives-subsidies"
    ).innerText = pctCollectivesSubsidies.toLocaleString(I18n.locale, {
      style: "percent",
      minimumFractionDigits: 2
    });
    document.getElementById("sum-collectives-subsidies").innerText = money(
      sumCollectivesSubsidies
    ) ;
    document.getElementById("mean-collectives-subsidies").innerText = money(
      meanCollectivesSubsidies
    );
    document.getElementById("median-collectives-subsidies").innerText = money(
      medianCollectivesSubsidies
    );

    document.getElementById(
      "number-individuals-subsidies"
    ).innerText = pctIndividualsSubsidies.toLocaleString(I18n.locale, {
      style: "percent",
      minimumFractionDigits: 2
    });
    document.getElementById("sum-individuals-subsidies").innerText = money(
      sumIndividualsSubsidies
    );
    document.getElementById("mean-individuals-subsidies").innerText = money(
      meanIndividualsSubsidies
    );
    document.getElementById("median-individuals-subsidies").innerText = money(
      medianIndividualsSubsidies
    );

    document.getElementById(
      "less-than-1000-pct"
    ).innerText = lessThan1000Pct.toLocaleString(I18n.locale, {
      style: "percent"
    });
    document.getElementById(
      "larger-subsidy-amount-pct"
    ).innerText = largerSubsidyAmountPct.toLocaleString(I18n.locale, {
      style: "percent"
    });
    document.getElementById(
      "half-spendings-subsidies-pct"
    ).innerText = halfSpendingsSubsidiesPct.toLocaleString(I18n.locale, {
      style: "percent"
    });
  }

  _renderByAmountsChart() {
    const dimension = this.ndx.dimension(subsidy => subsidy.range);

    const renderOptions = {
      containerSelector: "#amount-distribution-bars",
      dimension: dimension,
      range: this._amountRange,
      labelMore: I18n.t("gobierto_visualizations.visualizations.subsidies.more"),
      labelFromTo: I18n.t("gobierto_visualizations.visualizations.subsidies.fromto"),
      onFilteredFunction: () => {
        this._refreshData(dimension.top(Infinity));
      }
    };

    this.charts["amount_distribution"] = new AmountDistributionBars(
      renderOptions
    );
  }

  _renderCategoryChart() {
    const dimension = this.ndx.dimension(subsidy => subsidy.category);

    const renderOptions = {
      containerSelector: "#category-bars",
      dimension: dimension,
      onFilteredFunction: (chart, filter) => {
        this._refreshData(dimension.top(Infinity));
        EventBus.$emit("dc-filter-selected", {
          title: filter,
          id: "categories"
        });
      }
    };

    this.charts["categories"] = new GroupPctDistributionBars(renderOptions);
  }

  _renderDateChart() {
    const dimension = this.ndx.dimension(subsidy => subsidy.year);

    const renderOptions = {
      containerSelector: "#date-bars",
      dimension: dimension,
      onFilteredFunction: (chart, filter) => {
        this._refreshData(dimension.top(Infinity));
        EventBus.$emit("dc-filter-selected", { title: filter, id: "dates" });
      }
    };

    this.charts["dates"] = new GroupPctDistributionBars(renderOptions);
  }

  _updateChartsFromFilter(options) {
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

    Object.values(this.charts).forEach(chart => chart.container.redraw());
  }

  _redrawCharts() {
    Object.values(this.charts).forEach(chart => {
      chart.setContainerSize();
      chart.container.redraw();
    });
  }

  _currentDataSource() {
    return this.reduced || this.data;
  }
}
