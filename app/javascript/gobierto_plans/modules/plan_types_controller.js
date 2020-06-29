import Vue from "vue";
import { router } from "../webapp/lib/router";

Vue.config.productionTip = false;

export class GobiertoPlansController {
  constructor(options = {}) {
    const selector = "gobierto-planification";

    // Mount Vue application
    const entryPoint = document.getElementById(selector);
    if (entryPoint) {
      const htmlRouterBlock = `
      <keep-alive>
        <router-view></router-view>
      </keep-alive>
      `;

      entryPoint.innerHTML = htmlRouterBlock;

      const { dataset: { baseurl, planId } } = entryPoint

      new Vue({
        router,
        data: { ...options, baseurl, planId },
      }).$mount(entryPoint);
    }
  }
}