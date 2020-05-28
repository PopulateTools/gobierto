import Vue from "vue";
import VueRouter from "vue-router";

import { getRemoteData } from '../webapp/lib/utils'
import { EventBus } from '../webapp/mixins/event_bus'

import { VisBubble } from "lib/visualizations";

Vue.use(VueRouter);
Vue.config.productionTip = false;

export class CostsController {
  constructor(options) {
    this.charts = {};

    const selector = "gobierto-dashboards-costs-app";

    // Mount Vue applications
    const entryPoint = document.getElementById(selector);

    if (entryPoint) {
      const htmlRouterBlock = `<router-view></router-view>`;

      entryPoint.innerHTML = htmlRouterBlock;

      const Home = () => import("../webapp/containers/shared/Home.vue");

      //FIX-ME: get
      // JSON https://mataro.gobify.net/api/v1/data/data?sql=select%20*%20from%20costes
      // CSV https://mataro.gobify.net/api/v1/data/data.csv?sql=select%20*%20from%20costes
      Promise.all([getRemoteData(options.contractsEndpoint), getRemoteData(options.tendersEndpoint)]).then((rawData) => {
        this.setGlobalVariables(rawData)

        const router = new VueRouter({
          mode: "history",
          routes: [
            { path: "/costes", component: Home
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

        this.vueApp = new Vue({
          router,
          data: Object.assign(options, this.data),
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

        const loadingElement = document.querySelector(".js-loading");
        if (loadingElement) {
          loadingElement.classList.add('hidden')
        }
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
    this._amountRange = {
      domain: [1001, 10001, 50001, 100001],
      range: [0, 1, 2, 3, 4]
    };
    var rangeFormat = d3.scaleThreshold().domain(this._amountRange.domain).range(this._amountRange.range);

    for(let i = 0; i < contractsData.length; i++){
      const contract = contractsData[i];
      const final_amount_no_taxes = contract.final_amount_no_taxes ? parseFloat(contract.final_amount_no_taxes) : 0.0;
      const initial_amount_no_taxes = contract.initial_amount_no_taxes ? parseFloat(contract.initial_amount_no_taxes) : 0.0 ;

      contract.final_amount_no_taxes = final_amount_no_taxes;
      contract.initial_amount_no_taxes = initial_amount_no_taxes;
      contract.range = rangeFormat(+final_amount_no_taxes);
      contract.start_date_year = contract.start_date ? (new Date(contract.start_date).getFullYear()) : contract.start_date;
    }

    for(let i = 0; i < tendersData.length; i++){
      const tender = tendersData[i];
      const initial_amount_no_taxes = tender.initial_amount_no_taxes ? parseFloat(tender.initial_amount_no_taxes) : 0.0;

      tender.initial_amount_no_taxes = initial_amount_no_taxes;
      tender.submission_date_year = tender.submission_date ? (new Date(tender.submission_date).getFullYear()) : tender.submission_date;

      if(tender.submission_date_year) { tender.submission_date_year = tender.submission_date_year.toString() }
    }

    this.unfilteredTendersData = tendersData.sort(sortByField('submission_date'));

    this.data = {
      contractsData: this._formalizedContractsData(contractsData).sort(sortByField('start_date')),
      tendersData: this.unfilteredTendersData,
    }
  }

}
