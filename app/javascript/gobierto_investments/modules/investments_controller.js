import Vue from "vue";
import VueRouter from "vue-router";

Vue.use(VueRouter);
Vue.config.productionTip = false;

export class InvestmentsController {
  constructor() {
    // Mount Vue application
    const entryPoint = document.getElementById("investments-app");
    if (entryPoint) {
      const htmlRouterBlock = `
        <keep-alive>
          <router-view :key="$route.fullPath"></router-view>
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
        ]
      });

      Vue.prototype.$baseUrl = `${location.origin}/gobierto_investments/api/v1/projects`;
      new Vue({ router }).$mount(entryPoint);
    }
  }
}
