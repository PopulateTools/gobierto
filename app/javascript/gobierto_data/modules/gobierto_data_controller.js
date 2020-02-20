import Vue from "vue";
import VueRouter from "vue-router";
import 'codemirror/lib/codemirror.css'

Vue.use(VueRouter);
Vue.config.productionTip = false;

export class GobiertoDataController {
  constructor(options) {
    const selector = "gobierto-datos-app";

    // Mount Vue application
    const entryPoint = document.getElementById(selector);
    if (entryPoint) {
      const htmlRouterBlock = `
          <router-view :key="$route.fullPath"></router-view>
      `;

      entryPoint.innerHTML = htmlRouterBlock;

      const Home = () => import("../webapp/pages/Home.vue");

      const router = new VueRouter({
        mode: "history",
        routes: [{
            path: "/datos",
            name: "home",
            component: Home,
            props: { currentComponent: 'InfoList', activateTabSidebar: 0 }
          },
          {
            path: "/datos/:id",
            name: "dataset",
            component: Home,
            props: { currentComponent: 'DataSets', activateTabSidebar: 1 }
          }
        ]
      })

      const baseTitle = document.title;

      router.afterEach(to => {
        // Wait 2 ticks
        Vue.nextTick(() =>
          Vue.nextTick(() => {
            let title = baseTitle;
            if (to.name === "dataset") {
              const { titleDataset: dataset } = to.params;

              if (dataset) {
                const titleI18n = dataset
                  ? `${dataset} · `
                  : "";

                title = `${titleI18n}${baseTitle}`;
              }
            }

            document.title = title;
          })
        );
      })

      new Vue({
        router,
        data: options,
      }).$mount(entryPoint);
    }
  }
}
