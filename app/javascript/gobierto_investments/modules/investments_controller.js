import Vue from "vue";
import VueRouter from "vue-router";
Vue.use(VueRouter);
Vue.config.productionTip = false;

export class InvestmentsController {
  constructor() {
    // Mount Vue application
    const entryPoint = document.getElementById("investments-app");
    if (entryPoint) {
      const Home = () => import("../webapp/containers/home/Home.vue");
      const Project = () => import("../webapp/containers/project/Project.vue");

      const router = new VueRouter({
        mode: "history",
        routes: [
          { path: "/inversiones/proyectos", name: "home", component: Home },
          { path: "/inversiones/proyectos/:id", name: "project", component: Project }
        ]
      });

      new Vue({ router }).$mount(entryPoint);
    }
  }
}
