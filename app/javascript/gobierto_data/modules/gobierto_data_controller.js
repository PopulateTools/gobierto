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
      <keep-alive>
        <router-view :key="$route.params.id"></router-view>
      </keep-alive>
      `;

      entryPoint.innerHTML = htmlRouterBlock;

      const Home = () => import("../webapp/pages/Home.vue");

      const router = new VueRouter({

        mode: "history",
        routes: [{
            path: "/datos",
            name: "home",
            component: Home,
            props: {
              currentComponent: 'InfoList',
              activateTabSidebar: 0
            }
          },
          {
            path: "/datos/:id",
            name: "dataset",
            component: Home,
            props: {
              currentComponent: 'DataSets',
              activateTabSidebar: 1
            }
          },
          {
            path: "/datos/:id/resumen",
            name: "resumen",
            component: Home,
            props: {
              currentComponent: 'DataSets',
              activateTabSidebar: 1,
              activeDatasetTab: 0
            }
          },
          {
            path: "/datos/:id/editor",
            name: "editor",
            component: Home,
            props: {
              currentComponent: 'DataSets',
              activateTabSidebar: 1,
              activeDatasetTab: 1
            }
          },
          {
            path: "/datos/:id/consultas",
            name: "consultas",
            component: Home,
            props: {
              currentComponent: 'DataSets',
              activateTabSidebar: 1,
              activeDatasetTab: 2
            }
          },
          {
            path: "/datos/:id/visualizaciones",
            name: "visualizaciones",
            component: Home,
            props: {
              currentComponent: 'DataSets',
              activateTabSidebar: 1,
              activeDatasetTab: 3
            }
          },
          {
            path: "/datos/:id/descarga",
            name: "descarga",
            component: Home,
            props: {
              currentComponent: 'DataSets',
              activateTabSidebar: 1,
              activeDatasetTab: 4
            }
          },
          {
            path: "/datos/:id/q/:queryId",
            name: "queries",
            component: Home,
            props: {
              currentComponent: 'DataSets',
              activateTabSidebar: 1,
              activeDatasetTab: 1
            }
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
