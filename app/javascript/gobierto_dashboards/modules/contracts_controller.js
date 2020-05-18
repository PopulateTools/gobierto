import Vue from "vue";
import VueRouter from "vue-router";
import { getRemoteData } from '../webapp/lib/get_remote_data'
import { EventBus } from '../webapp/mixins/event_bus'
import { money } from 'lib/shared/modules/vue-filters'
import { sum, mean, median, max } from 'd3-array';

const d3 = { sum, mean, median, max }

Vue.use(VueRouter);
Vue.config.productionTip = false;

export class ContractsController {
  constructor(options) {
    const selector = "gobierto-dashboards-contracts-app";

    // Mount Vue applications
    const entryPoint = document.getElementById(selector);

    if (entryPoint) {
      const htmlRouterBlock = `
        <keep-alive>
          <transition name="fade" mode="out-in">
            <router-view :key="$route.fullPath"></router-view>
          </transition>
        </keep-alive>
      `;

      entryPoint.innerHTML = htmlRouterBlock;

      const Home = () => import("../webapp/containers/shared/Home.vue");
      const Summary = () => import("../webapp/containers/summary/Summary.vue");
      const ContractsIndex = () => import("../webapp/containers/contract/ContractsIndex.vue");
      const ContractsShow = () => import("../webapp/containers/contract/ContractsShow.vue");
      const TendersIndex = () => import("../webapp/containers/tender/TendersIndex.vue");
      const TendersShow = () => import("../webapp/containers/tender/TendersShow.vue");

      const router = new VueRouter({
        mode: "history",
        routes: [
          { path: "/dashboards/contratos", component: Home,
            children: [
              { path: "resumen", name: "summary", component: Summary },
              { path: "contratos", name: "contracts_index", component: ContractsIndex },
              { path: "contratos/:id", name: "contracts_show", component: ContractsShow },
              { path: "licitaciones", name: "tenders_index", component: TendersIndex },
              { path: "licitaciones/:id", name: "tenders_show", component: TendersShow },
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

      Promise.all([getRemoteData(options.contractsEndpoint), getRemoteData(options.tendersEndpoint)]).then((rawData) => {
        const remoteCsvData = this.buildDataObject(rawData)

        new Vue({
          router,
          data: Object.assign(options, remoteCsvData),
        }).$mount(entryPoint);

        EventBus.$on('summary_ready', () => {
          this._renderSummary(remoteCsvData);
        });
      });
    }
  }

  buildDataObject(rawData){
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
          return -1;
        } else if ( aDate > bDate ){
          return 1;
        } else {
          return 0;
        }
      }
    }

    const result = {
      contractsData: contractsData.sort(sortByField('end_date')),
      tendersData: tendersData.sort(sortByField('submission_date')),
    }

    return result;
  }

  _renderSummary(remoteCsvData){
    this._renderTendersMetricsBox(remoteCsvData.tendersData);
    this._renderContractsMetricsBox(remoteCsvData.contractsData);
  }

  _renderTendersMetricsBox(tendersData){
    // Calculations
    const amountsArray = tendersData.map(({initial_amount = 0}) => initial_amount === '' ? 0.0 : parseFloat(initial_amount) );

    const numberTenders = tendersData.length;
    const sumTenders = d3.sum(amountsArray);
    const meanTenders = d3.mean(amountsArray);
    const medianTenders = d3.median(amountsArray);

    // Updating the DOM
    document.getElementById("number-tenders").innerText = numberTenders.toLocaleString();
    document.getElementById("sum-tenders").innerText = money(sumTenders);
    document.getElementById("mean-tenders").innerText = money(meanTenders);
    document.getElementById("median-tenders").innerText = money(medianTenders);
  }

  _renderContractsMetricsBox(contractsData){
    // Calculations
    const amountsArray = contractsData.map(({final_amount = 0}) => final_amount === '' ? 0.0 : parseFloat(final_amount) );
    const sortedAmountsArray = amountsArray.sort((a, b) => b - a);
    const savingsArray = contractsData.map(({initial_amount = 0, final_amount = 0}) =>{
      initial_amount = initial_amount === '' ? 0.0 : initial_amount;
      final_amount = final_amount === '' ? 0.0 : final_amount;

      return (1 - parseFloat(final_amount) / parseFloat(initial_amount))
    });

    // Calculations box items
    const numberContracts = contractsData.length;
    const sumContracts = d3.sum(amountsArray);
    const meanContracts = d3.mean(amountsArray);
    const medianContracts = d3.median(amountsArray);
    const meanSavings = d3.mean(savingsArray);

    // Calculations headlines
    const lessThan1000Total = contractsData.filter(({final_amount = 0}) => parseFloat(final_amount) < 1000).length;
    const lessThan1000Pct = lessThan1000Total/numberContracts;

    const largerContractAmount = d3.max(contractsData, ({final_amount = 0}) => parseFloat(final_amount));
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

    document.getElementById("mean-savings").innerText = meanSavings.toLocaleString(I18n.locale, {
      style: 'percent'
    });
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
}
