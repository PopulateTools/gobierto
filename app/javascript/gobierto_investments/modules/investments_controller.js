import Vue from 'vue';
import VueRouter from 'vue-router';
import { checkAndReportAccessibility } from '../../lib/vue/accessibility';

// ESBuild does not work properly with dynamic components
import Home from '../webapp/containers/home/Home.vue';
import Project from '../webapp/containers/project/Project.vue';
import MapTour from '../webapp/components/MapTour.vue';
// const Home = () => import('../webapp/containers/home/Home.vue');
// const Project = () => import('../webapp/containers/project/Project.vue');
// const MapTour = () => import('../webapp/components/MapTour.vue');

if (Vue.config.devtools) {
  Vue.use(checkAndReportAccessibility)
}

Vue.use(VueRouter);
Vue.config.productionTip = false;

export class InvestmentsController {
  constructor(options) {
    const selector = "investments-app";

    // Mount Vue application
    const entryPoint = document.getElementById(selector);
    if (entryPoint) {
      const htmlRouterBlock = `
        <transition name="fade" mode="out-in">
          <keep-alive>
            <router-view :key="$route.path"></router-view>
          </keep-alive>
        </transition>
      `;

      entryPoint.innerHTML = htmlRouterBlock;

      const router = new VueRouter({
        mode: "history",
        routes: [
          { path: "/inversiones", name: "home", component: Home },
          { path: "/inversiones/proyectos/:id", name: "project", component: Project },
          { path: "/inversiones/tour-virtual", name: "tourVirtual", component: MapTour }
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
            if (to.name === "project") {
              const { item: { title: projectTitle } = {} } = to.params;

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
      });

      new Vue({
        router,
        data: options,
      }).$mount(entryPoint);
    }
  }
}
