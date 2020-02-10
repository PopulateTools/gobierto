import Vue from "vue";
import VueRouter from "vue-router";
import VueCodemirror from 'vue-codemirror'
import 'codemirror/lib/codemirror.css'

Vue.use(VueRouter);
Vue.use(VueCodemirror);
Vue.config.productionTip = false;

export class GobiertoDataController {
  constructor(options) {
    const selector = "gobierto-datos-app";

    // Mount Vue application
    const entryPoint = document.getElementById(selector);
    if (entryPoint) {
      const htmlRouterBlock = `
        <keep-alive>
          <router-view :key="$route.fullPath"></router-view>
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
            name: "home", component: Home
          },
          {
            path: "/datos/:id",
            name: "dataset",
            component: Sets,
            children: [
             {
               path: "/datos/:id/resumen",
               name: "resumen",
               component: Summary
             },
             {
               path: "/datos/:id/editor",
               name: "editor",
               component: Editor
             },
             {
               path: "/datos/:id/consultas",
               name: "consultas",
               component: Queries
             },
             {
               path: "/datos/:id/visualizaciones",
               name: "visualizaciones",
               component: Visualizations
             },
             {
               path: "/datos/:id/descarga",
               name: "descarga",
               component: Downloads
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
              const { id: projectTitle } = to.params;

              if (projectTitle) {
                const titleI18n = projectTitle
                  ? `${projectTitle} · `
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
