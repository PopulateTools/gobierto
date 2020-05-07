import Vue from "vue";
import VueRouter from "vue-router";
import { getRemoteData } from '../webapp/mixins/get_remote_data'

Vue.use(VueRouter);
Vue.config.productionTip = false;

export class ContractsController {
  constructor(options) {
    const selector = "gobierto-dashboards-contracts-app";

    // Mount Vue applications
    const entryPoint = document.getElementById(selector);

    const remoteCsvData = {
      contractsData: getRemoteData(options.contractsEndpoint),
      tendersData: getRemoteData(options.tendersEndpoint)
    };

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

      new Vue({
        router,
        data: Object.assign(options, remoteCsvData),
      }).$mount(entryPoint);
    }
  }
}
