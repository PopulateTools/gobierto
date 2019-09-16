import Vue from "vue";
import VueRouter from "vue-router";
Vue.use(VueRouter);
Vue.config.productionTip = false;

import Home from "../webapp/containers/home/Home.vue";
import Project from "../webapp/containers/project/Project.vue";

export class InvestmentsController {
  constructor() {
    // Mount Vue application
    const entryPoint = document.getElementById("investments-app");
    if (entryPoint) {
      const routes = [
        { path: "/inversiones/proyectos", name: "home", component: Home },
        { path: "/inversiones/proyectos/:id", name: "project", component: Project }
      ];
      const router = new VueRouter({
        mode: "history",
        routes
      });

      new Vue({ router }).$mount(entryPoint);
    }
  }
}
