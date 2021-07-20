import Vue from "vue";
import { router } from "../lib/router";
import 'codemirror/lib/codemirror.css';
import { checkAndReportAccessibility } from "lib/vue/accesibility";

if (Vue.config.devtools) {
  Vue.use(checkAndReportAccessibility)
}
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

      new Vue({
        router,
        data: options,
      }).$mount(entryPoint);
    }
  }
}
