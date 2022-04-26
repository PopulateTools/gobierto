import Vue from "vue";
import VueRouter from "vue-router";
import { EventBus } from "../webapp/lib/mixins/event_bus";
import { json } from 'd3-fetch';

function getRemoteDataJSON(endpoint) {
  return json(endpoint);
}

const data1 = getRemoteDataJSON('../../../debts/deute_total_deutor.json');
const data2 = getRemoteDataJSON('../../../debts/deute_entitat_creditora.json');
const data3 = getRemoteDataJSON('../../../debts/evolucio_endeutament_GRUP_AJUNTAMENT.json');

let getDebtsData = [];

/*if (Vue.config.devtools) {
  Vue.use(checkAndReportAccessibility)
}*/
Vue.use(VueRouter);
Vue.config.productionTip = false;

export class DebtsController {
  constructor(options) {
    this.charts = {};

    const selector = "gobierto-visualizations-debts-app";

    // Mount Vue applications
    const entryPoint = document.getElementById(selector);

    if (entryPoint) {
      const htmlRouterBlock = `<router-view></router-view>`;

      entryPoint.innerHTML = htmlRouterBlock;

      const Home = () =>
        import("../webapp/containers/debts/Home.vue");

      Promise.all([data1, data2, data3]).then(values => {
        [getDebtsData[0], getDebtsData[1], getDebtsData[2]] = [values[0], values[1], values[2]]
        this.setGlobalVariables(getDebtsData);
        const router = new VueRouter({
          mode: "history",
          routes: [{
            path: "/visualizaciones/deuda",
            name: "Home",
            component: Home
          }],
          /*scrollBehavior(to) {
            const element = document.getElementById(
              "gobierto-visualizations-title-detail"
            );
            element.scrollIntoView({ behavior: "smooth" });
          }*/
        });

        const baseTitle = document.title;
        router.afterEach(to => {
          // Wait 2 ticks
          Vue.nextTick(() =>
            Vue.nextTick(() => {
              if (to.name === "contracts_show" || to.name === "tenders_show") {
                const { item: { title: itemTitle } = {} } = to.params;

                if (itemTitle) {
                  title = `${itemTitle}${baseTitle}`;
                }
              }
              let title = baseTitle;
              document.title = title;
            })
          );
        });

        this.vueApp = new Vue({
          router,
          data: Object.assign(options, this.data)
        }).$mount(entryPoint);

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
    this.data = {
      debtsData: rawData[0],
      debtsData1: rawData[1],
      debtsData2: rawData[2]
    };
  }
}
