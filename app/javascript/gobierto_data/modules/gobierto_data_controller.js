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
          <router-view/>
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
            props: true,
            component: Home
          },
          {
            path: "/datos/:id",
            name: "dataset",
            props: true,
            component: Sets,
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
              const { title: projectTitle } = to.params;

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
