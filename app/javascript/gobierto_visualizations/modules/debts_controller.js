import Vue from "vue";
import VueRouter from "vue-router";
import { getRemoteData } from "../webapp/lib/utils";
import { EventBus } from "../webapp/lib/mixins/event_bus";
import { checkAndReportAccessibility } from "lib/vue/accesibility";

const data1 = getRemoteData('../../../debts/01_Deute_Total_Deutor.csv')
const data2 = getRemoteData('../../../debts/02_Deute_Entitat_Creditora.csv')
const data3 = getRemoteData('../../../debts/03_evolucio_endeutament_GRUP_AJUNTAMENT.csv')

let getDebtsData = [];

if (Vue.config.devtools) {
  Vue.use(checkAndReportAccessibility)
}
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

      Promise.resolve(getRemoteData(options.debtsEndpoint)).then(rawData => {
        Promise.all([data1, data2, data3]).then(values => {
          [getDebtsData[0], getDebtsData[1], getDebtsData[2]] = [values[0], values[1], values[2]]
          this.setGlobalVariables(getDebtsData);
        });

        const router = new VueRouter({
          mode: "history",
          routes: [
            {
              path: "/visualizaciones/deuda",
              name: "Home",
              component: Home
            }
          ],
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
          console.log("loadingElement", loadingElement);
          if (loadingElement) {
            loadingElement.classList.add("hidden");
          }
        });
      });
    }
  }

  setGlobalVariables(rawData) {
    //Convert strings with some format to Numbers without format

    this.data = {
      debtsData: rawData
    };
  }
}
