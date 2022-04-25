import Vue from "vue";
import VueRouter from "vue-router";
import { getRemoteData } from "../webapp/lib/utils";
import { EventBus } from "../webapp/lib/mixins/event_bus";
import { checkAndReportAccessibility } from "lib/vue/accesibility";

if (Vue.config.devtools) {
  Vue.use(checkAndReportAccessibility)
}
Vue.use(VueRouter);
Vue.config.productionTip = false;

export class CostsController {
  constructor(options) {
    console.log("options", options);
    this.charts = {};

    const selector = "gobierto-visualizations-debts-app";

    // Mount Vue applications
    const entryPoint = document.getElementById(selector);

    if (entryPoint) {
      const htmlRouterBlock = `<router-view></router-view>`;

      entryPoint.innerHTML = htmlRouterBlock;

      const Home = () =>
        import("../webapp/containers/debts/Home.vue");

      Promise.resolve(getRemoteData(options.costsEndpoint)).then(rawData => {
        this.setGlobalVariables(rawData);

        const router = new VueRouter({
          mode: "history",
          routes: [
            {
              path: "/visualizaciones/deuda/",
              name: "Home",
              component: Home
            }
          ],
          scrollBehavior(to) {
            let element;
            element = document.getElementById(
              "gobierto-visualizations-title-detail"
            );
            element.scrollIntoView({ behavior: "smooth" });
          }
        });

        const baseTitle = document.title;
        router.afterEach(to => {
          // Wait 2 ticks
          Vue.nextTick(() =>
            Vue.nextTick(() => {
              document.title = baseTitle;
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
      debtsData: rawData
    };
  }
}
