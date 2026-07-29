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
import { calculateSumMeanMedian, effectiveTenderId, getRemoteData } from '../webapp/lib/utils';
import { divide } from '../../lib/shared';

// ESBuild does not work properly with dynamic components
import Home from '../webapp/containers/contracts/Home.vue';
import Summary from '../webapp/containers/contracts/Summary.vue';
import ContractsIndex from '../webapp/containers/contracts/ContractsIndex.vue';
import ContractsShow from '../webapp/containers/contracts/ContractsShow.vue';
import AssigneesShow from '../webapp/containers/contracts/AssigneesShow.vue';
// const Home = () => import('../webapp/containers/contracts/Home.vue');
// const Summary = () => import('../webapp/containers/contracts/Summary.vue');
// const ContractsIndex = () => import('../webapp/containers/contracts/ContractsIndex.vue');
// const ContractsShow = () => import('../webapp/containers/contracts/ContractsShow.vue');
// const AssigneesShow = () => import('../webapp/containers/contracts/AssigneesShow.vue');

if (Vue.config.devtools) {
  Vue.use(checkAndReportAccessibility)
}

Vue.use(VueRouter);
Vue.config.productionTip = false;

// Mirrors CONTRACTING_SYSTEM_TYPES in open-licitaciones
// (app/models/concerns/is_tender.rb). It is an official CODICE code, the order is
// stable. The ETL exports the integer, not the text, so the I18n keys are ours
// (and spelled without the "establishement" typo the origin carries).
const CONTRACTING_SYSTEMS = [
  'none',
  'based_on_agreement_establishment',
  'dynamic_acquisition_establishment',
  'based_on_agreement',
  'dynamic_acquisition'
];

export class ContractsController {
  constructor(options) {
    this.charts = {};
    // Sidebar filters with no dc chart behind them. We keep the crossfilter
    // dimension and the set of selected values ourselves, because without a chart
    // there is no onFiltered callback doing it for us. They must stay out of
    // this.charts: several loops there assume every entry has .container and .node.
    this.chartlessFilters = {};
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
              alias: "/",
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

        // Events must listen BEFORE vue application to start (i.e. the trigger)
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

        EventBus.$on("mounted", () => {
          // Hide the external loader once the vueApp has been mounted in the DOM
          const loadingElement = document.querySelector(".js-loading");
          if (loadingElement) {
            loadingElement.classList.add("hidden");
          }
        });

        const data = Object.assign(options, this.data)

        this.vueApp = new Vue({
          router,
          data,
        }).$mount(entryPoint);
      });
    }
  }

  setGlobalVariables([contractsData, tendersData]) {
    let contractsDataMap = this._translate(contractsData, false)
    let tendersDataMap = this._translate(tendersData, true)
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

    // The código de expediente lives on the tender (document_number) and is
    // shared by all its lots through the tender id. Contracts may also carry it
    // themselves, and that value wins when present.
    //
    // The join goes through effectiveTenderId, which resolves the tender of a
    // contract and returns null when there is none to join against (a minor
    // contract, whose id belongs to a colliding id space). Falsy tender ids are
    // skipped for the same reason: some tenders arrive with an empty id.
    const tenderByTenderId = tendersData.reduce((acc, tender) => {
      if (tender.id) acc[tender.id] = tender;
      return acc;
    }, {});
    const contractTender = row => {
      const key = effectiveTenderId(row);
      return key ? tenderByTenderId[key] : undefined;
    };
    const tenderDocumentNumber = row => {
      const { document_number } = contractTender(row) || {};
      return document_number || '';
    };

    // The establishment tender of a derived contract lives only in the tenders
    // dataset (contracting systems 1 and 2 never appear in contracts). We resolve
    // it here, once per load, instead of in the detail: the search reads these
    // fields too, and it walks the whole dataset on every keystroke. Empty strings
    // when the contract is not derived or the tender is not found, so the detail
    // can hide the block with a plain truthiness check.
    const establishment = row => {
      const tender = row.is_derived_contract ? contractTender(row) : undefined;
      return {
        establishment_title: (tender && tender.title) || '',
        establishment_document_number: (tender && tender.document_number) || ''
      };
    };

    contractsDataMap = contractsData.map(({ final_amount_no_taxes = 0, initial_amount_no_taxes = 0, gobierto_start_date, assignee_id, document_number, ...rest }) => {
      return {
        final_amount_no_taxes: (final_amount_no_taxes && !Number.isNaN(final_amount_no_taxes)) ? parseFloat(final_amount_no_taxes): 0.0,
        initial_amount_no_taxes: (initial_amount_no_taxes && !Number.isNaN(initial_amount_no_taxes)) ? parseFloat(initial_amount_no_taxes): 0.0,
        range: rangeFormat(+final_amount_no_taxes),
        assignee_routing_id: assignee_id,
        gobierto_start_date_year: gobierto_start_date ? new Date(gobierto_start_date).getFullYear().toString() : '',
        gobierto_start_date: new Date(gobierto_start_date),
        ...rest,
        document_number: document_number || tenderDocumentNumber(rest),
        ...establishment(rest)
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

    // Nothing mutates individual rows after this point (components copy rows
    // with spread before adding fields, crossfilter and dc charts only read).
    // Freezing each row lets Vue 2 skip making its ~25 fields reactive, which
    // on large sites (tens of thousands of rows) avoids hundreds of thousands
    // of getter/setter + Dep allocations at startup. Freeze the rows, not the
    // arrays, so the in-place sorts above still work.
    this.data.contractsData.forEach(Object.freeze);
    this.unfilteredTendersData.forEach(Object.freeze);
  }

  _translate(data, dataForTenders) {
    // These fields only take a handful of distinct values, but the dataset can
    // hold tens of thousands of rows. Memoize each key so I18n.t runs once per
    // distinct value instead of once per row.
    const cache = Object.create(null)
    const t = key => (key in cache ? cache[key] : (cache[key] = I18n.t(key)))
    const statusPrefix = dataForTenders
      ? 'gobierto_visualizations.visualizations.tender_statuses'
      : 'gobierto_visualizations.visualizations.contract_statuses'

    return data.map(d => {
      const { category_title, contract_type, process_type, status } = d

      // 3 (based_on_agreement) and 4 (dynamic_acquisition) are the contracts
      // derived from a framework agreement or a dynamic acquisition system; 1 and
      // 2 are the establishment tenders and never show up in `contratos`. We keep
      // the boolean because the translation below overwrites the integer and the
      // components can no longer recover it. `+undefined` is NaN and NaN >= 3 is
      // false, so sites still serving the old CSV land on false.
      if (!dataForTenders) {
        d.is_derived_contract = +d.contracting_system >= 3
      }

      if (category_title) {
        d.category_title = t(`gobierto_visualizations.visualizations.categories.${category_title}`)
      }

      if (contract_type) {
        d.contract_type = t(`gobierto_visualizations.visualizations.contract_types.${contract_type}`)
      }

      if (process_type) {
        d.process_type = t(`gobierto_visualizations.visualizations.process_types.${process_type}`)
      }

      // Guarded like the fields above: two of the UJI's tenders arrive with an
      // empty status, and translating it renders the I18n missing-key message
      // where an empty row was meant to be.
      if (status) {
        d.status = t(`${statusPrefix}.${status}`)
      }

      // The CSV delivers numbers as strings. `none` (0) is normalized to '' so it
      // shows up neither as a filter option nor as a row in the detail, the same
      // as every other empty field. A missing column (a site still serving the old
      // CSV) lands here too and also ends up as '': `+undefined` is NaN and
      // CONTRACTING_SYSTEMS[NaN] is undefined.
      const system = CONTRACTING_SYSTEMS[+d.contracting_system]
      d.contracting_system = (system && system !== 'none')
        ? t(`gobierto_visualizations.visualizations.contracting_systems.${system}`)
        : ''

      return d
    })
  }

  _renderSummary() {
    this.ndx = crossfilter(this._currentDataSource().contractsData);

    // Registered here and not in the constructor because this.ndx is recreated on
    // every call, and a dimension of a discarded crossfilter filters nothing.
    this.chartlessFilters["contracting_systems"] = {
      dimension: this.ndx.dimension(contract => contract.contracting_system),
      selected: new Set()
    };

    this._renderTendersMetricsBox();
    this._renderContractsMetricsBox();

    this._renderByAmountsChart();
    this._renderContractTypeChart();
    this._renderProcessTypeChart();
    this._renderDateChart();
    this._renderCategoriesChart();
    this._renderEntitiesChart();
    this._renderProcessTypePerAmountChart();
  }

  _refreshData(reducedContractsData, filters, tendersAttribute) {
    // With no filter active, crossfilter hands back the whole dataset as a fresh
    // array. Reuse the original reference so the assignment below doesn't look
    // like a change to downstream consumers that compare by identity.
    if (reducedContractsData.length === this.data.contractsData.length) {
      reducedContractsData = this.data.contractsData;
    }

    if (filters) {
      this._refreshTendersDataFromFilters(filters, tendersAttribute);
    }
    this.reduced = {
      tendersData: this.data.tendersData,
      contractsData: reducedContractsData
    };

    this.vueApp.contractsData = reducedContractsData;

    // The downstream refresh (treemaps, beeswarm, tables, metric boxes) is heavy
    // on large datasets and otherwise runs synchronously inside the filter click
    // handler, freezing the UI so it looks like nothing happens — worst when
    // clearing a filter and the full dataset comes back. Defer it to the next
    // frame so the click and the dc chart redraw paint first, and coalesce rapid
    // toggles into a single refresh.
    if (this._refreshHandle) {
      cancelAnimationFrame(this._refreshHandle);
    }
    this._refreshHandle = requestAnimationFrame(() => {
      this._refreshHandle = null;
      EventBus.$emit("refresh-summary-data");
      this._renderTendersMetricsBox();
      this._renderContractsMetricsBox();
    });
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
    const lessThan1000Pct = divide(lessThan1000Total, numberContracts);

    const largerContractAmount = d3.max(
      _contractsData,
      ({ final_amount_no_taxes = 0 }) => parseFloat(final_amount_no_taxes)
    );
    const largerContractAmountPct = sumContracts ? (divide(largerContractAmount, sumContracts)) : 0;

    let iteratorAmountsSum = 0,
      numberContractsHalfSpendings = 0;
    for (let i = 0; i < sortedAmountsArray.length; i++) {
      iteratorAmountsSum += sortedAmountsArray[i];
      numberContractsHalfSpendings++;

      if (iteratorAmountsSum > sumContracts / 2) {
        break;
      }
    }
    const halfSpendingsContractsPct = divide(numberContractsHalfSpendings, numberContracts);

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

  _renderProcessTypePerAmountChart() {
    const dimension = this.ndx.dimension(contract => contract.process_type);

    const renderOptions = {
      containerSelector: "#process-type-per-amount-bars",
      dimension: dimension,
      groupValue: 'final_amount_no_taxes',
      onFilteredFunction: (chart, filter) => {
        this._refreshData(
          dimension.top(Infinity),
          chart.filters(),
          "final_amount_no_taxes"
        );
        EventBus.$emit("dc-filter-selected", {
          title: filter,
          id: "process_types"
        });
      }
    };

    this.charts["process_types_per_amount"] = new GroupPctDistributionBars(renderOptions);
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
    // apply the filters
    const chartless = this.chartlessFilters[options.id];
    if (chartless) {
      this._applyChartlessFilter(chartless, options);
    } else {
      this.charts[options.id].container.filter(options.all ? null : options.title);
    }

    Object.values(this.charts).forEach(chart => {
      // Math.round in order to avoid a javascript issue handling floating numbers (very tiny decimals)
      const hasData = chart.container.data().reduce((acc, item) => acc + Math.round(item.value), 0) !== 0

      if (hasData) {
        // remove the no data indicator, if exists
        chart.node.nextElementSibling?.remove()
        // show the original chart
        chart.node.removeAttribute("style")
        chart.container.redraw()
      } else {
        // add a text label indicating no data, when it's not already present
        if (!chart.node.nextElementSibling) {
          const div = document.createElement("div")
          div.innerHTML = I18n.t("gobierto_common.vue_components.table.no_data")
          chart.node.insertAdjacentElement("afterend", div);
        }
        // hide the original chart
        chart.node.style.display = "none"
      }
    });
  }

  _applyChartlessFilter(chartless, { all, title, titles }) {
    const { dimension, selected } = chartless;

    // Aside emits one title per click and expects the selection to accumulate, so
    // the semantics are toggle, not replace: filterExact(title) would be wrong.
    if (all) {
      // "Select all" toggles: if everything was already selected, clear it.
      if (selected.size === titles.length) selected.clear();
      else titles.forEach(t => selected.add(t));
    } else if (selected.has(title)) {
      selected.delete(title);
    } else {
      selected.add(title);
    }

    if (selected.size === 0) {
      dimension.filterAll();
    } else {
      dimension.filterFunction(value => selected.has(value));
    }

    // Deliberately without the filter arguments: this filter must not propagate to
    // the tenders dataset. Derived contracts carry contracting_system 3 or 4 while
    // establishment tenders carry 1 or 2, so matching the selected label against
    // `licitaciones` would find no row and empty the tenders panel.
    this._refreshData(dimension.top(Infinity));
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
    // Resolve the labels once instead of on every row: the translation is
    // constant, so calling I18n.t inside the filter recomputed it for all rows.
    const formalized = I18n.t('gobierto_visualizations.visualizations.contract_statuses.formalized');
    const awarded = I18n.t('gobierto_visualizations.visualizations.contract_statuses.awarded');
    return contractsData.filter(
      ({ status }) => status === formalized || status === awarded
    );
  }
}
