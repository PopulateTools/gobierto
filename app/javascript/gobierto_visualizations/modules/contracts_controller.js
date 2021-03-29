import crossfilter from "crossfilter2";
import { max, mean, median, sum } from "d3-array";
import { scaleThreshold } from "d3-scale";
import { money } from "lib/vue/filters";
import {
  AmountDistributionBars,
  GroupPctDistributionBars
} from "lib/visualizations";
import Vue from "vue";
import VueRouter from "vue-router";
import { getRemoteData, calculateSumMeanMedian } from "../webapp/lib/utils";
import { EventBus } from "../webapp/mixins/event_bus";

const d3 = { scaleThreshold, sum, mean, median, max };

Vue.use(VueRouter);
Vue.config.productionTip = false;

export class ContractsController {
  constructor(options) {
    this.charts = {};
    this.tendersFilters = {
      submission_date: [],
      process_type: [],
      contract_type: []
    };

    const selector = "gobierto-visualizations-contracts-app";

    // Mount Vue applications
    const entryPoint = document.getElementById(selector);

    if (entryPoint) {
      const htmlRouterBlock = `<router-view></router-view>`;

      entryPoint.innerHTML = htmlRouterBlock;

      const Home = () =>
        import("../webapp/containers/contracts/Home.vue");
      const Summary = () =>
        import("../webapp/containers/contracts/Summary.vue");
      const ContractsIndex = () =>
        import("../webapp/containers/contracts/ContractsIndex.vue");
      const ContractsShow = () =>
        import("../webapp/containers/contracts/ContractsShow.vue");
      const AssigneesShow = () =>
        import("../webapp/containers/contracts/AssigneesShow.vue");

      Promise.all([
        getRemoteData(options.contractsEndpoint),
        getRemoteData(options.tendersEndpoint)
      ]).then(rawData => {
        this.setGlobalVariables(rawData);

        const router = new VueRouter({
          mode: "history",
          routes: [
            {
              path: "/visualizaciones/contratos",
              component: Home,
              props: { dataDownloadEndpoint: options.dataDownloadEndpoint },
              children: [
                { path: "", name: "summary", component: Summary },
                {
                  path: "adjudicaciones",
                  name: "contracts_index",
                  component: ContractsIndex
                },
                {
                  path: "adjudicaciones/:id",
                  name: "contracts_show",
                  component: ContractsShow
                },
                {
                  path: "adjudicatario/:id",
                  name: "assignees_show",
                  component: AssigneesShow
                }
              ]
            }
          ],
          scrollBehavior(to) {
            const components = ['contracts_show', 'assignees_show']
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
        //   i.e.: they could first land on a contract page, but still this page would need to render for the filters to work
        // - dc charts sizes are calculated automatically, but if the page is not visible it won't calculate sizes properly
        // - Given all that: when we go from a page that is not summary to summary for the first time, the sizes must
        //   be calculated and the charts redrawn. This is why this event only needs to be listened once.
        EventBus.$once("moved-to-summary", () => {
          this._redrawCharts();
        });

        const loadingElement = document.querySelector(".js-loading");
        if (loadingElement) {
          loadingElement.classList.add("hidden");
        }
      });
    }
  }

  setGlobalVariables([contractsData, tendersData]) {
    let contractsDataMap = this._translateCategoriesTitle(contractsData)
    let tendersDataMap = this._translateCategoriesTitle(tendersData)
    const sortByField = dateField => {
      return function(a, b) {
        const aDate = a[dateField],
          bDate = b[dateField];

        if (aDate == "") {
          return 1;
        }

        if (bDate == "") {
          return -1;
        }

        if (aDate < bDate) {
          return 1;
        } else if (aDate > bDate) {
          return -1;
        } else {
          return 0;
        }
      };
    };

    // Contracts precalculations and normalizations
    this._amountRange = {
      domain: [1001, 10001, 50001, 100001],
      range: [0, 1, 2, 3, 4]
    };
    var rangeFormat = d3
      .scaleThreshold()
      .domain(this._amountRange.domain)
      .range(this._amountRange.range);

    contractsDataMap = contractsData.map(({ final_amount_no_taxes = 0, initial_amount_no_taxes = 0, gobierto_start_date, assignee_id, ...rest }) => {
      return {
        final_amount_no_taxes: (final_amount_no_taxes && !Number.isNaN(final_amount_no_taxes)) ? parseFloat(final_amount_no_taxes): 0.0,
        initial_amount_no_taxes: (initial_amount_no_taxes && !Number.isNaN(initial_amount_no_taxes)) ? parseFloat(initial_amount_no_taxes): 0.0,
        range: rangeFormat(+final_amount_no_taxes),
        assignee_routing_id: assignee_id,
        gobierto_start_date_year: gobierto_start_date ? new Date(gobierto_start_date).getFullYear().toString() : '',
        gobierto_start_date: new Date(gobierto_start_date),
        ...rest
      }
    })

    tendersDataMap = tendersData.map(({ initial_amount_no_taxes = 0, submission_date, ...rest }) => {

      return {
        initial_amount_no_taxes: initial_amount_no_taxes ? parseFloat(initial_amount_no_taxes) : 0.0,
        submission_date_year: submission_date ? new Date(submission_date).getFullYear().toString() : '',
        ...rest
      }

    })

    this.unfilteredTendersData = tendersDataMap.sort(
      sortByField("submission_date")
    );

    this.data = {
      contractsData: this._formalizedContractsData(contractsDataMap).sort(
        sortByField("gobierto_start_date")
      ),
      tendersData: this.unfilteredTendersData
    };
  }

  _translateCategoriesTitle(contractsData) {

    contractsData.map(d => {
      const { category_title } = d

      d.category_title = I18n.t(`gobierto_visualizations.visualizations.categories.${category_title}`)

      if (d.contract_type === 'Servicios') {
        d.contract_type = I18n.t('gobierto_visualizations.visualizations.contracts_types.services')
      } else if (d.contract_type === 'Suministros') {
        d.contract_type = I18n.t('gobierto_visualizations.visualizations.contracts_types.supplies')
      } else if (d.contract_type === 'Obras') {
        d.contract_type = I18n.t('gobierto_visualizations.visualizations.contracts_types.works')
      } else if (d.contract_type === 'Otros') {
        d.contract_type = I18n.t('gobierto_visualizations.visualizations.contracts_types.others')
      } else if (d.contract_type === 'Privado') {
        d.contract_type = I18n.t('gobierto_visualizations.visualizations.contracts_types.private')
      } else if (d.contract_type === 'Gestión de servicios públicos') {
        d.contract_type = I18n.t('gobierto_visualizations.visualizations.contracts_types.public_services')
      }

      if (d.process_type === 'Contrato menor') {
        d.process_type = I18n.t('gobierto_visualizations.visualizations.process_type.minor_contract')
      } else if (d.process_type === 'Abierto') {
        d.process_type = I18n.t('gobierto_visualizations.visualizations.process_type.open')
      } else if (d.process_type === 'Negociado sin publicidad') {
        d.process_type = I18n.t('gobierto_visualizations.visualizations.process_type.negotiated_publicity')
      } else if (d.process_type === 'Basado en Acuerdo Marco') {
        d.process_type = I18n.t('gobierto_visualizations.visualizations.process_type.based_marco')
      } else if (d.process_type === 'Otros') {
        d.process_type = I18n.t('gobierto_visualizations.visualizations.process_type.others')
      } else if (d.process_type === 'Licitación con negociación') {
        d.process_type = I18n.t('gobierto_visualizations.visualizations.process_type.tender')
      } else if (d.process_type === 'Restringido') {
        d.process_type = I18n.t('gobierto_visualizations.visualizations.process_type.restricted')
      }

      if (d.status === 'Adjudicado') {
        d.status = I18n.t('gobierto_visualizations.visualizations.status_types.awarded')
      } else if (d.status === 'Rechazado') {
        d.status = I18n.t('gobierto_visualizations.visualizations.status_types.renunciation')
      } else if (d.status === 'Formalizado') {
        d.status = I18n.t('gobierto_visualizations.visualizations.status_types.formalized')
      } else if (d.status === 'Desierto') {
        d.status = I18n.t('gobierto_visualizations.visualizations.status_types.deserted')
      }

    })
    return contractsData
  }

  _renderSummary() {
    this.ndx = crossfilter(this._currentDataSource().contractsData);

    this._renderTendersMetricsBox();
    this._renderContractsMetricsBox();

    this._renderByAmountsChart();
    this._renderContractTypeChart();
    this._renderProcessTypeChart();
    this._renderDateChart();
    this._renderCategoriesChart();
    this._renderEntitiesChart();
  }

  _refreshData(reducedContractsData, filters, tendersAttribute) {
    if (filters) {
      this._refreshTendersDataFromFilters(filters, tendersAttribute);
    }
    this.reduced = {
      tendersData: this.data.tendersData,
      contractsData: reducedContractsData
    };

    this.vueApp.contractsData = reducedContractsData;
    EventBus.$emit("refresh-summary-data");

    this._renderTendersMetricsBox();
    this._renderContractsMetricsBox();
  }

  _renderTendersMetricsBox() {
    const _tendersData = this._currentDataSource().tendersData;

    // Calculations
    const amountsArray = _tendersData.map(({ initial_amount_no_taxes = 0 }) =>
      parseFloat(initial_amount_no_taxes)
    );

    const numberTenders = _tendersData.length;
    const [ sumTenders, meanTenders, medianTenders ] = calculateSumMeanMedian(amountsArray)

    // Updating the DOM
    document.getElementById(
      "number-tenders"
    ).innerText = numberTenders.toLocaleString();
    document.getElementById("sum-tenders").innerText = money(sumTenders);
    document.getElementById("mean-tenders").innerText = money(meanTenders);
    document.getElementById("median-tenders").innerText = money(medianTenders);
  }

  _renderContractsMetricsBox() {
    const _contractsData = this._currentDataSource().contractsData;

    // Calculations
    const amountsArray = _contractsData.map(({ final_amount_no_taxes = 0 }) =>
      parseFloat(final_amount_no_taxes)
    );
    const sortedAmountsArray = amountsArray.sort((a, b) => b - a);

    // Calculations box items
    const numberContracts = _contractsData.length;
    const [ sumContracts, meanContracts, medianContracts ] = calculateSumMeanMedian(amountsArray)

    // Calculations headlines
    const lessThan1000Total = _contractsData.filter(
      ({ final_amount_no_taxes = 0 }) =>
        parseFloat(final_amount_no_taxes) < 1000
    ).length;
    const lessThan1000Pct = lessThan1000Total / numberContracts;

    const largerContractAmount = d3.max(
      _contractsData,
      ({ final_amount_no_taxes = 0 }) => parseFloat(final_amount_no_taxes)
    );
    const largerContractAmountPct = sumContracts ? (largerContractAmount / sumContracts) : 0;

    let iteratorAmountsSum = 0,
      numberContractsHalfSpendings = 0;
    for (let i = 0; i < sortedAmountsArray.length; i++) {
      iteratorAmountsSum += sortedAmountsArray[i];
      numberContractsHalfSpendings++;

      if (iteratorAmountsSum > sumContracts / 2) {
        break;
      }
    }
    const halfSpendingsContractsPct =
      numberContractsHalfSpendings / numberContracts;

    // Updating the DOM
    document.getElementById(
      "number-contracts"
    ).innerText = numberContracts.toLocaleString();
    document.getElementById("sum-contracts").innerText = money(sumContracts);
    document.getElementById("mean-contracts").innerText = money(meanContracts);
    document.getElementById("median-contracts").innerText = money(
      medianContracts
    );

    document.getElementById(
      "less-than-1000-pct"
    ).innerText = lessThan1000Pct.toLocaleString(I18n.locale, {
      style: "percent"
    });
    document.getElementById(
      "larger-contract-amount-pct"
    ).innerText = largerContractAmountPct.toLocaleString(I18n.locale, {
      style: "percent"
    });
    document.getElementById(
      "half-spendings-contracts-pct"
    ).innerText = halfSpendingsContractsPct.toLocaleString(I18n.locale, {
      style: "percent"
    });
  }

  _renderByAmountsChart() {
    const dimension = this.ndx.dimension(contract => contract.range);

    const renderOptions = {
      containerSelector: "#amount-distribution-bars",
      dimension: dimension,
      range: this._amountRange,
      labelMore: I18n.t('gobierto_visualizations.visualizations.contracts.more'),
      labelFromTo: I18n.t('gobierto_visualizations.visualizations.contracts.fromto'),
      onFilteredFunction: () => this._refreshData(dimension.top(Infinity))
    }

    this.charts["amount_distribution"] = new AmountDistributionBars(
      renderOptions
    );
  }

  _renderContractTypeChart() {
    const dimension = this.ndx.dimension(contract => contract.contract_type);

    const renderOptions = {
      containerSelector: "#contract-type-bars",
      dimension: dimension,
      onFilteredFunction: (chart, filter) => {
        this._refreshData(
          dimension.top(Infinity),
          chart.filters(),
          "contract_type"
        );
        EventBus.$emit("dc-filter-selected", {
          title: filter,
          id: "contract_types"
        });
      }
    };

    this.charts["contract_types"] = new GroupPctDistributionBars(renderOptions);
  }

  _renderProcessTypeChart() {
    const dimension = this.ndx.dimension(contract => contract.process_type);

    const renderOptions = {
      containerSelector: "#process-type-bars",
      dimension: dimension,
      onFilteredFunction: (chart, filter) => {
        this._refreshData(
          dimension.top(Infinity),
          chart.filters(),
          "process_type"
        );
        EventBus.$emit("dc-filter-selected", {
          title: filter,
          id: "process_types"
        });
      }
    };

    this.charts["process_types"] = new GroupPctDistributionBars(renderOptions);
  }

  _renderDateChart() {
    const dimension = this.ndx.dimension(contract => contract.gobierto_start_date_year);

    const renderOptions = {
      containerSelector: "#date-bars",
      dimension: dimension,
      onFilteredFunction: (chart, filter) => {
        this._refreshData(
          dimension.top(Infinity),
          chart.filters(),
          "submission_date_year"
        );
        EventBus.$emit("dc-filter-selected", { title: filter, id: "dates" });
      }
    };

    this.charts["dates"] = new GroupPctDistributionBars(renderOptions);
  }

  _renderCategoriesChart() {
    const dimension = this.ndx.dimension(contract => contract.category_title);

    const renderOptions = {
      containerSelector: "#category-bars",
      dimension: dimension,
      onFilteredFunction: (chart, filter) => {
        this._refreshData(
          dimension.top(Infinity),
          chart.filters(),
          "category_title"
        );
        EventBus.$emit("dc-filter-selected", { title: filter, id: "category_title" });
      }
    };

    this.charts["category_title"] = new GroupPctDistributionBars(renderOptions);
  }

  _renderEntitiesChart() {
    const dimension = this.ndx.dimension(contract => contract.contractor);

    const renderOptions = {
      containerSelector: "#contractor-bars",
      dimension: dimension,
      onFilteredFunction: (chart, filter) => {
        this._refreshData(
          dimension.top(Infinity),
          chart.filters(),
          "contractor"
        );
        EventBus.$emit("dc-filter-selected", { title: filter, id: "contractor" });
      }
    };

    this.charts["contractor"] = new GroupPctDistributionBars(renderOptions);
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

  _refreshTendersDataFromFilters(filters, tendersAttribute) {
    this.tendersFilters[tendersAttribute] = filters;
    let filteredTendersData = [...this.unfilteredTendersData];

    Object.keys(this.tendersFilters).forEach(key => {
      if (this.tendersFilters[key].length > 0) {
        filteredTendersData = filteredTendersData.filter(tender =>
          this.tendersFilters[key].includes(tender[key])
        );
      }
    });

    this.data.tendersData = filteredTendersData;
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

  _formalizedContractsData(contractsData) {
    return contractsData.filter(
      ({ status }) => status === I18n.t('gobierto_visualizations.visualizations.status_types.formalized') || status === I18n.t('gobierto_visualizations.visualizations.status_types.awarded')
    );
  }
}
