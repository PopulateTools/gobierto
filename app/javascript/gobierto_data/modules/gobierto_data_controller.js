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
        <router-view></router-view>
      </keep-alive>
      `;

      entryPoint.innerHTML = htmlRouterBlock;

      const Home = () => import("../webapp/pages/Home.vue");
      const Sets = () => import("../webapp/pages/Sets.vue");
      const Summary = () => import("../webapp/components/sets/Summary.vue");
      const Editor = () => import("../webapp/components/sets/Data.vue");
      const Queries = () => import("../webapp/components/sets/Queries.vue");
      const Visualizations = () => import("../webapp/components/sets/Visualizations.vue");
      const Downloads = () => import("../webapp/components/sets/Downloads.vue");


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
            props: { currentComponent: 'DataSets', activateTabSidebar: 1 },
            children: [
             {
               path: "",
               name: "resumen",
               component: Summary
             },
             {
               path: "editor",
               name: "editor",
               props: true,
               component: Editor
             },
             {
               path: "consultas",
               name: "consultas",
               component: Queries
             },
             {
               path: "visualizaciones",
               name: "visualizaciones",
               component: Visualizations
             },
             {
               path: "descarga",
               name: "descarga",
               component: Downloads
             },
             {
               path: "q/:queryId",
               name: "queries",
               component: Editor
             }
           ]
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
