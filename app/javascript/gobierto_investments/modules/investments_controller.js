import Vue from "vue";
import VueRouter from "vue-router";

Vue.use(VueRouter);
Vue.config.productionTip = false;

export class InvestmentsController {
  constructor() {
    const selector = "investments-app";

    // Mount Vue application
    const entryPoint = document.getElementById(selector);
    if (entryPoint) {
      const htmlRouterBlock = `
        <keep-alive>
          <transition name="fade" mode="out-in">
            <router-view :key="$route.fullPath"></router-view>
          </transition>
        </keep-alive>
      `;

      entryPoint.innerHTML = htmlRouterBlock

      const Home = () => import("../webapp/containers/home/Home.vue")
      const Project = () => import("../webapp/containers/project/Project.vue")

      const router = new VueRouter({
        mode: "history",
        routes: [
          { path: "/inversiones", name: "home", component: Home },
          { path: "/inversiones/proyectos/:id", name: "project", component: Project }
        ],
        scrollBehavior () {
          const element = document.getElementById(selector)
          window.scrollTo({ top: element.offsetTop, behavior: 'smooth' });
        }
      });

      Vue.prototype.$baseUrl = `${location.origin}/gobierto_investments/api/v1/projects`;
      new Vue({ router }).$mount(entryPoint);
    }
  }
}
